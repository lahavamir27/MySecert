//
//  MainGridModelView.swift
//  MySecret
//
//  Created by amir lahav on 24.8.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit


final class FetchDataHelper

{
    static let realm = try! Realm()
    
    static func getNumberOfSections(album:Album) -> Int
    {
        let resualt = getSectionData(album: album)
        return resualt.count
    }
    
    static func numberOfItemAtSection(section: Int, album:Album) -> Int
    {
        let resualt = getSectionData(album: album)
        return (resualt[section].assets.count)
    }
    
    static func getSectionData(album:Album) -> Results<AssetCollection>
    {
        let albumName:String = album.albumName!
        let sections = realm.objects(Album.self).filter("albumName == '\(albumName)'").first?.sections.sorted(byKeyPath: "createdAt", ascending: true)
        return sections!
        
    }
    
    class func getAlbumData() -> Results<Day>
    {
        return realm.objects(Day.self).sorted(byKeyPath: "date", ascending: true)
    }
    
    class func getPhotoIDfor(indexPath:IndexPath, album:Album)-> String
    {
        let resualt = getSectionData(album: album)
        return (resualt[indexPath.section].assets[indexPath.row].assetID)
    }
    
    class func getPhotosFavorite(indexPath:IndexPath, album:Album) -> Bool
    {
        let resualt = getSectionData(album: album)
        return (resualt[indexPath.section].assets[indexPath.row].isFavorite)
    }
    
    class func getPhoto(indexPath:IndexPath,album:Album) -> Asset
    {
        let resualt = getSectionData(album: album)
        return (resualt[indexPath.section].assets[indexPath.row])
    }
    
    class func getSectionCreationDate(indexPath:IndexPath,album:Album) -> Date
    {
        let resualt = getSectionData(album: album)
        return resualt[indexPath.section].createdAt
    }
    
    class func getSectionAdress(indexPath:IndexPath,album:Album) -> String?
    {
        let resualt = getSectionData(album: album)
        return resualt[indexPath.section].location?.adress
    }
    
    
    class func getSectionAdressCountry(indexPath:IndexPath,album:Album) -> String?
    {
        let resualt = getSectionData(album: album)
        return resualt[indexPath.section].location?.country
    }
    
    class func getNumberOfPhotos() -> Int
    {
        return realm.objects(Asset.self).count
    }
    
    class func updateFavoriteAsset(at indexPath:IndexPath, album:Album)
    {
        let isFavorite = getPhotosFavorite(indexPath:indexPath, album: album)
        try! realm.write{
        let photo = getPhoto(indexPath:indexPath, album: album)
            photo.isFavorite = !isFavorite
        }
    }
    
    
    class func getPhotoFromID(id:String) -> Asset
    {
        let pred = NSPredicate(format: "assetID = '\(id)'")
        return realm.objects(Asset.self).filter(pred).first!
    }
    
    class func needHeader(album:Album)-> Bool {
        switch album.sectionType {
        case .people, .favorite, .cameraRoll, .editedPhoto, .userAlbum, .unknown:
            return false
        default:
            return true
        }

    }
    
    

}
