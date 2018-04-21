//
//  SaveAssets.swift
//  ProjectX
//
//  Created by amir lahav on 5.10.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit
import CoreLocation
import Photos
import RNCryptor
import KeychainSwift



protocol SaveAssetsProtocol:class {
    func willStartSaveAssets()
    func finishSaveAsset()
    func numOfAssetToSave(num:Int)
    func showUserAlert(title:String, message:String)
}


struct SaveAssets {
    
    
    var saveAssetsDelegate: SaveAssetsProtocol?
    
    var onProgress:(_ progress: Double)->() = {_ in }
    var onComplite:()->() = { _ in }
    var shouldSave = true
    fileprivate var loadImageHelper = LoadImageHelper()
    fileprivate var reachability = Reachability()
    fileprivate var serialQueue = DispatchQueue(label: "com.queue.Serial", qos: .utility)
    
    func save(assets: [PHAsset])
    {
        var imageAssetCollection = [MediaAsset]()
        var videoAssetCollection = [MediaAsset]()
        
        var numOfAssets:[Int] = [Int]()
        let imageOptions = PHImageRequestOptions()
        imageOptions.deliveryMode = .highQualityFormat
        imageOptions.version = .current
        imageOptions.isSynchronous = true
        imageOptions.isNetworkAccessAllowed = true
        
        let videoOption = PHVideoRequestOptions()
        videoOption.deliveryMode = .highQualityFormat
        serialQueue.async {
            
        for (index , asset) in assets.enumerated()
        {
            autoreleasepool
            {
                let decoder = MediaDecoder()
                numOfAssets.append(index)
//                let ID = asset.localIdentifier
                let ID = String.random()
                let creationAt = asset.creationDate
                let isFavorite = asset.isFavorite
                let isHidden = asset.isHidden
                let location = asset.location
                let mediaType = decoder.mediaType(asset.mediaType)
                let mediaSubtype = decoder.mediaSubtype(asset.mediaSubtypes)
                let updateAt = asset.modificationDate
                let duration = String.stringFromTimeInterval(interval: asset.duration)
                let mediaSourceType = MediaSourceType.library

                
                if asset.mediaType == .video{
                    
                    PHImageManager.default().requestAVAsset(forVideo: asset, options: videoOption, resultHandler: { (video, audio, dic) in

                        guard let url = video as? AVURLAsset else {return}
                        
                        PHImageManager.default().requestImageData(for: asset, options: imageOptions, resultHandler: { (photoData, photoName, orientaion, dic ) in
                            let assetData = MediaAsset(id: ID, mediaType: mediaType, mediaSubtypes: mediaSubtype, sourceType: mediaSourceType, createdAt: creationAt, modificationDate: updateAt, location: location, duration: duration, isFavorite: isFavorite, isHidden: isHidden, imageDate: photoData, videoURL: url, nsfw: false)
                                self.saveAssets(assetsData: [assetData])

                        })
                    })
                }else{

                    PHImageManager.default().requestImageData(for: asset, options: imageOptions, resultHandler: { (photoData, photoName, orientaion, dic ) in
                        let assetData = MediaAsset(id: ID, mediaType: mediaType, mediaSubtypes: mediaSubtype, sourceType: mediaSourceType, createdAt: creationAt, modificationDate: updateAt, location: location, duration: duration, isFavorite: isFavorite, isHidden: isHidden, imageDate: photoData, videoURL: nil, nsfw: false)
                            self.saveAssets(assetsData: [assetData])
//                        imageAssetCollection.append(assetData)
                    })
                
            }
            }
        
        }
            self.saveAssetsDelegate?.numOfAssetToSave(num: assets.count)
            self.saveAssetsDelegate?.willStartSaveAssets()
            
        }
    }
    

