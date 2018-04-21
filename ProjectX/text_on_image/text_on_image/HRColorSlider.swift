//
//  HRTextOnImageVC.swift
//
//  Created by Dat on 4/19/17.
//  Copyright © 2017 Dat. All rights reserved.
//

import UIKit

@objc protocol HRColorSliderDelegate {
    @objc optional func colorPicked(color: UIColor)
}

class HRColorSlider: UIView {
    
    var delegate: HRColorSliderDelegate?

    private var currentSelectionY: CGFloat = 0.0
    private var yBegin: CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.yBegin = self.frame.size.width * 0.5
        self.currentSelectionY = self.frame.size.height - (self.yBegin * 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clear
        self.yBegin = self.frame.size.width * 0.5
        self.currentSelectionY = self.frame.size.height - (self.yBegin * 2)
    }
    
    // MARK: - Draw helper
    
    private func DEGREES_TO_RADIANS(degrees: CGFloat) ->CGFloat {
        return (3.14159265359 * degrees) / 180.0
    }
    
    private func draw(inRect: CGRect, color: UIColor) {
        if let currentContext = UIGraphicsGetCurrentContext() {
            currentContext.addRect(inRect)
            currentContext.setFillColor(color.cgColor)
            currentContext.setStrokeColor(color.cgColor)
            currentContext.strokePath()
            currentContext.fillPath()
        }
    }
    
    private func drawRoundedRect(rect: CGRect, color: UIColor) {
        if let currentContext = UIGraphicsGetCurrentContext() {
            currentContext.addEllipse(in: rect)
            currentContext.setFillColor(color.cgColor)
            currentContext.fillPath()
            currentContext.strokePath()
        }
    }
    
    // MARK: - Draw
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let xBegin = self.frame.size.width * 0.35
        let height = (self.frame.size.height - (self.yBegin * 2)) / 7
        let width = self.frame.size.width * 0.3
        let lineWidth: CGFloat = 1
        
        // draw central vertical bar
        // pattern: 1
        let rect = CGRect(x: xBegin - lineWidth / 2, y: self.yBegin - width / 2, width: width + lineWidth, height: width + lineWidth)
        self.drawRoundedRect(rect: rect, color: UIColor(red: 1, green: 0, blue: 0, alpha: 1))
        
        for i in 1..<Int(height) {
            let temp = CGRect(x: xBegin, y: CGFloat(i) + self.yBegin, width: width, height: 1)
            self.draw(inRect: temp, color: UIColor(red: 1, green: CGFloat(i)/height, blue: 0, alpha: 1))
        }
        // pattern: 2
        for i in (Int(height)..<Int(height) * 2) {
            let h = CGFloat(Int(height) * 2) - CGFloat(i)
            let temp = CGRect(x: xBegin, y: CGFloat(i) + self.yBegin, width: width, height: 1)
            self.draw(inRect: temp, color: UIColor(red: h / height, green: 1, blue: 0, alpha: 1))
        }
        // pattern: 3
        for i in (Int(height) * 2..<Int(height) * 3) {
            let h = CGFloat(i) - (CGFloat(Int(height) * 2))
            let temp = CGRect(x: xBegin, y: CGFloat(i) + self.yBegin, width: width, height: 1)
            self.draw(inRect: temp, color: UIColor(red: 0, green: 1, blue: h / height, alpha: 1))
        }
        // pattern: 4
        for i in (Int(height) * 3..<Int(height) * 4) {
            let h = CGFloat(Int(height) * 4) - CGFloat(i)
            let temp = CGRect(x: xBegin, y: CGFloat(i) + self.yBegin, width: width, height: 1)
            self.draw(inRect: temp, color: UIColor(red: 0, green: h / height, blue: 1, alpha: 1))
        }
        // pattern: 5
        for i in (Int(height) * 4..<Int(height) * 5) {
            let h = CGFloat(i) - CGFloat(Int(height) * 4)
            let temp = CGRect(x: xBegin, y: CGFloat(i) + self.yBegin, width: width, height: 1)
            self.draw(inRect: temp, color: UIColor(red: h / height, green: 0, blue: 1, alpha: 1))
        }
        // pattern: 6
        for i in (Int(height) * 5..<Int(height) * 6) {
            let h = CGFloat(Int(height) * 6) - CGFloat(i)
            let temp = CGRect(x: xBegin, y: CGFloat(i) + self.yBegin, width: width, height: 1)
            self.draw(inRect: temp, color: UIColor(red: h / height, green: 0, blue: h / height, alpha: 1))
        }
        // pattern: 7
        let endI = Int(height) * 7
        let endY = CGFloat(endI) + self.yBegin - width / 2
        let endRect = CGRect(x: xBegin - lineWidth / 2, y: endY, width: width + lineWidth, height: width + lineWidth)
        self.drawRoundedRect(rect: endRect, color: UIColor(red: 1, green: 1, blue: 1, alpha: 1))
        
