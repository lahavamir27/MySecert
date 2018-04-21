//
//  UIPanGesture + Extention.swift
//  PhotoViewer
//
//  Created by amir lahav on 9.8.2017.
//  Copyright © 2017 Nathan Blamires. All rights reserved.
//

import Foundation
import UIKit

internal enum Direction {
    case Up
    case Down
    case Left
    case Right
}

//MARK: - UIPanGestureRecognizer
internal extension UIPanGestureRecognizer {
    internal var direction: Direction? {
        let velocitySpeed = velocity(in: view)
        let isVertical = fabs(velocitySpeed.y) > fabs(velocitySpeed.x)
        
        switch (isVertical, velocitySpeed.x, velocitySpeed.y) {
        case (true, _, let y) where y < 0: return .Up
        case (true, _, let y) where y > 0: return .Down
        case (false, let x, _) where x > 0: return .Right
        case (false, let x, _) where x < 0: return .Left
        default: return nil
        }
    }
}
