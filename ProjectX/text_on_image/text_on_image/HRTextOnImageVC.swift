//
//  HRTextOnImageVC.swift
//
//  Created by Dat on 4/19/17.
//  Copyright © 2017 Dat. All rights reserved.
//

/**
 * This view controller created for iphone (414x736) for the default.
 * Other devices scale automatically
 */

import UIKit

private let textViewPlaceString = "Hey, check"
private let defaultSize = CGSize(width: 414, height: 736)

class HRTextOnImageVC: UIViewController, HRColorSliderDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {

    var image: UIImage?
    
    // Controls on ui
    private var imageViewContainer: UIView!
    private var imageView: UIImageView?
    private var imageBackgroundView: UIView?
    private var backButton: UIButton!
    private var addTextButton: UIButton!
    private var okButton: UIButton!
    private var textViewContainer: UIView?
    private var textView: UITextView?
    private var colorSlider: HRColorSlider?
    
    // Frame of controls
    private var viewSize: CGSize!
    private var backButtonFrame: CGRect!
    private var addTextButtonFrame: CGRect!
    private var okButtonFrame: CGRect!
    private var textViewContainerFrame: CGRect!
    private var colorSliderFrame: CGRect!
    
    // Fonts
    private var textViewFont: UIFont!
    private var addTextButtonFont: UIFont!
    
    // Gesture recognizer
    private var activeRotateRecognizer: UIRotationGestureRecognizer?
    private var activePinchRecognizer: UIPinchGestureRecognizer?
    private var referenceRotateTransform: CGAffineTransform?
    private var currentRotateTransform: CGAffineTransform?
    private var referenceCenter = CGPoint(x: 0, y: 0)
    private var textScale: CGFloat = 1 {
        didSet {
            self.textViewContainer?.transform = CGAffineTransform.identity
            let textViewCenter = self.textViewContainer!.center
            let scaledTextViewFrame = CGRect(x: 0, y: 0,
                                             width: self.textViewContainer!.frame.size.width * textScale,
                                             height: self.textViewContainer!.frame.size.height * textScale)
            let currentFontSize = self.textView!.font!.pointSize * textScale
            
            self.textView!.font = UIFont.systemFont(ofSize: currentFontSize)
            self.textViewContainer?.frame = scaledTextViewFrame
            self.textViewContainer?.center = textViewCenter
            self.textViewContainer?.transform = self.currentRotateTransform!
            
            textScale = 1
        }
    }
    
