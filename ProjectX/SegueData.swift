//
//  SegueData.swift
//  MySecret
//
//  Created by amir lahav on 8.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation


struct SegueData {
    
    var indexPath:IndexPath? = nil
    var albumName:String? = nil
    var tabType:TabType? = nil
    init(indexPath:IndexPath? = nil, albumName:String? = nil, tabType:TabType? = nil) {
        self.indexPath = indexPath
        self.albumName = albumName
        self.tabType = tabType
    }
}
