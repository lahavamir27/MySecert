//
//  MapCollectionViewCell.swift
//  ProjectX
//
//  Created by amir lahav on 21.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapCollectionViewCell: UICollectionViewCell, MKMapViewDelegate, NibLoadableView {

    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var numberOfPhotos: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var photoImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImage.layer.borderColor = UIColor.white.cgColor
        // Initialization code
    }

    override func prepareForReuse() {
    }

}
