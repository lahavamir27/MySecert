//
//  UserTextView.swift
//  ProjectX
//
//  Created by amir lahav on 6.1.2018.
//  Copyright © 2018 LA Computers. All rights reserved.
//

import UIKit




protocol ViewUpdater:class {
    func view(center:CGPoint)
}

class UserTextView: UITextView, Draggable, Rotateable {
    
    
    var viewDelegate:ViewUpdater?
    
    func didPan(panGesture: UIPanGestureRecognizer) {
    
            if panGesture.state == .began{
                self.resignFirstResponder()
            }
            let translation = panGesture.translation(in: self.superview)
            self.view.center = CGPoint(x:self.initialLocation.x + translation.x, y: self.initialLocation.y + translation.y)
            viewDelegate?.view(center: self.view.center)
           if  panGesture.state == .ended
                {
                    initialLocation = (self.superview?.convert(self.view.center, to: self.superview))!
                    viewDelegate?.view(center: self.view.center)
            }
    }
        
    var lastRotation: CGFloat = 0.0
    var initialLocation: CGPoint = CGPoint.zero
    
    override func didMoveToSuperview() {
        if self.superview != nil {
            self.registerDraggability()
            self.registerRotateability()
            self.font = UIFont.boldSystemFont(ofSize: 36)
            self.textAlignment = .center
            self.textColor = UIColor.secretPurple()
            self.becomeFirstResponder()
            self.backgroundColor = .clear
        } else {
            self.removeRotateability()
            self.removeDraggability()
        }
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
