//
//  NCBarButtonItem.swift
//  MySecret
//
//  Created by amir lahav on 6.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit


enum BarButtonType:String {
    case unknown
    case addTo
    case add
    case trash
    case selectAll
    case deSelectAll
    
    var description: String {
        return "\(hashValue) did press"
    }
}

enum ButtonType
{
    case select
    case cancel
    case back
    case detail
    case newPhoto
    case newAlbum
    case editAlbum
    case doneEditAlbum
    case search
    case lightCancel
}
