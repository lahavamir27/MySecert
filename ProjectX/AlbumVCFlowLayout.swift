//
//  AlbumVCFlowLayout.swift
//  ProjectX
//
//  Created by amir lahav on 17.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit

class AlbumVCFlowLayout: UICollectionViewFlowLayout {

    
    ///// to do -> set album sizr on rotation
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var itemSize: CGSize {
        set{}
        get{
            
            let edgeIn: CGFloat = 13.5
            let labelSize:CGFloat = 50.0
            var itemsPerRow:CGFloat
            if UIDevice.current.orientation.isLandscape {
                itemsPerRow = CGFloat(3)
            } else {
                itemsPerRow = CGFloat(2)
            }
            let width = (375 - 3 * edgeIn)/2
            return CGSize(width: width, height: width + labelSize)
        }
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 1.0
        minimumLineSpacing = 0.0
        var insets:CGFloat = 10.0
        if UIDevice.current.orientation.isLandscape {
            insets = insets * 2
        }
        sectionInset = UIEdgeInsets(top: 10, left: insets, bottom: 10, right: insets * 2)
    }
    
}
