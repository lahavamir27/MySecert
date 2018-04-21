//
//  Month.swift
//  PhotoViewer
//
//  Created by amir lahav on 16.11.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift

class Month: Object {
    
    dynamic var month = 0
    var days = List<Day>()
    var sections = List<AssetCollection>()
}
