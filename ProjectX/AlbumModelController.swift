//
//  AlbumModelController.swift
//  ProjectX
//
//  Created by amir lahav on 13.10.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift

struct AlbumModelController {
    
    
    func numberOfItemsIn(_ section: Int) -> Int
    {
        guard let realm = try? Realm() else {print("cant get realm") ; return 0 }
        guard let numberOfItemsIn = realm.objects(AppData.self).first?.appData[section].albumCollection.count else {return 0}
        return numberOfItemsIn
    }
    
    func getAlbumData(at indexPath:IndexPath) -> PushAlbumData?
    {
        guard let realm = try? Realm() else {print("cant get realm") ; return nil }
        guard let appData = realm.objects(AppData.self).first else {print("cant get appData") ; return nil }
        let albumName = appData.getAlbumName(at: indexPath)
        let albumType = appData.getAlbumType(at: indexPath)
        let pushAlbumData = PushAlbumData(albumName: albumName,tabType: .albumGrid, albumType: albumType)
        return pushAlbumData
    }
    
    func isAlbum(exist albumName:String) -> Bool
    {
        guard let realm = try? Realm() else {print("cant get realm") ; return true }
        guard let appData = realm.objects(AppData.self).first else {print("cant get appData") ; return true }
        return appData.isUserAlbumExist(with: albumName)
    }
    
    func getAlbumType(at index:IndexPath) -> AlbumType?
    {
        guard let realm = try? Realm() else {print("cant get realm") ; return nil}
        guard let appData = realm.objects(AppData.self).first else {print("cant get appData") ; return nil }
        guard let type = appData.getAlbumType(at: index) else {print("cant get type") ; return nil }
        return type
    }
    func getNumberOfPhotosInAlbum(at indexPath:IndexPath) -> String?
    {
        let realm = try! Realm()
        let appData = realm.objects(AppData.self).first!
        return appData.getNumberOfPhotos(at: indexPath)
    }
    
    func getAlbumCover(at indexPath:IndexPath) -> UIImage? {
        
        guard let realm = try? Realm() else {print("cant get realm") ; return nil }
        let appData = realm.objects(AppData.self).first!
        return appData.getAlbumCover(at: indexPath)
    }
    func getPhotoForPeopleAlbum(at indexPath:IndexPath) -> QuadroPhoto
    {
        let realm = try! Realm()
        let appData = realm.objects(AppData.self).first!
        return appData.getPhotoForPeopleAlbum(at: indexPath)
    }
    
    func getAlbumName(at indexPath:IndexPath) -> String?
    {
        let realm = try! Realm()
        let appData = realm.objects(AppData.self).first!
        return appData.getAlbumName(at: indexPath)
    }
    
    func removeEmptySections()
    {
        let realm = try! Realm()
        let appData = realm.objects(AppData.self).first!
        appData.removeEmptySections()
    }
    func removeEmptyAlbums(complitionHandler:(Bool)->())
    {
        let realm = try! Realm()
        let appData = realm.objects(AppData.self).first!
        appData.removeEmptyAlbum { (succes) in
            complitionHandler(succes)
        }
    }
    
    
}
