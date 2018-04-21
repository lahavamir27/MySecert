//
//  EditImageToolbar.swift
//  ProjectX
//
//  Created by amir lahav on 24.1.2018.
//  Copyright © 2018 LA Computers. All rights reserved.
//

import UIKit

class EditImageToolbar: UIToolbar {

    fileprivate var viewState:EditToolbarState? = nil {
        
        didSet{
            switch viewState! {
            case .normal:   break
            case .filter:   break
            case .text:     break
            case .paint:    break
            case .label:    break
            }
        }
    }
    
    fileprivate var imageState:ImageState? = nil {
        
        didSet{
            switch imageState! {
            case .normal:
                self.updateButtonTint(color: .white, atIndex: 10)
            case .edited:
                self.updateButtonTint(color: .yellow, atIndex: 10)
            }
        }
    }

    convenience init(frame: CGRect, viewController:UIViewController) {
        self.init(frame: frame)
        viewState = .normal
        setupButtons(viewController: viewController)
    }
    
    func setupButtons(viewController:UIViewController)
    {
//        self.setBackgroundImage(UIImage(),  forToolbarPosition: .any, barMetrics: .default)
//        self.setShadowImage(UIImage(), forToolbarPosition: .any)
        self.barTintColor = .black
        self.isTranslucent = false
        self.updateBarItems(buttonType:[.cancel,.space, .filter,.space,.FX,.space,.paint,.space,.doneEditAlbum ], delegate: viewController)
        self.updateButtonTint(color: .white, atIndex: 2)
        self.updateButtonTint(color: .white, atIndex: 4)
        self.updateButtonTint(color: .white, atIndex: 6)
        self.updateButtonTint(color: .white, atIndex: 8)
        self.updateButtonTint(color: .yellow, atIndex: 10)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


enum EditToolbarState{
    case normal
    case filter
    case text
    case paint
    case label
}

enum ImageState {
    case normal
    case edited
}
