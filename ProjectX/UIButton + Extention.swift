//
//  UIBotton + Extention.swift
//  PhotoViewer
//
//  Created by amir lahav on 11.12.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import Foundation
import UIKit

private var AssociatedObjectHandle: UInt8 = 0



extension UIButton
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
        
    var userButtonType:NavigationBarButtonsType {
        get {
            if let userButton = objc_getAssociatedObject(self, &AssociatedObjectHandle) as? NavigationBarButtonsType {
                return userButton
            }
            return NavigationBarButtonsType.back
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addBlurEffect()
    {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = self.bounds
        blur.alpha = 0.8
        self.insertSubview(blur, at: 1)
    }
}



