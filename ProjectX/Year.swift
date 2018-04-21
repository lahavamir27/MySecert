//
//  Year.swift
//  PhotoViewer
//
//  Created by amir lahav on 16.11.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift


class Year: Object {
    
    dynamic var year = 0
    var months = List<Month>()
    var sections = List<AssetCollection>()
}
