//
//  Album.swift
//  PhotoViewer
//
//  Created by amir lahav on 13.11.2016.
//  Copyright © 2016 Nathan Blamires. All rights reserved.
//

import Foundation
import RealmSwift




class AssetCollection: Object {
        
    dynamic var sectionTitle:String? = nil
    dynamic var createdAt: Date = Date()
    dynamic var sectionType:SectionType = .unknown
    dynamic var location:Location? = nil
    
    
    var assets = List<Asset>()


    var numOfPhotosInSection: Int {
        return assets.count
    }
    var sectionTitleDesc: String?{
        
        switch sectionType {
        case .day:
            return location?.adress
        default:
            return sectionTitle
        }
    }
    
    var dateComponents:DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day], from: createdAt)
    }
    
    
    static func getMultipleSectionAlbumType() -> [SectionType]
    {
        return [.day, .month, .year, .places]
    }
    
    static func getSystemSection() -> [SectionType]
    {
        return [ .month, .year, .places, .people, .favorite, .editedPhoto]
    }
    
    static func isSystemSectionType(sectionType:SectionType) -> Bool
    {
        return getSystemSection().contains(sectionType)
    }
    

   
}







@objc enum SectionType:Int {
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


    
    var description:String
    {
        switch self {
        case .cameraRoll:return "cameraRoll"
        case .favorite:return "favorite"
        case .people:return "people"
        case .places:return "places"
        case .recentlyDeleted:return "recentlyDeleted"
        case .selfie:return "selfie"
        case .video:return "video"
        case .unknown:return "unknown"
        case .userAlbum:return "userAlbum"
        case .year:return "year"
        case .month:return "month"
        case .day:return "day"
        case .editedPhoto:return "editedPhoto"
        case .sloMo:return "sloMo"
        case .timeLapse:return "timeLapse"
        case .screenShots:return "screenShots"
        case .specialEffect:return "specialEffect"
        case .panorama:return "panorama"
        case .search:return "search"
        case .nsfw: return "nsfw"

        }
    }

}

extension Bool {
    init<T: Integer>(_ num: T) {
        self.init(num != 0)
    }
}
