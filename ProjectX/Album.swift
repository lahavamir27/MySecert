//
//  Album.swift
//  MySecret
//
//  Created by amir lahav on 28.8.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class Album: Object {
    
    dynamic var albumName:String? = nil
    dynamic var createdAt = Date()
    dynamic var sectionType: SectionType = .unknown
    dynamic var albumType: AlbumType = .unknown
    var sections = List<AssetCollection>()
    var loadImageHelper = LoadImageHelper()

//    var numberOfItemsInAlbum

}

//// kind of viewModel

extension Album
{
    
    
    var numberOfSections:Int { return sections.count }
    
    var isLastPhoto:Bool { return numberPhotosInAlbum() == 1}
    
    var isEmptyAlbum:Bool { return numberPhotosInAlbum() == 0 }
    
    var isUserAlbum:Bool { return !getSystemAlbum().contains(self.albumType)}
    
    var isMultypleSection:Bool { return getMultipleSectionAlbumType().contains(self.albumType)}
    
    var needHeader:Bool { return getMultipleSectionAlbumType().contains(self.albumType)}
    
    func getMultipleSectionAlbumType() -> [AlbumType]
    {
        return [.day, .month, .year, .places]
    }
    
    func getMandatorySystemAlbum() -> [AlbumType]
    {
        return [.cameraRoll, .people, .places, .recentlyDeleted]
    }
    
    func getMandatorySystemCollection() -> [SectionType]
    {
        return [.cameraRoll, .people, .places, .recentlyDeleted, .search, .userAlbum]
    }
    
    func getSystemAlbum() -> [AlbumType]
    {
        return [.day, .month, .year,.cameraRoll, .places, .people, .favorite, .editedPhoto, .search, .nsfw, .video]
    }
    
    func numberOfPhotos(in section:Int) -> Int { return getSortedListOfSection()[section].assets.count }
    
    func getSortedListOfSection() -> Results<AssetCollection>
    {
        return sections.sorted(byKeyPath: "createdAt", ascending: true)
    }
    
    func getCell(at indexPath:IndexPath) -> CellData
    {
        var asset:Asset? = getSortedListOfSection()[indexPath.section].assets[indexPath.item]
        let cellData = CellData(photoId: (asset?.assetID)!, isFavorite: (asset?.isFavorite)!,mediaAsset: asset?.mediaType, duration: asset?.duration)
        asset = nil
        return cellData
    }
    
    func updateFavoritePhoto(indexPath:IndexPath)
    {
        do {
            let realm = try Realm()
            let cellData = getCell(at: indexPath)
            var asset:Asset? = getSortedListOfSection()[indexPath.section].assets[indexPath.item]
            try realm.write{
                asset!.isFavorite = !cellData.isFavorite
            }
            if !cellData.isFavorite {
                AlbumMenagerHelper.add(assets: [asset!], to: .favorite, name: "Favorite", collectionType: .systemCollection)
            }
            asset = nil
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    func numberPhotosInAlbum() -> Int
    {
        var numberOfPhotos:Int = 0
        for section in sections{
            numberOfPhotos += section.numOfPhotosInSection
        }
        return numberOfPhotos
    }
    
    func getImageToEdit(at indexPath:IndexPath) -> ImageToEdit
    {
        let id = getSortedListOfSection()[indexPath.section].assets[indexPath.item].assetID
        let image = loadImageHelper.getImageWith(ID: id, and: .fullSize)
        return ImageToEdit(photoId: id, image: image!)
    }
    
    func getPhotoTitleData(at indexPath:IndexPath) -> NCTitleData
    {
        var asset:Asset? = getSortedListOfSection()[indexPath.section].assets[indexPath.item]
        let data = NCTitleData(adress: asset?.location?.adress, date: (asset?.createdAt)!)
        asset = nil
        return data
    }
        
    func getAlbumCover(with albumType:AlbumType) -> UIImage?
    {
            return getFirstPhotoIamge()
    }
    
    func getFirstPhotoIamge() -> UIImage?
    {
        
        if let id = getSortedListOfSection().first?.assets.first?.assetID{
            if !isEmptyAlbum { return loadImageHelper.getImageWith(ID: id, and: .animationTransition) }
        }
        return nil
    }
    
    func getPhoto(at index:Int) -> UIImage?
    {
        if let id = getSortedListOfSection().first?.assets[safe: index]?.assetID{
            if !isEmptyAlbum { return loadImageHelper.getImageWith(ID: id, and: .animationTransition) }
        }
        return nil
    }
    func getAlbumLocation() -> CLLocationCoordinate2D?
    {
        if !isEmptyAlbum {
            return sections[0].assets[0].location?.coordinate
        }
        return nil
    }
    
    func getAssets(at indexs:[IndexPath]) -> [Asset]?
    {
        var assets = [Asset]()
        for index in indexs
        {
            var asset:Asset? = getSortedListOfSection()[index.section].assets[index.item]
            assets.append(asset!)
            asset = nil
        }
        return assets
    }
    
    func removeEmptySections()
    {
        for section in sections
        {
            if section.assets.count == 0{
            if !getMandatorySystemCollection().contains(section.sectionType) && section.assets.isEmpty {
            
                    do{
                        let realm = try Realm()
                        try realm.write {
                            print("delete section \(section.sectionType.description)")
                            realm.delete(section)
                        }
                    }catch let error as NSError{
                        print("cant delete sections \(error)")
                    }
                
                }
            }
        }
    }
}

struct CellData {
    var photoId:String
    var isFavorite:Bool
    var assetType:MediaType?
    var assetDuration:String?
    
    init(photoId:String, isFavorite:Bool, mediaAsset:MediaType? = nil, duration:String?) {
        self.photoId = photoId
        self.isFavorite = isFavorite
        self.assetType = mediaAsset
        self.assetDuration = duration
    }
}

struct ImageToEdit
{
    var photoId:String
    var image:UIImage

    init(photoId:String, image:UIImage) {
        self.photoId = photoId
        self.image = image
    }
}

struct collectionViewData {
    var numberOfSections:Int
}

@objc enum AlbumType:Int, CustomStringConvertible
{
    case cameraRoll
    case favorite
    case people
    case places
    case selfie
    case video
    case unknown
    case userAlbum
    case year
    case month
    case day
    case editedPhoto
    case sloMo
    case timeLapse
    case screenShots
    case specialEffect
    case panorama
    case search
    case nsfw
    case recentlyDeleted

    
    var description:String {
        switch self {
        case .cameraRoll: return "cameraRoll"
        case .favorite: return "favorite"
        case .people: return "people"
        case .places: return "places"
        case .recentlyDeleted: return "recentlyDeleted"
        case .selfie: return "selfie"
        case .video: return "video"
        case .unknown: return "unknown"
        case .userAlbum: return "userAlbum"
        case .year: return "year"
        case .month: return "month"
        case .day: return "day"
        case .editedPhoto: return "editedPhoto"
        case .sloMo: return "sloMo"
        case .timeLapse: return "timeLapse"
        case .screenShots: return "screenShots"
        case .specialEffect: return "specialEffect"
        case .panorama: return "panorama"
        case .search: return "search"
        case .nsfw: return "nsfw"

        }
    }
    
}

struct AlbumTypeName {
    static func getNameFrom(type: AlbumType) ->String
    {
        switch type {
        case .cameraRoll:
            return "All Photos"
        case .favorite:
            return "Favorite"
        case .people:
            return "People"
        case .places:
            return "Place"
        default:
            return ""
        }
    }
}
