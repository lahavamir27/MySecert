//
//  UIView + Extenstion + Protocol.swift
//  ProjectX
//
//  Created by amir lahav on 25.12.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import UIKit




protocol Fadeable {
    func fadeView(fade:Bool, time:TimeInterval)
}

extension Fadeable where Self:UIView {
    func fadeView(fade:Bool, time:TimeInterval){
        UIView.animate(withDuration: time) {
            if fade {
                self.alpha = 0.0
            }else{
                self.alpha = 1.0
            }
        }
    }
}

protocol Blurable where Self:UIView {
    var blurEffectView:UIVisualEffectView {get set}
    func fadeOut(withDuration: TimeInterval, curve: UIViewAnimationCurve)
    func fadeIn(withDuration: TimeInterval, curve: UIViewAnimationCurve)

}

extension Blurable {
    

    func fadeIn(withDuration: TimeInterval, curve: UIViewAnimationCurve)
    {
        self.addSubview(blurEffectView)
        
        let animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: withDuration, delay: 0.0, options: [], animations: {
            self.blurEffectView.effect = UIBlurEffect(style: .light)
        }) { (finish) in
            print("finish")
        }
//        let animator = UIViewPropertyAnimator(duration: withDuration, curve: curve) {[unowned self] _ in
//            self.blurEffectView.effect = UIBlurEffect(style: .light)
//        }
        animator.startAnimation()
    }
    
    func fadeOut(withDuration: TimeInterval, curve: UIViewAnimationCurve)
    {
        let animator = UIViewPropertyAnimator(duration: withDuration, curve: curve) {[unowned self] _ in
            self.blurEffectView.effect = nil
        }
        animator.startAnimation()
    }
}

extension UIView:Fadeable
{
    
}
