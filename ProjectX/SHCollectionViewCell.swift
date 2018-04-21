//
//  SHCollectionViewCell.swift
//  Pods
//
//
//

import UIKit

class SHCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iamgeView: UIImageView!
    @IBOutlet weak var filterNameLabel: UILabel!
    
    override var isSelected: Bool {
        willSet {
            iamgeView.layer.borderColor = UIColor.secretBlue().cgColor
            iamgeView.layer.borderWidth = newValue ? 3.0 : 0.0
            filterNameLabel.textColor = newValue ? .secretBlue() : .lightGray
//            imageView.isHidden = newValue ? false : true
            
        }
    }
    
    
    
    
    
}
