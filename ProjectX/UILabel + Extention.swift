//
//  Extention + UILabel.swift
//  PhotoViewer
//
//  Created by amir lahav on 1.7.2017.
//  Copyright © 2017 Nathan Blamires. All rights reserved.
//

import Foundation
import UIKit




extension UILabel
{
    func setLineHeight(lineHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.alignment = self.textAlignment
    
        let attrString = NSMutableAttributedString(string: self.text!)
        attrString.addAttribute(NSFontAttributeName, value: self.font, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range: NSMakeRange(0, attrString.length))
        self.attributedText = attrString
    }
    
    func attributeMyLabelSelfText() -> NSAttributedString{
        self.attributedText = NSAttributedString(string: self.text!, attributes:[NSKernAttributeName: 5.0])
        return self.attributedText!
    }
}
