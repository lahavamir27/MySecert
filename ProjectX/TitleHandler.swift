//
//  TitleHandler.swift
//  PhotoViewer
//
//  Created by amir lahav on 18.8.2017.
//  Copyright © 2017 Nathan Blamires. All rights reserved.
//

import Foundation


class TitleHelper: NSObject {
    
    static func getTitle(indexCount:Int, albumName:String, stateView: AppState ) -> String
    {
        if stateView == .selectPhotos  {
            switch indexCount {
            case 0:
                return "Select Items"
            case 1:
                return "1 Photo Selected"
            default:
                return "\(indexCount) Photos Selected"
            }
        }else
            if albumName != "" {
                return albumName
            }else{
                return "MySecert"
        }
    }
    
    static func getPrompTitle(with numberOfAssets:Int,and albumName:String) -> String {
        switch numberOfAssets {
        case 0:
            return "Add photos to \"\(albumName)\"."
        case 1:
            return "Add 1 photo to \"\(albumName)\"."
        default:
            return "Add \(numberOfAssets) photos to \"\(albumName)\"."
        }
    }
}