    func saveFilltered(image:UIImage, photo:Asset)
    {
        let data = UIImagePNGRepresentation(image)
        let id = String.random()
        let assetData = MediaAsset(id: id, mediaType: .image, mediaSubtypes: .fillteredImage, sourceType: photo.assetsSource, createdAt: photo.createdAt, modificationDate: photo.modificationDate, location: photo.location?.cLLocation, duration: "", isFavorite: photo.isFavorite, isHidden: photo.isHidden, imageDate: data, videoURL: nil, nsfw: false)
        
        saveAssets(assetsData:[assetData])
    }
    
    
    func saveAssets(assetsData:[MediaAsset])
    {
        
        serialQueue.async
        {
            
            
            for (index , assetData) in assetsData.enumerated()
            {
                autoreleasepool
                {
                    print(index)
                    if self.shouldSave{
                    var assetData = assetData
                    guard let realm = try? Realm() else { print("cant get realm to save") ; return }
                    
                    // create image
                    let asset = self.createAsset(assetData)

                    
                    let yearTag = YearTag()
                    yearTag.tag = String.getYearDate(date: asset.createdAt!)
                    let monthTag = MonthTag()
                    monthTag.tag = String.getMonthDate(date: asset.createdAt!)
                    let dateTag = DateTag()
                    dateTag.month = monthTag
                    dateTag.year = yearTag
                    
                    asset.dateTags = dateTag
                    
                    // save encrypt image to device
                    
                    do{ try self.saveImage(assetData.imageDate!, id: assetData.id)} catch {print("cant save asset")}
                    self.saveVideo(assetData.videoURL, id: assetData.id)
                    
                    
                    // detect face
                    let imageToDetect = self.loadImageHelper.getImageWith(ID: asset.assetID, and: .animationTransition)
                    FaceDetectorVision.hasFace(image: imageToDetect!, complition:{(face) in
                        asset.hasFace = face
                    })
                    
                    let inceptionV3 = Inceptionv3().model
                    let googleNetPlaces = GoogLeNetPlaces().model
                    
                    FaceDetectorVision.getObjects(from: imageToDetect!, complition:{(nsfw) in
                        assetData.nsfw = nsfw
                        asset.nsfw = nsfw
                        if !nsfw {
                            
                            FaceDetectorVision.getObject(using: inceptionV3, data: assetData.imageDate!, threshold: 0.3, complition:{ (tags) in
                                for tag in tags{
                                    let objectTag = ObjectTag()
                                    objectTag.tag = tag
                                    asset.objectTags.append(objectTag)
                                    
                                }
                                
                            })
                            FaceDetectorVision.getObject(using: googleNetPlaces, data: assetData.imageDate!, threshold: 0.7, complition: {(tags) in
                                for tag in tags{
                                    let objectTag = ObjectTag()
                                    objectTag.tag = tag
                                    asset.objectTags.append(objectTag)

                                }
                            })
                        }else{
                            let NSFW = ObjectTag()
                            NSFW.tag = "NSFW"
                            asset.objectTags.append(NSFW)
                            let nude = ObjectTag()
                            nude.tag = "nude"
                            asset.objectTags.append(nude)
                        }

                    })

                    
                    // create sections in albums
                    
                    self.createSections(for: assetData)
                    
                    // get sections to add photo into
                    guard let sections = self.getSections(for: asset) else { return }

                    guard let dateSection = self.getDateSections(for: asset) else { return }
                    sections.append(objectsIn: dateSection)
                    

                    if let connection = self.reachability?.connection{
                    switch connection
                    {
                        case .cellular, .wifi:
                            if let location =  assetData.location { self.updateLocations(locations: asset.assetID, assetLocation: location)}
                        case .none: print("didnt find internet connection")
                    }
                    }

                    do{
                        try realm.write {
                            
                            realm.add(asset)
                            realm.add(yearTag)
                            realm.add(monthTag)
                            realm.add(dateTag)

                            
                            for section in sections
                            {
                                section.assets.append(asset)
                            }
                            self.saveAssetsDelegate?.finishSaveAsset()
                        }
                    }catch let error{
                        self.saveAssetsDelegate?.showUserAlert(title: "Sorry", message: error.localizedDescription)
                    }


                }
                }
            }
        
        }
        
        
        
    }
    
    
    func saveVideos(videos:[MediaAsset])
    {
        for videoAsset in videos
        {
            autoreleasepool{
                
            }
        }
    }
    
    
    func stop()
    {
        var shouldSave = false
    }
   
