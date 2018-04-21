//
//  GridPhotoCell.swift
//  ProjectX
//
//  Created by amir lahav on 4.10.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import UIKit
import Cartography


class PhotoCell: BaseCell, AssetCellProtocl  {
    
   
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }


    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        willSet {
            isHighlighted(newValue)
        }
    }
    override var isSelected: Bool {
        willSet {
            isSelected(newValue)
        }
    }
    
    override func prepareForReuse() {
        isSelected = false
        isHighlighted = false
    }
    
}
