//
//  Day.swift
//  PhotoViewer
//
//  Created by amir lahav on 16.11.2016.
//  Copyright © 2016 Nathan Blamires. All rights reserved.
//

import Foundation
import RealmSwift

class Day: Object {
    
    dynamic var day: Int = 0
    dynamic var date = Date()
    var sections = List<AssetCollection>()
}
