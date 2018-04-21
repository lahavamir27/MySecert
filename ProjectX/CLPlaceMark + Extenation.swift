//
//  CLPlaceMark + Extenation.swift
//  PhotoViewer
//
//  Created by amir lahav on 28.7.2017.
//  Copyright © 2017 Nathan Blamires. All rights reserved.
//

import Foundation
import CoreLocation


extension CLPlacemark {
    
    var compactAddress: String? {
        
        if let name = name {
            var result = name
            if let street = thoroughfare {
                result += ", \(street)"
            }
            if let city = locality {
                result += ", \(city)"
            }
            if let country = country {
                result += ", \(country)"
            }
            return result
        }
        return nil
    }
    
    
    var city: String? {
        
        if let city = locality
        {
            return city
        }
        return nil
    }
    
    
}
