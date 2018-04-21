//
//  ImageCollectionViewCell.swift
//  PhotoViewer
//
//  Created by amir lahav on 11.8.2017.
//  Copyright © 2017 Nathan Blamires. All rights reserved.
//

import UIKit
import Cartography
class ImageCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate, NibLoadableView {
    
    
    
    
    


    @IBOutlet weak var imageView: ImageScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.frame = UIScreen.main.bounds
        // Initialization code
        
    }
    

    
    override func prepareForReuse() {
        imageView.frame = UIScreen.main.bounds
        imageView.zoomView?.image = nil
    }
}
