//
//  SaveIamgeToRealm.swift
//  PhotoViewer
//
//  Created by amir lahav on 18.11.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit
import CoreLocation
import Photos
import RNCryptor



protocol SaveImageProtocol:class {
    func finishSaveImages()
    func startSaveImages()
    func startSaveEditImages()
    func finishSaveEditImages()
    func updateProgress(progress: Float)
    func encryptPhotos()
    func faceDetectiong()
    func gettingLoactinos()
}

extension SaveImageProtocol{
    
    func finishSaveImages(){}
    func startSaveImages(){}
    func updateProgress(progress: Float){}
    func encryptPhotos(){}
    func faceDetectiong(){}
    func gettingLoactinos(){}
    func startSaveEditImages(){}
    func finishSaveEditImages(){}
    
}





class SaveImageToRealm: NSObject {
    
    
    typealias imagesToSaveType = (id:String, fullSizePhotoData:Data, animationImageData:Data, thumbnail:UIImage)
    typealias photoToSaveType = (id:String, creationDate:Date, isFavorite: Bool, thumbnail:UIImage?)
    
     static fileprivate var loadImageHelper = LoadImageHelper()

    
    fileprivate var loadImageHelper = LoadImageHelper()

    typealias CompletionHandler = (_ success:Bool) -> Void
    static weak var delegate: SaveImageProtocol?
    static fileprivate var serialQueue = DispatchQueue(label: "com.queue.Serial", qos: .utility)
    
    static func saveAssestsToRealm(assests:[PHAsset]?,complition : @escaping CompletionHandler)
    {
        if let assetsCollection = assests
        {
            getAssetsToSave(assets: assetsCollection)
            complition(true)
        }

    }
    
