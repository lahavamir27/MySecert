//
//  FilterImageToolbar.swift
//  ProjectX
//
//  Created by amir lahav on 7.1.2018.
//  Copyright © 2018 LA Computers. All rights reserved.
//

import UIKit
import Cartography


protocol EditImageNavigationBarProtocol {
    func navigationBarbuttonDidPress(button:UIButton)
}



class EditNavigationBar: UINavigationBar
{
    
    override init(frame:CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class EditImageNavigationBar: UIView {
    
    var delegate:EditImageNavigationBarProtocol?
    var textBtn:UIButton
    var panBtn:UIButton
    
    override init(frame:CGRect)
    {
        textBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        panBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        super.init(frame:frame)
        setupButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupButtons()
    {
        self.addSubview(textBtn)
        self.addSubview(panBtn)
        
        textBtn.setTitleColor(.lightGray, for: .normal)
        textBtn.setImage(#imageLiteral(resourceName: "Aa"), for: .normal)
        textBtn.userButtonType = .newLabel
        textBtn.imageEdgeInsets = UIEdgeInsets(top: 7.0, left: 6.0, bottom: 5.0, right: 6.0)
        textBtn.addTarget(self, action: #selector(self.buttonDidPress(_:)), for: .touchUpInside)
        
        panBtn.setTitleColor(UIColor.secretYellow(), for: .normal)
        panBtn.setImage(#imageLiteral(resourceName: "icons8-pencil-72"), for: .normal)
        panBtn.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 9.0, bottom: 8.0, right: 9.0)
        panBtn.userButtonType = .pan
        panBtn.addTarget(self, action: #selector(self.buttonDidPress(_:)), for: .touchUpInside)
        
        
        constrain(self, panBtn) {toolbar, button in
            button.right == toolbar.right - 12
            button.height == 44
            button.width == 44
            button.bottom == toolbar.bottom
        }
        
        constrain(self, textBtn, panBtn) {toolbar, text, pan in
            text.right == pan.left - 12
            text.height == 44
            text.width == 44
            text.bottom == toolbar.bottom
        }
        

        
        
    }
    
    @IBAction func buttonDidPress(_ sender:UIButton)
    {
        delegate?.navigationBarbuttonDidPress(button: sender)
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