    func createAsset(_ assetData:MediaAsset) -> Asset
    {
        let asset = Asset()
        asset.assetID = assetData.id
        asset.modificationDate = assetData.modificationDate
        asset.isFavorite = assetData.isFavorite
        asset.createdAt = assetData.createdAt
        asset.mediaSubtype = assetData.mediaSubtypes
        asset.assetsSource = assetData.sourceType
        asset.isHidden = assetData.isHidden
        asset.mediaType = assetData.mediaType
        asset.duration = assetData.duration
        return asset
    }
    
    
    func saveVideo(_ aVAsset:AVURLAsset?, id:String)
    {
        guard let url  = aVAsset?.url else { return  }
        let tranasionFilePath = loadImageHelper.getDocumentsDirectory().appendingPathComponent("\(id)_video.MOV")
        do {
            let videoData = try Data(contentsOf: url)
            try videoData.write(to: tranasionFilePath)
        }catch let error
        {
            self.saveAssetsDelegate?.showUserAlert(title: "Sorry", message: error.localizedDescription)
        }
    }
    
    
    func saveImage(_ data:Data, id:String) throws
    {
        
            let keychain = KeychainSwift()
            guard let password =  keychain.get("password") else { return}
            let fullSizeImage:UIImage = UIImage(data: data)!
            
            // get factor scale for images
            
            let thumbnailScaleFactor = UIImage.getIamgeScaleSize(image: fullSizeImage, size: 3.0)
            let animationScaleFactor = UIImage.getIamgeScaleSize(image: fullSizeImage, size: 0.8)
        
            // resize images
            
            let thumbnailPhotoResized = UIImage.scaleImage(sourceImage: fullSizeImage, factor: thumbnailScaleFactor)
            let animationPhotoResized = UIImage.scaleImage(sourceImage: fullSizeImage, factor: animationScaleFactor)
        
            // convert back to data
            
            guard let thumbnailPhotoData = UIImagePNGRepresentation(thumbnailPhotoResized) else { return }
            guard let animationPhotoData = UIImagePNGRepresentation(animationPhotoResized) else { return }
        
            
            // encrypt data before save it to device
            
            let thumbnailPhotoEncryptData = RNCryptor.encrypt(data: thumbnailPhotoData, withPassword: password)
            let animationPhotoEncryptData = RNCryptor.encrypt(data: animationPhotoData, withPassword: password)
            let fullSizePhotoEncryptData = RNCryptor.encrypt(data: data, withPassword: password)
            
            
            // save
            let tranasionFilePath = loadImageHelper.getDocumentsDirectory().appendingPathComponent("\(id)_main.png")
            try? fullSizePhotoEncryptData.write(to: tranasionFilePath)
            
            let animationFilePath = loadImageHelper.getDocumentsDirectory().appendingPathComponent("\(id)_animation.png")
            try? animationPhotoEncryptData.write(to: animationFilePath)
            
            let thumbnailFilePath = loadImageHelper.getDocumentsDirectory().appendingPathComponent("\(id)_thumbnail.png")
            try? thumbnailPhotoEncryptData.write(to: thumbnailFilePath)
            
    }
    
    
    func createSections(for asset:MediaAsset)
    {
        
        // Dates

        createDateSection(asset.createdAt)

        // Albums
        
        // favorite album
        
        if asset.isFavorite { createAlbumOfType(.favorite, name: "Favorite", collectionType: .systemCollection)
            print("need to create favorite album")
        }
        
        // vidos
        
        if asset.mediaType == .video { createAlbumOfType(.video, name: "Videos", collectionType: .systemCollection)}
        
        
        // nsfw
        
        if asset.nsfw {
            print("create nude section")
            createAlbumOfType(.nsfw, name: "NSFW", collectionType: .systemCollection)
        }

        
        // special album
        switch asset.mediaSubtypes {
        case .photoDepthEffect, .photoHDR, .photoLive:
              createAlbumOfType(.specialEffect, name: "Special Effect", collectionType: .systemCollection)
        case .photoPanorama:
                createAlbumOfType(.panorama, name: "Panormas", collectionType: .systemCollection)
        case .photoScreenshot:
                createAlbumOfType(.screenShots, name: "Screen Shots", collectionType: .systemCollection)
        case .videoHighFrameRate:
            createAlbumOfType(.sloMo, name: "Slo Mo", collectionType: .systemCollection)
        case .videoTimelapse:
            createAlbumOfType(.timeLapse, name: "Time Lapse", collectionType: .systemCollection)
        default: break
        }
        
        

    }
    