    static func saveEditedPhoto(photo:Asset, image:UIImage)
    {
        if let delegate = self.delegate
        {
            delegate.startSaveEditImages()
        }
        
        let ID = String.random()
        let creationDate = photo.createdAt
        let isFavorite = photo.isFavorite
        let imageData = UIImagePNGRepresentation(image)
        
        let imageToSave:imagesToSaveType = (ID, imageData!, imageData!, image)
        let photoToSave:photoToSaveType = (ID, creationDate!, isFavorite, image)
        self.addDaysToRealm(dates: [creationDate!])
        self.imagesToSave(images: [imageToSave])
        self.savePhotoToRealm(photos: [photoToSave], shouldStop: true)
    }
    
  
    static func getAssetsToSave(assets: [PHAsset])
    {
        
            if let delegate = self.delegate
            {
                    delegate.startSaveImages()
            }
        
            var photoDates = [Date]()
            var imagesToSave = [(id:String, fullSizePhotoData:Data, animationImageData:Data, thumbnail:UIImage)]()
            var realmPhotos = [(id:String, creationDate:Date, isFavorite: Bool, thumbnail:UIImage?)]()
            var photosLocation = [(id:String, photoLocation:CLLocation)]()
            var shouldStop = true

            let options = PHImageRequestOptions()
            options.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
            options.version = PHImageRequestOptionsVersion.current
            options.isSynchronous = true
            options.isNetworkAccessAllowed = true
        
            for (index , asset) in assets.enumerated()
            {
                serialQueue.async {
                    
                let ID = String.random()
                let creationDate = asset.creationDate
                let isFavorite = asset.isFavorite
                photoDates.append(creationDate!)

                PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: { (photoData, photoName, orin, dic) in
                    
                    

                    
                    
                    
                    PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 256, height:256), contentMode: .aspectFill , options: options, resultHandler: { (thumbnailImage,dic) in
                        
                        let assetImage = (id:ID, fullSizePhotoData:photoData!, animationImageData:photoData!, thumbnail:thumbnailImage!)
                        imagesToSave.append(assetImage)
                        let photoRealm = (id:ID, creationDate: creationDate!, isFavorite: isFavorite , thumbnail: thumbnailImage)
                        realmPhotos.append(photoRealm)

                        
                        if let location = asset.location
                        {
                            let photoLocation = (id:ID, photoLocation:location)
                            photosLocation.append(photoLocation)
                        }
                        
                        if photosLocation.count > 0
                        {
                            shouldStop = false
                        }
                        
                    })
                })
                    
                    
                if index == assets.count - 1
                {
                    DispatchQueue.main.async {
                        if Thread.isMainThread{
                            self.addDaysToRealm(dates: photoDates)
                            self.imagesToSave(images: imagesToSave)
                            self.savePhotoToRealm(photos: realmPhotos, shouldStop: shouldStop)
                            self.updateLocations(locations: photosLocation)
                        }else{
                        }
                    }
                }
                

                
        }
        
    }


    }
    
    // create dates in realm database
    
    private static func addDaysToRealm(dates: [Date])
    {

        for (index, date) in dates.enumerated()
        
        {
            serialQueue.async {
                autoreleasepool{
            
            let realm = try! Realm()
            let creationDate = date
            let calendar = Calendar.current
            let dayComp = calendar.dateComponents([.year, .month, .day], from: creationDate)
            let monthComp = calendar.dateComponents([.year, .month], from: creationDate)
                    
            
            let dayAlbum = realm.objects(Album.self).filter("albumType == \(AlbumType.day.rawValue)").first
            let daySections = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.day.rawValue)")
            

                    
            let monthAlbum = realm.objects(Album.self).filter("albumType == \(AlbumType.month.rawValue)").first
            let monthSections = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.month.rawValue)")


                    
            let yearAlbum = realm.objects(Album.self).filter("albumType == \(AlbumType.year.rawValue)").first
            let yearSections = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.year.rawValue)")
                    

                    try! realm.write {

                    if !daySections.contains{(section) -> Bool in section.dateComponents == dayComp}
                    {
                        let daySection = AssetCollection()
                        daySection.sectionType = .day
                        daySection.createdAt = creationDate
                        dayAlbum?.sections.append(daySection)
                    }
                    if !monthSections.contains{(section) -> Bool in section.dateComponents.month == monthComp.month && section.dateComponents.year == monthComp.year}
                    {
                        let monthSection = AssetCollection()
                        monthSection.sectionType = .month
                        monthSection.createdAt = creationDate
                        monthAlbum?.sections.append(monthSection)
                    }
                    if !yearSections.contains{(section) -> Bool in section.dateComponents.year == monthComp.year}
                    {
                        let yearSection = AssetCollection()
                        yearSection.sectionType = .year
                        yearSection.createdAt = creationDate
                        yearAlbum?.sections.append(yearSection)
                    }
                        
                        
                    }
        
            }
            }
        }

    }
    
    private static func imagesToSave(images:[(id:String, fullSizePhotoData:Data, animationImageData:Data, thumbnail:UIImage)])
        {
        
            let password = "password"
            
            for (index,image) in images.enumerated(){
                
                serialQueue.async {
                    autoreleasepool{

                        
                    let fullSizeImage:UIImage = UIImage(data: image.fullSizePhotoData)!
                    
                    // get factor scale for images
                        
                    let thumbnailScaleFactor = UIImage.getIamgeScaleSize(image: fullSizeImage, size: 3.0)
                    let animationScaleFactor = UIImage.getIamgeScaleSize(image: fullSizeImage, size: 1.2)
                    let fullSizeScaleFactor = UIImage.getIamgeScaleSize(image: fullSizeImage, size: 0.7)

                    // resize images

                    let thumbnailPhotoResized = UIImage.scaleImage(sourceImage: fullSizeImage, factor: thumbnailScaleFactor)
                    let animationPhotoResized = UIImage.scaleImage(sourceImage: fullSizeImage, factor: animationScaleFactor)
                    let fullSizePhotoResized = UIImage.scaleImage(sourceImage: fullSizeImage, factor: fullSizeScaleFactor)
                        
                    // convert back to data

                    let thumbnailPhotoData = UIImagePNGRepresentation(thumbnailPhotoResized)
                    let animationPhotoData = UIImagePNGRepresentation(animationPhotoResized)
                    let fullSizePhotoData = UIImagePNGRepresentation(fullSizePhotoResized)

                        
                    // encrypt data before save it to device

                    let thumbnailPhotoEncryptData = RNCryptor.encrypt(data: thumbnailPhotoData!, withPassword: password)
                    let animationPhotoEncryptData = RNCryptor.encrypt(data: animationPhotoData!, withPassword: password)
                    let fullSizePhotoEncryptData = RNCryptor.encrypt(data: fullSizePhotoData!, withPassword: password)


                    //
                    let tranasionFilePath = loadImageHelper.getDocumentsDirectory().appendingPathComponent("\(image.id)_main.png")
                    try? fullSizePhotoEncryptData.write(to: tranasionFilePath)
                    
                    let animationFilePath = loadImageHelper.getDocumentsDirectory().appendingPathComponent("\(image.id)_animation.png")
                    try? animationPhotoEncryptData.write(to: animationFilePath)
                    
                    let thumbnailFilePath = loadImageHelper.getDocumentsDirectory().appendingPathComponent("\(image.id)_thumbnail.png")
                    try? thumbnailPhotoEncryptData.write(to: thumbnailFilePath)
            
                    DispatchQueue.main.async {
                        

                    }
                        
                    if index == images.count - 1
                    {
                        DispatchQueue.main.async {
                            
                            if let delegate = self.delegate {
                                delegate.faceDetectiong()
                            }
                        }
                        
                    }

                    }
                }
            }

    }

    
    private static func savePhotoToRealm(photos: [(id:String, creationDate:Date, isFavorite: Bool, thumbnail:UIImage?)], shouldStop: Bool)
    {
        
        for (index,photoRealm) in photos.enumerated()
            
        {
            serialQueue.async {
                autoreleasepool{
                
                let realm = try! Realm()
                let calendar = Calendar.current
                    
                let faceDetector = FaceDetector()
                let hasFace:Bool = faceDetector.hasFace(image: photoRealm.thumbnail!)
                let fullDateComp = calendar.dateComponents([.year, .month, .day], from: photoRealm.creationDate)

                let favoriteAlbum = realm.objects(Album.self).filter("albumType == \(AlbumType.favorite.rawValue)").first
                if favoriteAlbum == nil && photoRealm.isFavorite {
                        createAlbumOfType(.favorite, name: "Favorite", collectionType: .systemCollection)
                }
                    
                let cameraRollSection = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.cameraRoll.rawValue)").first
                let faceSection = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.people.rawValue)").first
                let favoriteSection = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.favorite.rawValue)").first
                
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
                    
                    


                

                    
                    
                    
                let photo = Asset()
                photo.assetID = photoRealm.id
                photo.assetsSource = .library
                photo.createdAt = photoRealm.creationDate
                photo.isFavorite = photoRealm.isFavorite
                photo.hasFace = hasFace
                


                            try! realm.write ({
                                
                                realm.add(photo)
                                daySection?.assets.append(photo)
                                monthSection?.assets.append(photo)
                                yearSection?.assets.append(photo)
                                cameraRollSection?.assets.append(photo)
                                
                                
                                if hasFace
                                {
                                    faceSection?.assets.append(photo)
                                }
                                
                                if photoRealm.isFavorite
                                {
                                    favoriteSection?.assets.append(photo)
                                }
                            })
                    
                    

                
                if index == photos.count-1 && shouldStop
                {
                    DispatchQueue.main.async {
                        delegate?.finishSaveImages()
                        delegate?.finishSaveEditImages()
                    }
                }else if index == photos.count-1 && !shouldStop
                {
                    DispatchQueue.main.async {
                        delegate?.gettingLoactinos()
                    }
                }
                }
            }
        }
    }
    
    private static func updateLocations(locations: [(id:String, photoLocation:CLLocation)])
    {
        
        var counter = 0
        let calendar = Calendar.current
        for (index, location) in locations.enumerated()
        
        {
                let imageLocation = Location()
                    imageLocation.latitude = location.photoLocation.coordinate.latitude
                    imageLocation.longitude = location.photoLocation.coordinate.longitude
                    imageLocation.altitude = location.photoLocation.altitude
                    imageLocation.course = location.photoLocation.course
                    imageLocation.horizontalAccuracy = location.photoLocation.horizontalAccuracy
                    imageLocation.verticalAccuracy = location.photoLocation.verticalAccuracy
                    imageLocation.speed = location.photoLocation.speed
                    imageLocation.date = location.photoLocation.timestamp
            
                    LocationManagerHelper.getPlacemarkForAdress(location: location.photoLocation, resualtHendler: { (adress, placemark) in
                            serialQueue.async {
                                counter += 1
                                let realm = try! Realm()
                                
                                let assets = realm.objects(Asset.self).filter("assetID = '\(location.id)'")
                                let photo = assets.first
                                
                                let fullDateComp = calendar.dateComponents([.year, .month, .day], from: (photo?.createdAt)!)
                                
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
                                            try! realm.write {
                                                
                                                let placesAlbum = realm.objects(Album.self).filter("albumType == \(AlbumType.places.rawValue)").first
                                                let placesSections = realm.objects(AssetCollection.self).filter("sectionType == \(SectionType.places.rawValue)")
                                                
                                                var placeSection = placesSections.filter({$0.location?.country == placeMarkcountry}).first
                                                if !placesSections.contains{(section) -> Bool in section.location?.country == placeMarkcountry}
                                                {
                                                    placeSection = AssetCollection()
                                                    placeSection?.sectionType = .places
                                                    placesAlbum?.sections.append(placeSection!)
                                                }

                                                placeSection?.assets.append(photo!)
                                                imageLocation.city = placemark?.city
                                                imageLocation.country = placemark?.country
                                                imageLocation.adress = adress!
                                                daySection?.location = imageLocation
                                                monthSection?.location = imageLocation
                                                yearSection?.location = imageLocation
                                                photo?.location = imageLocation
                                                placeSection?.location = imageLocation
                                                realm.add(imageLocation)
                                                realm.add(placeSection!)
                                            }
                                

                                if counter == locations.count
                                {
                                    
                                    DispatchQueue.main.async {
                                        delegate?.finishSaveImages()
                                    }
                                }

                            }

                        })
                }
        
        
            }
    
    static func isEqualString(lhs:String, rhs:String) -> Bool
    {
        return lhs == rhs
    }
    
    static func createAlbumOfType(_ albumType:AlbumType, name:String, collectionType:CollectionType)
    {
        let realm = try! Realm()
        let appData = realm.objects(AppData.self).first?.appData.filter({$0.collectionType == collectionType})
       
        try! realm.write {
            let album = Album()
            album.albumType = albumType
            album.albumName = name
            album.sectionType = SectionType(rawValue: albumType.hashValue)!
            let section = AssetCollection()
            section.sectionType = SectionType(rawValue: albumType.hashValue)!
            album.sections.append(section)
            appData?.first?.albumCollection.append(album)
        }
        
    }

}

