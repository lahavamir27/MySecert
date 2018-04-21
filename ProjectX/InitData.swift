//
//  InitData.swift
//  ProjectX
//
//  Created by amir lahav on 7.11.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation


struct InitiailData
{
    var albumName:String
    var albumType:AlbumType
    var tabType:TabType
    var gridState:AppState?
    
    init(pushData: PushAlbumData?) {
        albumName = "Moments"
        albumType = .day
        tabType = .photoGrid
        gridState = .normal
        
        if let data = pushData  {
            if let albumName = data.albumName { self.albumName = albumName }
            if let albumType = data.albumType {self.albumType = albumType }
            if let tabType = data.tabType {self.tabType = tabType}
            if let gridState = data.gridState {self.gridState = gridState}
        }
    }
    
}
