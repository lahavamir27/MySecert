//
//  CollectionReusableViewFooter.swift
//  PhotoViewer
//
//  Created by amir lahav on 5.3.2017.
//  Copyright © 2017 Nathan Blamires. All rights reserved.
//

import UIKit

class CollectionReusableViewFooter: UICollectionReusableView, NibLoadableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var counterLbl: UILabel!
    
    
    func configure(album:Album)
    {
        let numberOfPhotos = FetchDataHelper.getNumberOfPhotos()
        self.counterLbl.text = ""
        switch album.sectionType {
        case .day, .month, .year, .cameraRoll:
            if numberOfPhotos == 1 {
                self.counterLbl.text = "\(numberOfPhotos) Photo"
            }else if numberOfPhotos > 1
            {
                self.counterLbl.text = "\(numberOfPhotos) Photos"
            }
        default:
            break
        }
    }
}
