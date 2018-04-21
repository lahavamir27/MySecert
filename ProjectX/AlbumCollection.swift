//
//  AlbumCollection.swift
//  MySecret
//
//  Created by amir lahav on 31.8.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//


import Foundation
import RealmSwift


class AlbumCollection: Object {
    
    dynamic var collectionType:CollectionType = .none
    var albumCollection = List<Album>()
    var sortedAlbumCollection:Results<Album>  {
        return albumCollection.sorted(byKeyPath: "albumType", ascending: true)
    }
}

@objc enum CollectionType:Int
{
    case none
    case systemCollection
    case userCollection
    case dateCollection
    case searchCollection
}