    private var selectedColor = UIColor.white
    private var isShowingTextView = false {
        didSet {
            if isShowingTextView {
                self.textViewContainer?.isHidden = false
                self.imageBackgroundView?.isHidden = false
                self.addTextButton.setTitleColor(UIColor.orange, for: .normal)
            } else {
                self.textViewContainer?.isHidden = true
                self.imageBackgroundView?.isHidden = true
                self.addTextButton.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupFrameForControls()
        self.setupFont()
        self.setupLayout()
        self.setupGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private
    
    private func bringViewToFront(views: [UIView], superView: UIView) {
        for view in views {
            superView.bringSubview(toFront: view)
        }
    }
    
    private func textViewFitContent() {
        let currentFontSize = self.textView!.font!.pointSize * textScale
        let font = UIFont(name: self.textViewFont.fontName, size: currentFontSize)! //UIFont.systemFont(ofSize: currentFontSize)
        let width = self.viewSize.width * textScale
        let height = self.textView!.text.height(withConstrainedWidth: width, font: font) + font.pointSize * 2
        
        self.textViewContainer?.transform = CGAffineTransform.identity
        let textViewCenter = self.textViewContainer!.center
        let scaledTextViewFrame = CGRect(x: 0, y: 0,
                                         width: width,
                                         height: height)
        
        self.textViewContainer?.frame = scaledTextViewFrame
        self.textViewContainer?.center = textViewCenter
        self.textViewContainer?.transform = self.currentRotateTransform!
    }
    
    private func screenShot() -> UIImageView {
        let imageSize = self.imageViewContainer.frame.size
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        self.imageViewContainer.drawHierarchy(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imgView = UIImageView(image: image)
        return imgView
    }
    
    // MARK: - Setup
    
    private func setupFrameForControls() {
        self.viewSize = self.view.frame.size
        
        let widthScale = self.viewSize.width /  defaultSize.width
        let heightScale = self.viewSize.height /  defaultSize.height
        
        self.backButtonFrame = CGRect(x: 0, y: 0, width: 100 * widthScale, height: 50 * heightScale)
        self.addTextButtonFrame  = CGRect(x: 150 * widthScale, y: 0, width: 100 * widthScale, height: 50 * heightScale)
        self.okButtonFrame = CGRect(x: self.viewSize.width / 2 - (50 * widthScale),
                                    y: self.viewSize.height - (100 * heightScale),
                                    width: 100 * widthScale,
                                    height: 100 * heightScale)
        self.textViewContainerFrame = CGRect(x: 0, y: 200 * heightScale, width: self.viewSize.width, height: 100 * heightScale)
        self.colorSliderFrame = CGRect(x: 50, y: 70 * heightScale, width: 50 * widthScale, height: 350 * heightScale)
    }
    
    private func setupFont() {
        let widthScale = self.viewSize.width /  defaultSize.width
        
        self.textViewFont = UIFont.systemFont(ofSize: 25 * widthScale)
        self.addTextButtonFont = UIFont.systemFont(ofSize: 25 * widthScale)
    }
    
    private func setupGesture() {
        self.currentRotateTransform = CGAffineTransform.identity
        self.referenceRotateTransform = CGAffineTransform.identity
    }
    
    // MARK: - Setup Layout
    
    private func setupLayout() {
        self.view.backgroundColor = UIColor.gray
        self.setupImageViewContainer()
        self.setupImageView()
        self.setupBackButton()
        self.setupAddTextButton()
        self.setupOkButton()
    }
    
    private func setupImageViewContainer() {
        self.imageViewContainer = UIView(frame: self.view.bounds)
        self.imageViewContainer!.backgroundColor = UIColor.clear
        self.view.addSubview(self.imageViewContainer!)
    }
    
    private func setupImageView() {
        if self.image != nil {
            self.imageView = UIImageView(frame: self.view.bounds)
            self.imageView!.contentMode = .scaleAspectFit
            self.imageView!.image = self.image
            self.imageViewContainer.addSubview(self.imageView!)
        }
    }
    
    private func setupBackButton() {
        self.backButton = UIButton(frame: self.backButtonFrame)
        self.backButton.setImage(UIImage(named: "Icon.bundle/icon_back"), for: .normal)
        self.backButton.addTarget(self, action: #selector(self.backButtonTouchUpInside(_:)), for: .touchUpInside)
        self.view.addSubview(self.backButton)
    }
    
    private func setupAddTextButton() {
        self.addTextButton = UIButton(frame: self.addTextButtonFrame)
        self.addTextButton.setTitle("Aa", for: .normal)
        self.addTextButton.titleLabel?.font = self.addTextButtonFont
        self.addTextButton.addTarget(self, action: #selector(self.addTextButtonTouchUpInside(_:)), for: .touchUpInside)
        self.view.addSubview(self.addTextButton)
    }
    
    private func setupOkButton() {
        self.okButton = UIButton(frame: self.okButtonFrame)
        self.okButton.setImage(UIImage(named: "Icon.bundle/ic_tick"), for: .normal)
        self.okButton.addTarget(self, action: #selector(self.okButtonTouchUpInside(_:)), for: .touchUpInside)
        self.view.addSubview(self.okButton)
    }
    
    private func setupTextViewContainerIfNeeded() {
        if self.textViewContainer == nil {
            self.setupImageBackgroundView()
            self.setupTextViewContainer()
            self.setupTextView()
            self.setupColorSlider()
            self.isShowingTextView = true
        } else {
            self.isShowingTextView = true
            self.colorSlider?.isHidden = false
        }
    }
    
    private func setupColorSlider() {
        self.colorSlider = HRColorSlider(frame: self.colorSliderFrame)
        self.colorSlider!.delegate = self
        self.view.addSubview(self.colorSlider!)
    }
    
    private func setupImageBackgroundView() {
        self.imageBackgroundView = UIView(frame: self.view.bounds)
        self.imageBackgroundView!.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.imageViewContainer.addSubview(self.imageBackgroundView!)
    }
    
    private func setupTextViewContainer() {
        self.textViewContainer = UIView(frame: self.textViewContainerFrame)
        self.textViewContainer!.backgroundColor = UIColor.clear
        self.textViewContainer!.isUserInteractionEnabled = true
        self.imageViewContainer.addSubview(self.textViewContainer!)
        
        // add pan gesture to text view container
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.textViewDidPan(pan:)))
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        self.textViewContainer!.addGestureRecognizer(pan)
        
        // add rotation gesture to text view container
        self.activeRotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(self.textViewDidPinchOrRotation(recognizer:)))
        self.activeRotateRecognizer!.delegate = self
        self.textViewContainer!.addGestureRecognizer(self.activeRotateRecognizer!)
        
        // add pinch gesture to text view container
        self.activePinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.textViewDidPinchOrRotation(recognizer:)))
        self.activePinchRecognizer!.delegate = self
        self.textViewContainer!.addGestureRecognizer(self.activePinchRecognizer!)
    }
    
    private func setupTextView() {
        self.textView = UITextView(frame: self.textViewContainer!.bounds)
        self.textView!.tintColor = UIColor.white
        self.textView!.keyboardType = .default
        self.textView!.keyboardAppearance = .dark
        self.textView!.spellCheckingType = .no
        self.textView!.autocorrectionType = .no
        self.textView!.returnKeyType = .done
        self.textView!.text = textViewPlaceString
        self.textView!.textAlignment = .center
        self.textView!.textColor = self.selectedColor
        self.textView!.backgroundColor = UIColor.clear
        self.textView!.font = self.textViewFont
        self.textView!.clipsToBounds = true
        self.textView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.textView!.delegate = self
        self.textView!.isUserInteractionEnabled = true
        self.textViewContainer!.addSubview(self.textView!)
        self.textViewFitContent()
    }
    
    // MARK: - TextView Gesture Recognizer
    
    
    @objc private func textViewDidPan(pan: UIPanGestureRecognizer) {
        switch (pan.state) {
        case .began:
            self.referenceCenter = self.textViewContainer!.center
        case .changed:
            let panTranslation = pan.translation(in: self.view)
            self.textViewContainer?.center = CGPoint(x: self.referenceCenter.x + panTranslation.x,
                                            y: self.referenceCenter.y + panTranslation.y)
        case .ended:
            self.referenceCenter = self.textViewContainer!.center
        default:
            break
        }
    }
    
    @objc private func textViewDidPinchOrRotation(recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if let rotate = recognizer as? UIRotationGestureRecognizer {
                self.currentRotateTransform = self.referenceRotateTransform
                self.activeRotateRecognizer = rotate
            }
            else if let pinch = recognizer as? UIPinchGestureRecognizer {
                self.activePinchRecognizer = pinch
            }
        case .changed:
            var currentTransform = self.referenceRotateTransform
            
            if recognizer is UIRotationGestureRecognizer {
                self.currentRotateTransform = self.apply(recognizer: recognizer, transform: self.referenceRotateTransform!)
            }
            
            currentTransform  = self.apply(recognizer: self.activePinchRecognizer, transform: currentTransform!)
            currentTransform  = self.apply(recognizer: self.activeRotateRecognizer, transform: currentTransform!)
            
            self.textViewContainer?.transform = currentTransform!
        case .ended:
            if recognizer is UIRotationGestureRecognizer {
                self.referenceRotateTransform = self.apply(recognizer: recognizer, transform: self.referenceRotateTransform!)
                self.currentRotateTransform = self.referenceRotateTransform!
                self.activeRotateRecognizer = nil
            }
            else if recognizer is UIPinchGestureRecognizer {
                self.textScale *= (recognizer as! UIPinchGestureRecognizer).scale
                self.activePinchRecognizer = nil
            }
        default:
            break
        }
    }
    
    private func apply(recognizer: UIGestureRecognizer?, transform: CGAffineTransform) -> CGAffineTransform {
        if let rotate = recognizer as? UIRotationGestureRecognizer {
            return transform.rotated(by: rotate.rotation)
        }
        else if recognizer is UIPinchGestureRecognizer {
            let scale = (recognizer as! UIPinchGestureRecognizer).scale
            return transform.scaledBy(x: scale, y: scale)
        }
        else {
            return transform
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.isShowingTextView = true
        self.colorSlider?.isHidden = false
        self.textView?.isScrollEnabled = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.textViewFitContent()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            self.isShowingTextView = false
            self.textViewContainer?.isHidden = false
            self.colorSlider?.isHidden = true
            self.textView?.isScrollEnabled = true
        }
        return true
    }
    
    // MARK: - HRColorSliderDelegate
    
    func colorPicked(color: UIColor) {
        self.selectedColor = color
        self.textView?.textColor = color
    }
    
    // MARK: - Action
    
    @objc private func backButtonTouchUpInside(_ sender: UIButton) {
        if self.isShowingTextView {
            self.isShowingTextView = false
            self.textViewContainer?.isHidden = false
            self.colorSlider?.isHidden = true
            self.textView?.resignFirstResponder()
        } else {
            // dismiss or pop
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func addTextButtonTouchUpInside(_ sender: UIButton) {
        self.setupTextViewContainerIfNeeded()
        self.bringViewToFront(views: [self.backButton,self.addTextButton], superView: self.view)
        self.textView?.becomeFirstResponder()
    }
    
    @objc private func okButtonTouchUpInside(_ sender: UIButton) {
        
    }

}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return boundingBox.height
    }
}
