//
//  AppData.swift
//  ProjectX
//
//  Created by amir lahav on 17.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class AppData: Object {

    
    var appData = List<AlbumCollection>()

    
}


////// Getters

extension AppData
{
    typealias complitionHandelr = (Bool)->()
    func numberOfItems(in section:Int) -> Int { return appData[section].albumCollection.count }

    func getAlbumName(at indexPath:IndexPath) -> String?
    {
        return appData[indexPath.section].sortedAlbumCollection[indexPath.item].albumName
    }
    
    func getAlbumType(at indexPath:IndexPath) -> AlbumType?
    {
        return appData[indexPath.section].sortedAlbumCollection[indexPath.item].albumType
    }
    
    
    func getNumberOfPhotos(at indexPath:IndexPath) -> String?
    {
        return "\(appData[indexPath.section].sortedAlbumCollection[indexPath.item].numberPhotosInAlbum())"
    }
    func getNumberOfUserAlbums() -> Int {

        return (appData.filter({$0.collectionType == .userCollection}).first?.albumCollection.count)!
    }
    
    func getUserAlbum(with userAlbum:String) -> Album?
    {
        return appData.filter({$0.collectionType == .userCollection}).first?.albumCollection.filter("albumName == '\(userAlbum)'").first
    }
    
    func isUserAlbumExist(with albumName:String) -> Bool
    {
        return getUserAlbum(with: albumName) != nil
    }
    
    func getAlbumCover(at indexPath: IndexPath) -> UIImage?
    {
        var album:Album? = appData[indexPath.section].sortedAlbumCollection[indexPath.item]
        let image:UIImage? = album?.getAlbumCover(with: (album?.albumType)!)
        album = nil
        return image
    }
    func isEmptyAlbum(at indexPath:IndexPath) -> Bool
    {
        var album:Album? = appData[indexPath.section].sortedAlbumCollection[indexPath.item]
        let isEmpty:Bool = (album?.isEmptyAlbum)!
        album = nil
        return isEmpty
        
    }
    
    func getAlbumFirstPhotoLocation(at indexPath:IndexPath) -> CLLocationCoordinate2D?
    {
        let loaction = appData[indexPath.section].sortedAlbumCollection[indexPath.item].getAlbumLocation()
        return loaction
    }
    
    
    func isAlbumTypeOf(_ type:AlbumType, at indexPath:IndexPath) -> Bool
    {
        let album:Album? = appData[indexPath.section].sortedAlbumCollection[indexPath.item]
        return album?.albumType == type
    }
    
    func getPhotoForPeopleAlbum( at indexPath:IndexPath) -> QuadroPhoto
    {
        let album:Album? = appData[indexPath.section].sortedAlbumCollection[indexPath.item]

        let upperLeft:UIImage? = album?.getPhoto(at: 0)
        let buttomLeft:UIImage? = album?.getPhoto(at: 2)
        let upperRight:UIImage? = album?.getPhoto(at: 1)
        let buttomRight:UIImage? = album?.getPhoto(at: 3)
        
        return QuadroPhoto(upperLeft: upperLeft, upperRight: upperRight, buttomLeft: buttomLeft, buttomRight: buttomRight)
    }
    
    func removeEmptySections(){
        for collection in appData{
            for album in collection.albumCollection{
                album.removeEmptySections()
            }
        }
    }
    
    func removeEmptyAlbum(handelr:complitionHandelr)
    {
        for collection in appData{
            if collection.collectionType == .systemCollection{
                for album in collection.albumCollection{
                    let mandatoryAlbum = album.getMandatorySystemAlbum()
                    if !mandatoryAlbum.contains(album.albumType) && album.sections.isEmpty && album.numberPhotosInAlbum() == 0
                    {
                        do{
                            let realm = try Realm()
                            try realm.write {
                                print("need to delete \(album)")
                                realm.delete(album)
                                handelr(true)
                            }
                        }catch let error as NSError
                        {
                            print(error.debugDescription)
                            handelr(false)
                        }
                    }
                }
            }
        }
    }
}


////// Setters

struct QuadroPhoto
{
    var upperLeft:UIImage?
    var buttomLeft:UIImage?
    var upperRight:UIImage?
    var buttomRight:UIImage?
    
    init(upperLeft:UIImage? = nil,upperRight:UIImage? = nil, buttomLeft:UIImage? = nil, buttomRight:UIImage? = nil ) {
        self.upperLeft = upperLeft
        self.upperRight = upperRight
        self.buttomLeft = buttomLeft
        self.buttomRight = buttomRight
    }
}
