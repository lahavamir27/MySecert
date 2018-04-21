//
//  TextLabelAddOn.swift
//  ProjectX
//
//  Created by amir lahav on 13.1.2018.
//  Copyright © 2018 LA Computers. All rights reserved.
//

import Foundation
import UIKit

protocol UserTextLabelProtocol {
    func didTap(sender:UILabel)
}


class TextLabelAddOn :UILabel, Rotateable, Scaleable, UIGestureRecognizerDelegate
{
    
    var delegate:UserTextLabelProtocol?
    
    var lastScale: CGFloat = 1.0
    var currentScale:CGFloat = 1.0
    var lastRotation: CGFloat = 0.0
    var initialLocation: CGPoint = CGPoint.zero
    
    var viewDelegate:ViewUpdater?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView()
    {
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(self.didRotate(rotateGesture:)))
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didPan(panGesture:)))
        let sacleGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.didScale(scaleGesture:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.didTap(tapGesture:)))
        
        doubleTap.numberOfTapsRequired = 2
        rotateGesture.delegate = self
        dragGesture.delegate = self
        rotateGesture.delegate = self
        doubleTap.delegate = self
        
        
        self.addGestureRecognizer(sacleGesture)
        self.addGestureRecognizer(dragGesture)
        self.addGestureRecognizer(rotateGesture)
        self.addGestureRecognizer(doubleTap)
        
        self.text = ""
        self.textAlignment = .center
        self.textColor = .white
        self.font = UIFont.boldSystemFont(ofSize: 80)
        self.numberOfLines = 1
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.5
        self.lineBreakMode = .byTruncatingTail
        self.shadowColor = .darkGray
        self.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.layer.cornerRadius = 4.0
        self.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func didTap(tapGesture: UITapGestureRecognizer)
    {
        delegate?.didTap(sender: self)
    }
        
    func didPan(panGesture: UIPanGestureRecognizer) {
        

        let translation = panGesture.translation(in: self.superview)
        self.view.center = CGPoint(x:self.initialLocation.x + translation.x, y: self.initialLocation.y + translation.y)
        viewDelegate?.view(center: self.view.center)
        if  panGesture.state == .ended
        {
            initialLocation = (self.superview?.convert(self.view.center, to: self.superview))!
            viewDelegate?.view(center: self.view.center)
        }
    }
    
    func didScale(scaleGesture:  UIPinchGestureRecognizer)
    {
        if let view = scaleGesture.view {
            
            let size:CGFloat = 60.0
            switch scaleGesture.state
            {
                
            case .began:
                break
            case .changed:
            
                if scaleGesture.scale > currentScale{
                    print("greater")
                    lastScale = size * scaleGesture.scale
                }else if scaleGesture.scale == currentScale {
                    print("equal")
                    lastScale = size * scaleGesture.scale
                }else{
                    print("smaller")
                    lastScale = size * scaleGesture.scale
                }

                let delta = scaleGesture.scale - currentScale
                self.font = UIFont.boldSystemFont(ofSize: self.font.pointSize + delta * 100)
                sizeToFit()
                
                currentScale = scaleGesture.scale
            case .ended:
                currentScale = 1.0
            case .cancelled:
                break
            default: break
            }

        }
    }
    
    func didRotate(rotateGesture:  UIRotationGestureRecognizer)
    {
        if let view = rotateGesture.view {
            view.transform = view.transform.rotated(by: rotateGesture.rotation)
            rotateGesture.rotation = 0
        }
    }
    
    
    
    
    
}
