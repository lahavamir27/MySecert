//
//  BlurView.swift
//  ProjectX
//
//  Created by amir lahav on 23.11.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit

class BlurView: UIView, PlayableButton {


    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

protocol PlayableButton  {
    func addBlurEffect()
    func setupPlayButton()
}
extension PlayableButton where Self:UIView
{
    func addBlurEffect()
    {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = self.bounds
        blur.alpha = 0.8
        self.insertSubview(blur, at: 0)
    }
    
    func setupPlayButton()
    {
        self.clipsToBounds = true
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), cornerRadius: 0)
        
        let topX = self.frame.size.height * 0.35
        let topY = self.frame.size.height * 0.25
        
        let middleX = self.frame.size.height * 0.75
        let middleY = self.frame.size.height/2
        
        let bottomX = topX
        let bottomY = self.frame.size.height * 0.75
        
        let trianglePath = UIBezierPath()
        trianglePath.lineJoinStyle = .round
        
        trianglePath.move(to: CGPoint(x: topX, y: topY))
        trianglePath.addLine(to: CGPoint(x: middleX, y: middleY))
        trianglePath.addLine(to: CGPoint(x: bottomX, y: bottomY))
        trianglePath.addLine(to: CGPoint(x: topX, y: topY))
        
        path.append(trianglePath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.white.cgColor
        fillLayer.opacity = 0.8
        self.layer.insertSublayer(fillLayer, at: 1)
        self.layer.cornerRadius = self.frame.size.width / 2
    }
    
}

