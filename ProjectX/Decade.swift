//
//  Decate.swift
//  MySecret
//
//  Created by amir lahav on 25.8.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift


class Decade: Object {
    
    dynamic var decade = 0
    var years = List<Year>()
    var photos = List<Asset>()
    
}
