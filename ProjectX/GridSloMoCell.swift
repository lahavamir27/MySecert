//
//  GridSloMoCell.swift
//  ProjectX
//
//  Created by amir lahav on 5.10.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import UIKit


class SloMoCell:VideoCell, MediaCell
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupIconType(.sloMo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



