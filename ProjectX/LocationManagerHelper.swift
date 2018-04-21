//
//  LocationManegere.swift
//  PhotoViewer
//
//  Created by amir lahav on 23.12.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import UIKit
import RealmSwift

class LocationManagerHelper: NSObject {
    
    
    static fileprivate var loadImageHelper = LoadImageHelper()

    
    static func getPlacemarkForAdress(location: CLLocation, resualtHendler: @escaping (String?, CLPlacemark?)->() )
    {
        let geocoder = CLGeocoder() 
        var place:[CLPlacemark]?
        var errorT:Error?
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            // Process Response
            place = placemarks
            errorT = error
            var response:(String?, CLPlacemark?)
            response = self.processResponse(withPlacemarks: place, error: errorT)
            resualtHendler(response.0,response.1)
        }

    }
    
    private static func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) -> (String?, CLPlacemark?) {
        // Update View
 
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                return (placemark.name, placemark)
//               return placemark.compactAddress!
            } else {
               return ("No Matching Addresses Found",nil)
            }
        }
        return (nil,nil)
    }
    
    static func getMapImage(from location:CLLocationCoordinate2D, size:CGSize)
    {
            
        let mapSpan = MKCoordinateSpanMake(0.1, 0.1)
        let mapRegion = MKCoordinateRegionMake(location, mapSpan)
        let options = MKMapSnapshotOptions()
        options.region = mapRegion
        options.size = size
        options.scale = UIScreen.main.scale
        let snapshotter = MKMapSnapshotter(options: options)
        
        snapshotter.start() {snapshot, error in
            
            let mapData = UIImagePNGRepresentation((snapshot?.image)!)
            let mapPhoto = loadImageHelper.getDocumentsDirectory().appendingPathComponent("backgrounMap.png")
            try? mapData?.write(to: mapPhoto)
            }
    }
    
    static func requestSnapshotData(complition:@escaping (UIImage?)->()) {
        let mapSnapshotOptions = MKMapSnapshotOptions()
        
        // Set the region of the map that is rendered.
        let realm = try! Realm()
        let placeAlbum = realm.objects(Album.self).filter("albumType == \(AlbumType.places.rawValue)").first
        if let location:CLLocationCoordinate2D = placeAlbum?.sections.first?.assets.first?.location?.coordinate{
            let region = MKCoordinateRegionMakeWithDistance(location, 10000, 10000)
        mapSnapshotOptions.region = region
        
        // Set the scale of the image. We'll just use the scale of the current device .
        mapSnapshotOptions.scale = UIScreen.main.scale
        
        // Set the size of the image output.
        mapSnapshotOptions.size = CGSize(width: 150,height: 150)
        
        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true
        
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        
        snapShotter.start { (snapshot, error) in
            complition(snapshot?.image)
        }
        }else
        {complition(nil)}
    }
    
}
