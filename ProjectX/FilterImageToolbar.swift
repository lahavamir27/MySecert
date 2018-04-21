//
//  FilterImageToolbar.swift
//  ProjectX
//
//  Created by amir lahav on 7.1.2018.
//  Copyright © 2018 LA Computers. All rights reserved.
//

import UIKit
import Cartography


protocol FilterImageToolbarProtocol {
    func buttonDidPress(button:UIButton)
}


class FilterImageToolbar: UIView {

    var delegate:FilterImageToolbarProtocol?
    var doneBtn:UIButton
    var cancelBtn:UIButton
    
    override init(frame:CGRect)
    {
        doneBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        cancelBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        super.init(frame:frame)
        setupButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupButtons()
    {
        self.addSubview(doneBtn)
        self.addSubview(cancelBtn)
        
        doneBtn.setTitleColor(.lightGray, for: .normal)
        doneBtn.setTitle("Done", for: .normal)
        doneBtn.contentHorizontalAlignment = .right
        doneBtn.userButtonType = .doneEditAlbum
        doneBtn.addTarget(self, action: #selector(self.buttonDidPress(_:)), for: .touchUpInside)

        cancelBtn.setTitleColor(UIColor.secretYellow(), for: .normal)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.contentHorizontalAlignment = .left
        cancelBtn.userButtonType = .cancel
        cancelBtn.addTarget(self, action: #selector(self.buttonDidPress(_:)), for: .touchUpInside)


        constrain(self, doneBtn) {toolbar, button in
            button.right == toolbar.right - 12
            button.height == 36
            button.width == 64
            button.bottom == toolbar.bottom - 4
        }
        
        constrain(self, cancelBtn) {toolbar, button in
            button.left == toolbar.left + 12
            button.height == 36
            button.width == 64
            button.bottom == toolbar.bottom - 4
        }
        
        
    }
    
    @IBAction func buttonDidPress(_ sender:UIButton)
    {
        delegate?.buttonDidPress(button: sender)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
