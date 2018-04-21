//
//  AlbumMenagerHelper.swift
//  MySecret
//
//  Created by amir lahav on 31.8.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift


class AlbumMenagerHelper
{
    
    
    typealias CompletionHandler = (NSMutableIndexSet,[AssetCollection],Bool) -> Void
    typealias Complete = (Bool) -> Void
    

    
    
    static func createSystemAlbum()
    {
        
        guard let realm  = try? Realm() else { return }
        let helper = SaveAssets()
        let albums =  realm.objects(AlbumCollection.self)
        if albums.count == 0 {
            do
            {
                try realm.write {
                    
                    let appData = AppData()
                    
                    let systemAlbumsCollection = AlbumCollection()
                    systemAlbumsCollection.collectionType = .systemCollection
                    let userAlbumsCollection = AlbumCollection()
                    userAlbumsCollection.collectionType = .userCollection
                    let dateAlbumsCollection = AlbumCollection()
                    dateAlbumsCollection.collectionType = .dateCollection
                    let searchAlbumsCollection = AlbumCollection()
                    searchAlbumsCollection.collectionType = .searchCollection

                    let cameraRoll = Album()
                    cameraRoll.albumName = "All Photos"
                    cameraRoll.albumType = .cameraRoll
                    cameraRoll.sectionType = .cameraRoll
                    let cameraRollSection = AssetCollection()
                    cameraRollSection.sectionType = .cameraRoll
                    cameraRoll.sections.append(cameraRollSection)
                    
                    let people = Album()
                    people.albumName = "People"
                    people.albumType = .people
                    people.sectionType = .people
                    let peopleSection = AssetCollection()
                    peopleSection.sectionType = .people
                    people.sections.append(peopleSection)


                    let places = Album()
                    places.albumName = "Places"
                    places.albumType = .places
                    places.sectionType = .places
                    
                    
                    let yearAlbum = Album()
                    yearAlbum.albumName = "Year"
                    yearAlbum.albumType = .year
                    yearAlbum.sectionType = .year
                    
                    let monthAlbum = Album()
                    monthAlbum.albumName = "Month"
                    monthAlbum.albumType = .month
                    monthAlbum.sectionType = .month

                    
                    let dayAlbum = Album()
                    dayAlbum.albumName = "Moments"
                    dayAlbum.albumType = .day
                    dayAlbum.sectionType = .day
                    
                    
                    let recentlyDelete = Album()
                    recentlyDelete.albumName = "Recently Delete"
                    recentlyDelete.albumType = .recentlyDeleted
                    recentlyDelete.sectionType = .recentlyDeleted
                    
                    
                    systemAlbumsCollection.albumCollection.append(cameraRoll)
                    systemAlbumsCollection.albumCollection.append(people)
                    systemAlbumsCollection.albumCollection.append(places)
                    systemAlbumsCollection.albumCollection.append(recentlyDelete)

                    
                    dateAlbumsCollection.albumCollection.append(yearAlbum)
                    dateAlbumsCollection.albumCollection.append(monthAlbum)
                    dateAlbumsCollection.albumCollection.append(dayAlbum)
                    
                    let searchManger = SearchManager()
                    
                    
                    appData.appData.append(systemAlbumsCollection)
                    appData.appData.append(userAlbumsCollection)
                    appData.appData.append(dateAlbumsCollection)
                    appData.appData.append(searchAlbumsCollection)

                    
                    realm.add(appData)
                    realm.add(searchManger)
                }
            }catch
            {
                print("couldnt create albums")
            }
            helper.createAlbumOfType(.search, name: "Search", collectionType: .searchCollection)
        }

    }
    
