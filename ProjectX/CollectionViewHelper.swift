//
//  CollectionViewHelper.swift
//  ProjectX
//
//  Created by amir lahav on 16.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift

class CollectionViewHelper
{
    static func getContentOffsetFactor(with indexPath:IndexPath, and albumName:String) -> CGFloat
    {
        let realm = try! Realm()
        let album =  realm.objects(Album.self).filter("albumName == '\(albumName)'").first!
        var factor = 0
        if indexPath.section == 0 {
            factor = indexPath.row
        }else{
            for i in 0...(indexPath.section) - 1
            {
                let numOfPhoto = album.numberOfPhotos(in: i)
                factor += numOfPhoto
            }
            factor += (indexPath.row)
        }
        return CGFloat(factor)
    }
    
    
    static func updateCurrentIndex(from indexPaths: [IndexPath]?, and scrollRightDiraction:Bool) -> IndexPath? {
        
        guard var indexPaths = indexPaths else {return nil}
        
        var currentImageIndex:IndexPath? = nil
        
        if indexPaths.count > 0
        {
            indexPaths = indexPaths.sorted {$0[1] > $1[1]}
            
            if indexPaths.count > 1  {
                
                let tuple = (scrollRightDiraction, indexPaths[0][0] >= indexPaths[1][0])
                switch tuple {
                case (true,false):
                    currentImageIndex = indexPaths.last!
                case (true,true):
                    currentImageIndex = indexPaths.first!
                case (false,false):
                    currentImageIndex = indexPaths.first!
                case (false,true):
                    currentImageIndex = indexPaths.last!
                }
            }else{
                if scrollRightDiraction
                {
                    currentImageIndex = indexPaths.first!
                }else{
                    currentImageIndex = indexPaths.last!
                }
            }
        }
        return currentImageIndex
    }

}
