//
//  SlideShowFlowLayout.swift
//  ProjectX
//
//  Created by amir lahav on 16.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit

class SlideShowFlowLayout: UICollectionViewFlowLayout {

    
    
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
            
                switch UIDevice.current.orientation {
                
                case .portrait,.faceDown,.faceUp, .unknown:
                    let size = CGSize(width: (collectionView?.bounds.size.width)!  , height: (collectionView?.bounds.size.height)!)
                    return size
                case .landscapeLeft,.landscapeRight,.portraitUpsideDown:
                    let size = CGSize(width: (collectionView?.bounds.size.width)! , height:
                        ((collectionView?.bounds.size.height)!))

                    return size
                }
        }
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0.0
        scrollDirection = .horizontal
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    

}