    func createAlbumOfType(_ albumType:AlbumType, name:String, collectionType:CollectionType)
    {
        let realm = try! Realm()
        let appData = realm.objects(AppData.self).first?.appData.filter({$0.collectionType == collectionType})
        
        guard realm.objects(Album.self).filter("albumType == \(albumType.rawValue)").first == nil else {print("there is that kind of album already"); return}
        
        do{
            try realm.write {
                let album = Album()
                album.albumType = albumType
                album.albumName = name
                album.sectionType = SectionType(rawValue: albumType.hashValue)!
                let section = AssetCollection()
                section.sectionType = SectionType(rawValue: albumType.hashValue)!
                album.sections.append(section)
                print("create \(section.sectionType.description)")
                appData?.first?.albumCollection.append(album)
            }
        }catch let error {
            self.saveAssetsDelegate?.showUserAlert(title: "Sorry", message: error.localizedDescription)
        }

            
        
    }
    
    
    func createDateSection(_ date:Date?)
    {
        guard let date = date else {  return }
        
        let calendar = Calendar.current

        let dayComp = calendar.dateComponents([.year, .month, .day], from: date)
        let monthComp = calendar.dateComponents([.year, .month], from: date)
        let yearComp = calendar.dateComponents([.year], from: date)
        
        let realm = try! Realm()
        
        
        let dayAlbum = realm.objects(Album.self).filter("albumType == \(AlbumType.day.rawValue)").first
        let daySections = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.day.rawValue)")
        
