//
//  FacesCollectionViewCell.swift
//  ProjectX
//
//  Created by amir lahav on 22.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit

class FacesCollectionViewCell: UICollectionViewCell, NibLoadableView {
    
    @IBOutlet weak var numberOfPhotos: UILabel!
    @IBOutlet weak var upperLeft: UIImageView!
    @IBOutlet weak var upperRight: UIImageView!
    @IBOutlet weak var buttomLeft: UIImageView!
    @IBOutlet weak var buttomRight: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
