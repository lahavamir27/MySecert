//
//  UINavigationItem + Extenstion.swift
//  ProjectX
//
//  Created by amir lahav on 6.11.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationItem
{
    func updateLeftBarItems(buttonType:[NavigationBarButtonsType?], delegate: UIViewController)
    {
        self.leftBarButtonItem = nil
        var leftBarButtonItem = [UIBarButtonItem]()
        for button in buttonType
        {
            guard let buttonType = button else { return }
            let NCLeftButton = NavigationBarButton.init(buttonType: buttonType)
            NCLeftButton.buttonDelegate = delegate as? NavigatinoBarButtonsProtocol
            leftBarButtonItem.append(NCLeftButton)
        }
        self.leftBarButtonItems = leftBarButtonItem
    }
 
    func updateRightBarItems(buttonType:[NavigationBarButtonsType?],delegate: UIViewController)
    {
        self.rightBarButtonItem = nil
        var rightBarButtonItem = [UIBarButtonItem]()
        
        for button in buttonType{
            guard let buttonType = button else { return }
            let NCRightButton = NavigationBarButton.init(buttonType: buttonType)
            NCRightButton.buttonDelegate = delegate as? NavigatinoBarButtonsProtocol
            rightBarButtonItem.append(NCRightButton)
        }
        self.rightBarButtonItems = rightBarButtonItem
    }
    
    enum side {
        case right
        case left
    }
}