        for i in (Int(height) * 6..<Int(height) * 7) {
            let h = CGFloat(i) - CGFloat(Int(height) * 6)
            let temp = CGRect(x: xBegin, y: CGFloat(i) + self.yBegin, width: width, height: 1)
            self.draw(inRect: temp, color: UIColor(red: h / height, green: h / height, blue: h / height, alpha: 1))
        }
        
        // draw cycle
        if self.currentSelectionY < 0 {
            self.currentSelectionY = 0
        }
        else if self.currentSelectionY >= CGFloat(Int(height) * 7) {
            self.currentSelectionY = CGFloat(Int(height) * 7)
        }
        let cycleRect = CGRect(x: lineWidth / 2,
                               y: self.currentSelectionY + lineWidth / 2,
                               width: self.frame.size.width - lineWidth,
                               height: self.frame.size.width - lineWidth)
        self.drawRoundedRect(rect: cycleRect, color: UIColor.white)
    }
    
    // MARK: - Touch events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject? = touches.first
        if let point = touch?.location(in: self) {
            self.touchHandle(point: point)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject? = touches.first
        if let point = touch?.location(in: self) {
            self.touchHandle(point: point)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject? = touches.first
        if let point = touch?.location(in: self) {
            self.touchHandle(point: point)
        }
    }
    
    // MARK: - Touch handle
    
    private func touchHandle(point: CGPoint) {
        self.currentSelectionY = point.y - self.yBegin
        
        let height = (self.frame.size.height - (self.yBegin * 2)) / 7
        var color: UIColor?
        
        if self.currentSelectionY <= 0 {
            color = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        }
        else if self.currentSelectionY > 0 && Int(self.currentSelectionY) < Int(height) {
            // color for pattern 1
            color = UIColor(red: 1, green: self.currentSelectionY/height, blue: 0, alpha: 1)
        }
        else if Int(self.currentSelectionY) >= Int(height) && Int(self.currentSelectionY) < Int(height) * 2 {
            // color for pattern 2
            let h = CGFloat(Int(height) * 2) - self.currentSelectionY
            color = UIColor(red: h / height, green: 1, blue: 0, alpha: 1)
        }
        else if Int(self.currentSelectionY) >= Int(height * 2) && Int(self.currentSelectionY) < Int(height) * 3 {
            // color for pattern 3
            let h = self.currentSelectionY - CGFloat(Int(height) * 2)
            color = UIColor(red: 0, green: 1, blue: h / height, alpha: 1)
        }
        else if Int(self.currentSelectionY) >= Int(height * 3) && Int(self.currentSelectionY) < Int(height) * 4 {
            // color for pattern 4
            let h = CGFloat(Int(height * 4)) - self.currentSelectionY
            color = UIColor(red: 0, green: h / height, blue: 1, alpha: 1)
        }
        else if Int(self.currentSelectionY) >= Int(height * 4) && Int(self.currentSelectionY) < Int(height) * 5 {
            // color for pattern 5
            let h = self.currentSelectionY - CGFloat(Int(height) * 4)
            color = UIColor(red: h / height, green: 0, blue: 1, alpha: 1)
        }
        else if Int(self.currentSelectionY) >= Int(height * 5) && Int(self.currentSelectionY) < Int(height) * 6 {
            // color for pattern 6
            let h = CGFloat(Int(height) * 6) - self.currentSelectionY
            color = UIColor(red: h / height, green: 0, blue: h / height, alpha: 1)
        }
        else if Int(self.currentSelectionY) >= Int(height * 6) && Int(self.currentSelectionY) < Int(height) * 7 {
            // color for pattern 7
            let h = self.currentSelectionY - CGFloat(Int(height) * 6)
            color = UIColor(red: h / height, green: h / height, blue: h / height, alpha: 1)
        }
        else if Int(self.currentSelectionY) >= Int(height) * 7 {
            color = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        if color != nil {
            if self.delegate != nil {
                self.delegate!.colorPicked!(color: color!)
            }
            self.setNeedsDisplay()
        }
    }
    
}
