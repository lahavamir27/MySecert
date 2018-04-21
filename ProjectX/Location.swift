//
//  Location.swift
//  PhotoViewer
//
//  Created by amir lahav on 13.11.2016.
//  Copyright © 2016 Nathan Blamires. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class Location: Object {
    
    
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var altitude = 0.0
    dynamic var horizontalAccuracy = 0.0
    dynamic var verticalAccuracy = 0.0
    dynamic var course = 0.0
    dynamic var speed = 0.0
    dynamic var date = Date()
    dynamic var adress:String? = nil
    dynamic var city:String? = nil
    dynamic var country:String? = nil
    
    /// Computed properties are ignored in Realm
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude)
    }
    
    var cLLocation: CLLocation {
        return CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy, course: course, speed: speed, timestamp: date)
    }
    
}
