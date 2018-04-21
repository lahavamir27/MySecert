//
//  AddToNavigationBar.swift
//  ProjectX
//
//  Created by amir lahav on 10.10.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit

class AddToNavigationBar: UINavigationBar {

    fileprivate var imageView:UIImageView?
    
    override init(frame: CGRect) {
        self.imageView = UIImageView(frame: CGRect(x: 12, y: 16, width: 48, height: 42))
        super.init(frame: frame)
        self.addSubview(imageView!)
        self.height = 112.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(with image:UIImage?)
    {
        self.imageView?.image = image
    }
}
