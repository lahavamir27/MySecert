//
//  PhotoModelController.swift
//  ProjectX
//
//  Created by amir lahav on 5.10.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift
import Cache
import Photos




struct PhotoModelController: ViewModelProtocol {
    
    var albumName:String
    fileprivate var loadImageHelper = LoadImageHelper()

    var albumType:AlbumType {
        guard let realm = try? Realm() else { return .day }
        guard let albumType = realm.objects(Album.self).filter("albumName == '\(albumName)'").first?.albumType else {
            return .day
        }
        return albumType
    }
        
    var album:Album {
        guard let realm = try? Realm() else { return Album() }
        guard let album = realm.objects(Album.self).filter("albumName == '\(albumName)'").first else {
            return Album()
        }
        return album
    }
    
    init(albumName:String) {
        self.albumName = albumName
    }
    
    fileprivate let cache = HybridCache(name: "Mix")
    fileprivate let detailCache = HybridCache(name: "Detail")

    
    func getSortedListOfSection() -> Results<AssetCollection>
    {
        return album.getSortedListOfSection()
    }
    
//    NCTitle
//    title:String
//    subTitle:String?
    
    func getPhotoTitleData(at indexPath:IndexPath) -> NCTitleData
    {
        return album.getPhotoTitleData(at: indexPath)
    }
    func getAssetID(at indexPath:IndexPath) -> String?
    {
        let data = album.getCell(at: indexPath)
        return data.photoId
    }
    
    func getImage(at: IndexPath, imageSize: ImageSizeExtention) -> UIImage?
    {
        let data = album.getCell(at: at)
        return loadImageHelper.getImageWith(ID: data.photoId, and: imageSize)
    }
    func getAssetMediaType(at indexPath:IndexPath) -> MediaType?
    {
        let sortedSection = getSortedListOfSection()
        return sortedSection[indexPath.section].assets[indexPath.item].mediaType
    }
    
    func getImageToEdit(at indexPath:IndexPath) -> ImageToEdit
    {
        let id = album.getSortedListOfSection()[indexPath.section].assets[indexPath.item].assetID
        let image = loadImageHelper.getImageWith(ID: id, and: .animationTransition)
        return ImageToEdit(photoId: id, image: image!)
    }
    
    func updateFavoriteAsset(at indexPath:IndexPath)
    {
        guard let realm = try? Realm() else {return}
        let cellData = getCellData(at: indexPath)
        var asset:Asset? = album.getSortedListOfSection()[indexPath.section].assets[indexPath.item]
        try! realm.write{
            asset!.isFavorite = !cellData.isFavorite
        }
        if !cellData.isFavorite {
            AlbumMenagerHelper.add(assets: [asset!], to: .favorite, name: "Favorite", collectionType: .systemCollection)
        }else{
            print(indexPath)
        }
        asset = nil
    }
    
    
    func getAlbumName(at indexPath:IndexPath) -> String?
    {
        guard let realm = try? Realm() else {return nil}
        guard let appData = realm.objects(AppData.self).first else {return nil}
        return appData.getAlbumName(at: indexPath)
    }
    
    func add(assets atIndexs:[IndexPath], from:String, to albumName:String)
    {
        let realm = try! Realm()
        let album = realm.objects(Album.self).filter("albumName == '\(from)'").first!
        if let assets = album.getAssets(at: atIndexs) {
        
            AlbumMenagerHelper.add(assets: assets, to: .userAlbum, name: albumName, collectionType: .userCollection)
        }
    }
    
    func isNotSafe(at indexPath:IndexPath) -> Bool
    {
        let asset = album.getAssets(at: [indexPath])
        return (asset?.first?.nsfw)!
    }
    
    func removeUnFavoriteAsstes()
    {
        guard let realm = try? Realm() else {return}

        if album.albumType == .favorite{
            for asset in (album.sections.first?.assets)!{
                if asset.isFavorite == false{
                
                    guard let index = album.sections.first?.assets.index(of: asset) else { return }
                    
                    do{
                        try realm.write {
                            album.sections.first?.assets.remove(objectAtIndex: index)
                        }
                    }catch let error{
                        print("cant remove asset at index: \(index)", error)
                    }
                    
                }
            }
        }
    }
    
    func getHeader(for section:Int) -> (title:String?,subtitle:String? ,size:HeaderSize)
    {
        let section =  self.getSortedListOfSection()[section]
        let creationDate = section.createdAt
        let country = section.location?.country
        let address = section.location?.adress
        let convertedDate = String.getDate(date: creationDate, sectionType:section.sectionType)
        switch albumType {
        case .places: return(country, nil, .normal)
        case .day:
            if country != nil
            {
                return(address, String.getHeaderSubtitle(date:convertedDate, country:country!), .extended)
            }else{
                return(convertedDate, nil, .normal)
            }
        case .month, .year:
            return(convertedDate, nil, .normal)
        default:
            return(convertedDate, nil, .normal)
        }
        
    }
    
    func checkPhotoLibraryPermission(complition:@escaping (Bool)->())  {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: complition(true)
        case .denied, .restricted : complition(false)
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized: DispatchQueue.main.async {
                    complition(true)
                    }
                // as above
                case .denied, .restricted: complition(false)
                // as above
                case .notDetermined: complition(false)
                    // won't happen but still
                }
            }
        }
    }
    
    
    func getImage(id:String,imageSize:ImageSizeExtention, handler:@escaping (UIImage, String)->())
    {
        switch imageSize {
        case .animationTransition, .fullSize:
            
            let image:UIImage? = detailCache.object(forKey: id)
            if let imageFetch = image
            {
                handler(imageFetch,id)
            }else{
                DispatchQueue.global().async { _ in
                    if let image = self.loadImageHelper.getImageWith(ID: id, and: imageSize){
                        self.detailCache.async.addObject(image, forKey: id) { error in
                            DispatchQueue.main.async {
                                handler(image,id)
                            }
                        }
                    }
                }
            }
        default:
            let image:UIImage? = cache.object(forKey: id)
            if let imageFetch = image
            {
                handler(imageFetch,id)
            }else{
                DispatchQueue.global().async { _ in
                    if let image = self.loadImageHelper.getImageWith(ID: id, and: imageSize){
                        self.cache.async.addObject(image, forKey: id) { error in
                            DispatchQueue.main.async {
                                handler(image,id)
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
}

enum Role
{
    case normal
    case search
}
enum HeaderSize
{
    case normal
    case extended
}

protocol ExportImageProtocol:class {
    func result(_ resualt:Resualt)
}

final class ExportImage:NSObject {
    
    var delegate:ExportImageProtocol?
    
    func export(image:UIImage)
    {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    func exportVideo(atPath:String){
        UISaveVideoAtPathToSavedPhotosAlbum(atPath, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
            // we got back an error!
            delegate?.result(Resualt.error(error: error))
        } else {
            delegate?.result(Resualt.success)
        }
    }
    deinit {
        print("image exporter deinit")
    }
}

enum Resualt {
    case success
    case error(error:Error)
}

struct PushAlbumData {
    
    let albumName:String?
    let tabType:TabType?
    let albumType:AlbumType?
    let gridState:AppState?
    let promptName:String?
    
    init(albumName:String? = nil, tabType:TabType? = nil, albumType:AlbumType? = nil, gridState:AppState? = nil, promptName:String? = nil) {
        self.albumName = albumName
        self.tabType = tabType
        self.albumType = albumType
        self.gridState = gridState
        self.promptName = promptName
    }
}





