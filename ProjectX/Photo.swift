//
//  Photo.swift
//  PhotoViewer
//
//  Created by amir lahav on 13.11.2016.
//  Copyright © 2016 Nathan Blamires. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation







class Asset: Object
{
    
    // common
    dynamic var assetID:String = ""
    dynamic var createdAt: Date? = nil
    dynamic var modificationDate: Date? = nil
    dynamic var isFavorite:Bool = false
    dynamic var location:Location? = nil
    dynamic var mediaType: MediaType = .unknown
    dynamic var assetsSource: MediaSourceType  = .unknown
    dynamic var mediaSubtype : MediaSubtype = .normal
    dynamic var isHidden: Bool = false
    dynamic var nsfw: Bool = false

    
    // dates
    
    dynamic var dateTags:DateTag? = nil

    
    
    var objectTags = List<ObjectTag>()
    // photo
    
    dynamic var hasFace:Bool = false
    
    // video
    
    dynamic var duration: String? = nil

    
    dynamic var recentlyDeleted = false
    dynamic var reecntlyDeletedDate: Date? = nil
    let inSection = LinkingObjects(fromType: AssetCollection.self, property: "assets")

    override static func primaryKey() -> String? {
        return "assetID"
    }
}



@objc enum MediaSourceType:Int
{
    case library
    case frontCamera
    case rearCamera
    case share
    case unknown
}


@objc enum MediaType: Int,CustomStringConvertible {
    
    case unknown
    case image
    case video
    case audio
    
    var description: String {
        switch self {
        case .unknown: return "unknown"
            case .image: return "image"
            case .video: return "video"
            case .audio: return "audio"
        }
    }
    
    
}

@objc enum MediaSubtype: Int, CustomStringConvertible {
    
    case normal
    case photoPanorama
    case photoHDR
    case photoScreenshot
    case photoLive
    case videoStreamed
    case videoHighFrameRate
    case videoTimelapse
    case photoDepthEffect
    case fillteredImage
    
    var description: String {
        switch self {
        case .normal: return "normal"
        case .photoPanorama  :  return "photoPanorama"
        case .photoHDR : return "photoHDR"
        case .photoScreenshot :return "photoScreenshot"
        case .photoLive : return "photoLive"
        case .videoStreamed :return "videoStreamed"
        case .videoHighFrameRate :return "videoHighFrameRate"
        case .videoTimelapse :return "videoTimelapse"
        case .photoDepthEffect :return "photoDepthEffect"
        case .fillteredImage :return "fillteredImage"
        }
    }
    
}