    static func addPhotoToAlbum(asset: Asset, and albumType:AlbumType)
    {
        guard let realm  = try? Realm() else { return }
        let results = realm.objects(Album.self).filter("albumType = '\(albumType)'")
        if results.count > 0  {
            
            do{
                try realm.write {
                    results.first?.sections.first?.assets.append(asset)
                    print("add photo to album")
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }else{
            print("didnt save")
        }
    }
    
    static func createUserAlbum(albumName:String)
    {
        guard let realm  = try? Realm() else { return }
        let userAlbumCollection = realm.objects(AppData.self).first!.appData[1].albumCollection
        do{
            try realm.write {
                let userAlbum = Album()
                userAlbum.albumName = albumName
                userAlbum.albumType = .userAlbum
                let albumSection = AssetCollection()
                albumSection.sectionType = .userAlbum
                userAlbum.sections.append(albumSection)
                userAlbumCollection.insert(userAlbum, at: 0)
            }
        }catch let error{
            print(error.localizedDescription)
        }

    }
    
    static func removeAlbum(at indexPath:IndexPath, complite: Complete)
    {
        guard let realm  = try? Realm() else { return }
        let appData = realm.objects(AppData.self).first!
        let album:Album = appData.appData[indexPath.section].albumCollection[indexPath.item]
        do{
            try realm.write {
                realm.delete(album)
            }
        }catch let error
        {
            print(error.localizedDescription)
        }
        complite(true)
    }
    
        
    static func deletePhotosFromCameraRoll(indexes: [IndexPath]?,albumName:String,ascending: Bool ,complition: CompletionHandler)
        {
            guard let sortedIndexPaths = indexes?.sorted(by: >) else {
                return
            }
            guard let realm  = try? Realm() else { return }
            var deleteSection = [Int]()
            
            /// get all photos from realm
            
            let sections = realm.objects(Album.self).filter("albumName == '\(albumName)'").first!.getSortedListOfSection()
            var numOfPhotosInAlbum = 0
            var sectionToDelete:Array<AssetCollection> = []
            let indexSetToDelete = NSMutableIndexSet()

            /// loop through all indexs to delete and get empty section to delete
            for index in sortedIndexPaths
            {
                let section = index.section
                let item = index.item
                numOfPhotosInAlbum = sections[section].assets.count
                let photo = sections[section].assets[item]
                let linkSection = Array(photo.inSection)
                deleteFromDevice(ID: photo.assetID)

                do {
                    if numOfPhotosInAlbum > 1 {
                        
                        try realm.write {
                            for tag in photo.objectTags{
                                realm.delete(tag)
                            }
                            realm.delete(photo.dateTags!)
                            if let location = photo.location{ realm.delete(location) }
                            realm.delete(photo)
                        }
                    }else if numOfPhotosInAlbum == 1{
                        try realm.write {
                            for tag in photo.objectTags{
                                realm.delete(tag)
                            }
                            realm.delete(photo.dateTags!)
                            if let location = photo.location{ realm.delete(location) }
                            realm.delete(photo)
                            deleteSection.append(section)
                        }
                    }
                }catch let error {
                    print(error.localizedDescription)
                }
                

                for sectionTo in linkSection
                {
                    if sectionTo.assets.isEmpty && AssetCollection.getMultipleSectionAlbumType().contains(sectionTo.sectionType)
                    {
                        sectionToDelete.append(sectionTo)
                    }
                }
                
                deleteSection.forEach(indexSetToDelete.add) //Swift 3
            }
            print(indexSetToDelete)

            complition(indexSetToDelete,sectionToDelete, true)
        }

    static func deleteFromDevice(ID:String)
    {
        let helper = LoadImageHelper()
        helper.deleteImageFromDevice(ID: ID, size: .fullSize)
        helper.deleteImageFromDevice(ID: ID, size: .animationTransition)
        helper.deleteImageFromDevice(ID: ID, size: .thumbnail)

    }
    
    static func deleteEmptySections(sections:[AssetCollection], compltion:(Bool) -> Void)
    {
        guard let realm  = try? Realm() else { return }
        do{
            for sectionToDelete in sections
            {
                try realm.write {
                    realm.delete(sectionToDelete)
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }

        compltion(true)
    }
    
    static func isAlbumEmpty(album:Album) -> Bool
    {
        var numberOfPhotos = 0
        for section in album.sections
        {
            numberOfPhotos += section.assets.count
        }
        return numberOfPhotos == 0
    }
    
    static func deletePhotoFromAlbum(indexes: [IndexPath]?,albumName:String ,ascending: Bool ,complition: Complete)
    {
        guard let sortedIndexPaths = indexes?.sorted(by: >) else {
            return
        }
        guard let realm  = try? Realm() else { return }
        guard let album = realm.objects(Album.self).filter("albumName == '\(albumName)'").first else {
            print("print cant find album")
            return
        }
        let numberOfPhotosInAlbum = album.numberPhotosInAlbum()

        for index in sortedIndexPaths{
        
            do{
                if numberOfPhotosInAlbum > 1 {
                    try realm.write {
                        album.sections[index.section].assets.remove(objectAtIndex: index.item)
                    }
                }else if numberOfPhotosInAlbum == 1{
                    try realm.write {
                        album.sections[0].assets.remove(objectAtIndex: 0)
                    }
                }
            }catch let error{
                print(error.localizedDescription)
            }

        }
        complition(true)
    }
    
    static func removePhotoFromFavotrite(at indexPath:IndexPath){
        guard let realm  = try? Realm() else { return }
        guard let album = realm.objects(Album.self).filter("albumName == 'Favorite'").first else { return}
        do{
            try realm.write
                {album.sections[indexPath.section].assets.remove(objectAtIndex: indexPath.item)
            }
        }catch let error{
            print(error.localizedDescription)
        }

    }
    
    static func add(assets:[Asset],to albumType:AlbumType, name albumName:String, collectionType:CollectionType)
    {
        
        let saveHelper = SaveAssets()
        
        guard let realm = try? Realm() else { return }
       
        saveHelper.createAlbumOfType(albumType, name: albumName, collectionType: collectionType)

        guard realm.objects(Album.self).filter("albumType == \(albumType.rawValue)").first != nil else {print("no album found this album")
            return}
        
        guard let section = realm.objects(Album.self).filter("albumName == '\(albumName)'").first?.sections.first else
        {
            print("ooppppssss section not exist")
            return
        }
        do{
            try realm.write {
                for asset in assets {
                    if !section.assets.contains(asset){
                        section.assets.append(asset)
                    }
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }

    }
}







