//
//  UIPinchGuesture + Extention.swift
//  PhotoViewer
//
//  Created by amir lahav on 11.8.2017.
//  Copyright © 2017 Nathan Blamires. All rights reserved.
//

import Foundation
import UIKit

internal enum PinchDirection {
    
    case squeze
    case expend
    
}


internal extension UIPinchGestureRecognizer {
    internal var direction: PinchDirection? {
        
        let velocitySpeed = self.velocity
        let isSqueze = (velocitySpeed) < 0
        
        switch isSqueze {
        case true:
            return .squeze
        default:
            return .expend
        }

    }
}
