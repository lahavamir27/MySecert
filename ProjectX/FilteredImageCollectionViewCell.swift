//
//  FilteredImageCollectionViewCell.swift
//  ProjectX
//
//  Created by amir lahav on 7.1.2018.
//  Copyright © 2018 LA Computers. All rights reserved.
//

import UIKit
import Cartography

class FilteredImageCollectionViewCell: UICollectionViewCell {
    
    
    var imageView:UIImageView
    var filterName:UILabel
    
    override init(frame: CGRect) {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 1.0, height: 1.0))
        filterName = UILabel(frame: CGRect(x: 0, y: 0, width: 1.0, height: 1.0))
        super.init(frame: frame)
        setupConstraints()
    }
    
    
    func setupConstraints()
    {
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(filterName)
        
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        constrain(self.contentView, imageView) { cell, image in
            image.top == cell.top
            image.width == cell.width
            image.height == cell.width
            image.left == cell.left
            image.right == cell.right
        }
        
        filterName.font = UIFont.systemFont(ofSize: 12.0)
        filterName.textColor = .lightGray
        filterName.textAlignment = .center
        
        constrain(self.contentView, imageView, filterName) { cell, image, label in
            label.width == cell.width
            label.top == image.bottom + 7
            label.bottom == cell.bottom

        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        willSet {
            imageView.layer.borderColor = UIColor.secretBlue().cgColor
            imageView.layer.borderWidth = newValue ? 3.0 : 0.0
            filterName.textColor = newValue ? .secretBlue() : .lightGray
        }
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        filterName.text = nil
        self.isSelected = false
    }
    
}
