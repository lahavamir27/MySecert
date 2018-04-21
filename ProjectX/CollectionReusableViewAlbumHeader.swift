//
//  CollectionReusableView.swift
//  PhotoViewer
//
//  Created by amir lahav on 23.12.2016.
//  Copyright © 2016 Nathan Blamires. All rights reserved.
//

import UIKit

class CollectionReusableViewAlbumHeader: UICollectionReusableView, NibLoadableView {

    @IBOutlet weak var headerText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