        let monthAlbum = realm.objects(Album.self).filter("albumType == \(AlbumType.month.rawValue)").first
        let monthSections = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.month.rawValue)")
        
        let yearAlbum = realm.objects(Album.self).filter("albumType == \(AlbumType.year.rawValue)").first
        let yearSections = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.year.rawValue)")
        
        do{
            try realm.write {
                
                if !daySections.contains{(section) in section.dateComponents == dayComp}
                {
                    let daySection = AssetCollection()
                    daySection.sectionType = .day
                    daySection.createdAt = date
                    dayAlbum?.sections.append(daySection)
                }
                if !monthSections.contains{(section) -> Bool in section.dateComponents.month == monthComp.month && section.dateComponents.year == monthComp.year}
                {
                    let monthSection = AssetCollection()
                    monthSection.sectionType = .month
                    monthSection.createdAt = date
                    monthAlbum?.sections.append(monthSection)
                }
                if !yearSections.contains{(section) -> Bool in section.dateComponents.year == yearComp.year}
                {
                    let yearSection = AssetCollection()
                    yearSection.sectionType = .year
                    yearSection.createdAt = date
                    yearAlbum?.sections.append(yearSection)
                }
                
            }
        }catch let error{
            self.saveAssetsDelegate?.showUserAlert(title: "Sorry", message: error.localizedDescription)
        }
        


    }
    
    
    func getDateSections(for asset:Asset) -> List<AssetCollection>?
    {
        let realm = try! Realm()
        let sectionList:List<AssetCollection>? = List<AssetCollection>()
        let calendar = Calendar.current
        guard let date = asset.createdAt else { return nil }
        let fullDateComp = calendar.dateComponents([.year, .month, .day], from: date)
        
        
        if let daySection = realm.objects(AssetCollection.self).filter({
            $0.dateComponents.day == fullDateComp.day &&
                $0.dateComponents.month == fullDateComp.month &&
                $0.dateComponents.year == fullDateComp.year &&
                $0.sectionType == .day}).first
        {sectionList?.append(daySection)}
        
        
        if let monthSection = realm.objects(AssetCollection.self).filter({
            $0.dateComponents.month == fullDateComp.month &&
                $0.dateComponents.year == fullDateComp.year &&
                $0.sectionType == .month}).first
        {sectionList?.append(monthSection)}
        
        
        if let yearSection = realm.objects(AssetCollection.self).filter({
            $0.dateComponents.year == fullDateComp.year &&
                $0.sectionType == .year}).first
        {sectionList?.append(yearSection)}
        
        return sectionList

    }
    
    
    func getSections(for image:Asset) -> List<AssetCollection>?
    {
        let sectionList:List<AssetCollection>? = List<AssetCollection>()
        
        let realm = try! Realm()
        let calendar = Calendar.current
        guard let date = image.createdAt else { return nil }
        let fullDateComp = calendar.dateComponents([.year, .month, .day], from: date)
        
        
        if let cameraRollSection = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.cameraRoll.rawValue)").first { sectionList?.append(cameraRollSection)}
        else{ print("didnt find camera roll section")}
        
        
        if let faceSection = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.people.rawValue)").first { if image.hasFace { sectionList?.append(faceSection)} }

        if let videoSection = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.video.rawValue)").first { if image.mediaType == .video { sectionList?.append(videoSection)} }
        
        if let favoriteSection = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.favorite.rawValue)").first {
            if image.isFavorite {   sectionList?.append(favoriteSection)}}
        
        
        if let nsfwSection = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.nsfw.rawValue)").first { if image.nsfw {  sectionList?.append(nsfwSection)}
            print("image is nsfw and get section") }
        
        
        
        switch image.mediaSubtype {
        case .photoDepthEffect, .photoHDR,.photoLive :
            if let section = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.specialEffect.rawValue)").first  {sectionList?.append(section)
            }
        case .photoPanorama:
          if let section = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.panorama.rawValue)").first {sectionList?.append(section)}
        case .photoScreenshot:
          if let section = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.screenShots.rawValue)").first {sectionList?.append(section)}
        case .videoHighFrameRate:
            if let section = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.sloMo.rawValue)").first {sectionList?.append(section)}
        case .videoTimelapse:
            if let section = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.timeLapse.rawValue)").first {sectionList?.append(section)}
            
        default: break
        }
        return sectionList
    }
    
    
    func updateLocations(locations id:String, assetLocation:CLLocation)
    {
        
        var counter = 0
        let calendar = Calendar.current
        
            let imageLocation = Location()
            imageLocation.latitude = assetLocation.coordinate.latitude
            imageLocation.longitude = assetLocation.coordinate.longitude
            imageLocation.altitude = assetLocation.altitude
            imageLocation.course = assetLocation.course
            imageLocation.horizontalAccuracy = assetLocation.horizontalAccuracy
            imageLocation.verticalAccuracy = assetLocation.verticalAccuracy
            imageLocation.speed = assetLocation.speed
            imageLocation.date = assetLocation.timestamp
            
            LocationManagerHelper.getPlacemarkForAdress(location: assetLocation, resualtHendler: { (adress, placemark) in
                self.serialQueue.async {
                    counter += 1
                    let realm = try! Realm()
                    
                    let assets = realm.objects(Asset.self).filter("assetID = '\(id)'")
                    let asset = assets.first
                    
                    let fullDateComp = calendar.dateComponents([.year, .month, .day], from: (asset?.createdAt)!)
                    
                    let daySection = realm.objects(AssetCollection.self).filter({
                        $0.dateComponents.day == fullDateComp.day &&
                            $0.dateComponents.month == fullDateComp.month &&
                            $0.dateComponents.year == fullDateComp.year &&
                            $0.sectionType == .day}).first
                    
                    let monthSection = realm.objects(AssetCollection.self).filter({
                        $0.dateComponents.month == fullDateComp.month &&
                            $0.dateComponents.year == fullDateComp.year &&
                            $0.sectionType == .month}).first
                    
                    let yearSection = realm.objects(AssetCollection.self).filter({
                        $0.dateComponents.year == fullDateComp.year &&
                            $0.sectionType == .year}).first
                    
                    
                    
                    let placeMarkcountry:String? = placemark?.country
                    
                    
                    // Do something with the placemark
                    do{
                        try realm.write {
                            
                            let placesAlbum = realm.objects(Album.self).filter("albumType == \(AlbumType.places.rawValue)").first
                            let placesSections = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.places.rawValue)")
                            
                            var placeSection = placesSections.filter({$0.location?.country == placeMarkcountry}).first
                            if !placesSections.contains{(section) -> Bool in section.location?.country == placeMarkcountry}
                            {
                                placeSection = AssetCollection()
                                placeSection?.sectionType = .places
                                placesAlbum?.sections.append(placeSection!)
                            }
                            
                            placeSection?.assets.append(asset!)
                            imageLocation.city = placemark?.city
                            imageLocation.country = placemark?.country
                            if let city = placemark?.city, let addres = adress{
                                imageLocation.adress = "\(addres), \(city)"
                            }else if let add = adress
                            {
                                imageLocation.adress = add
                            }
                            daySection?.location = imageLocation
                            monthSection?.location = imageLocation
                            yearSection?.location = imageLocation
                            asset?.location = imageLocation
                            placeSection?.location = imageLocation
                            realm.add(imageLocation)
                            realm.add(placeSection!)
                            
                        }
                    }catch let error
                    {
                        self.saveAssetsDelegate?.showUserAlert(title: "Sorry", message: error.localizedDescription)
                    }

                    
                }
                
            })
        
        
        
    }
    
    
