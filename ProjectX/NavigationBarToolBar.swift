//
//  NavigationBarToolBar.swift
//  ProjectX
//
//  Created by amir lahav on 25.1.2018.
//  Copyright © 2018 LA Computers. All rights reserved.
//

import UIKit

class NavigationBarToolBar: UIToolbar {

    
    convenience init(frame: CGRect, viewController:UIViewController) {
        self.init(frame: frame)
        setupButtons(viewController: viewController)
    }
    
    func setupButtons(viewController:UIViewController)
    {
        self.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        self.setShadowImage(UIImage(), forToolbarPosition: .any)
        self.updateBarItems(buttonType:[.space, .text, .pan ,.newLabel], delegate: viewController)
    }

}
