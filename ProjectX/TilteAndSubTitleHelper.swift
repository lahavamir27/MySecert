//
//  TilteAndSubTitleHelper.swift
//  MySecret
//
//  Created by amir lahav on 31.8.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation



struct TilteAndSubTitleHelper {
    
    var title:String? = nil
    var subTitle:String? = nil
    
    
    init(with section:AssetCollection) {
    let creationDate = section.createdAt
    let country = section.location?.country
    let address = section.location?.adress
    let convertedDate = String.getDate(date: creationDate, sectionType:section.sectionType)
        
        switch section.sectionType {
        case .places: title = country
        case .day:
            if country != nil
            {
                title = address
                subTitle = String.getHeaderSubtitle(date:convertedDate, country:country!)
            }else{
                title = convertedDate
            }
        case .month, .year:
            title = convertedDate
        default:
            break
        }

    }
  
}