enum Resualt {
    case image(MediaAsset)
    case movie(MediaAsset)
}
    
}

struct MediaDecoder {
    func mediaSubtype(_ type:PHAssetMediaSubtype) -> MediaSubtype
    {
        switch type {
        case PHAssetMediaSubtype.photoHDR: return MediaSubtype.photoHDR
        case PHAssetMediaSubtype.photoLive: return MediaSubtype.photoLive
        case PHAssetMediaSubtype.photoPanorama: return MediaSubtype.photoPanorama
        case PHAssetMediaSubtype.photoScreenshot: return MediaSubtype.photoScreenshot
        case PHAssetMediaSubtype.videoHighFrameRate: return MediaSubtype.videoHighFrameRate
        case PHAssetMediaSubtype.videoStreamed: return MediaSubtype.videoStreamed
        case PHAssetMediaSubtype.videoTimelapse: return MediaSubtype.videoTimelapse
        default: return MediaSubtype.normal
        }
    }
    
    func mediaType(_ type:PHAssetMediaType) -> MediaType
    {
        switch type {
        case .image: return MediaType.image
        case .video: return MediaType.video
        case .audio: return MediaType.audio
        default: return MediaType.unknown
        }
    }
}

struct MediaAsset {
    
    var id:String
    var mediaType: MediaType
    var mediaSubtypes: MediaSubtype
    var sourceType: MediaSourceType
    var createdAt:Date?
    var modificationDate: Date?
    var location: CLLocation?
    var duration: String
    var isFavorite: Bool
    var isHidden: Bool
    var imageDate:Data?
    var videoURL:AVURLAsset?
    var nsfw:Bool
    
    
}



