//
//  UINavigationController.swift
//  ProjectX
//
//  Created by amir lahav on 10.10.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import UIKit

private var AssociatedObjectHandle: UInt8 = 0


extension UINavigationBar {

    

    var height: CGFloat {
        get {
            if let h = objc_getAssociatedObject(self, &AssociatedObjectHandle) as? CGFloat {
                return h
            }
            return 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        if self.height > 0
        {
            return CGSize(width: UIScreen.main.bounds.width, height: self.height)
        }
        return super.sizeThatFits(size)
    }
    
    
    func updateViews()
    {
        for view: UIView in self.subviews {
            let bounds: CGRect = self.bounds
            var frame: CGRect = view.frame
            frame.origin.y = bounds.origin.y   + 20.0
            frame.size.height = bounds.size.height + 20.0
            view.frame = frame
        }
    }
    
}


class NavigationBar: UINavigationBar {
    
    //set NavigationBar's height
    open var customHeight : CGFloat = 132
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: customHeight)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        frame = CGRect(x: frame.origin.x, y:  0, width: frame.size.width, height: customHeight)
        
        setTitleVerticalPositionAdjustment(0, for: UIBarMetrics.default)
        
        for subview in self.subviews {
            var stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("BarBackground") {
                subview.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: customHeight)
                
            }
            
            stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("BarContent") {
                
                subview.frame = CGRect(x: subview.frame.origin.x, y: 20, width: subview.frame.width, height: customHeight - 20)
                
                
            }
        }
    }
    
    
}

