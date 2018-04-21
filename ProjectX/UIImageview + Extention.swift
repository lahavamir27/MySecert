//
//  UIImageview.swift
//  PhotoViewer
//
//  Created by amir lahav on 22.11.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView
{
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
        
    }
        @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue

        }
    }
    
    @IBInspectable var borderColor: UIColor {
        set {
            layer.borderColor = borderColor.cgColor
        }
        get{
           return UIColor(cgColor: layer.borderColor!)
        }
    }
}
