//
//  ImageScrollView.swift
//  Beauty
//
//  Created by Nguyen Cong Huy on 1/19/16.
//  Copyright © 2016 Nguyen Cong Huy. All rights reserved.
//

import UIKit


protocol ImageZoomedDelegate:class {
    
    func imageViewDidEndZoomingInOriginalSize(originalSize : Bool)
    func tapOnce()
    func dragFromTop()
}


class ImageScrollView: UIScrollView, GeustureHendler {
    
    static let kZoomInFactorFromMinWhenDoubleTap: CGFloat = 2
    weak var zoomDelegate: ImageZoomedDelegate?
    var zoomView: UIImageView? = nil
    var imageSize: CGSize = CGSize.zero
    fileprivate var pointToCenterAfterResize: CGPoint = CGPoint.zero
    fileprivate var scaleToRestoreAfterResize: CGFloat = 1.0
    var maxScaleFromMinScale: CGFloat = 3.0
    var isZoom: Bool = false
    var originalFrame: CGRect = CGRect.zero
    
    override open var frame: CGRect {
        willSet {
            if frame.equalTo(newValue) == false && newValue.equalTo(CGRect.zero) == false && imageSize.equalTo(CGSize.zero) == false {
                prepareToResize()
            }
        }
        
        didSet {
            if frame.equalTo(oldValue) == false && frame.equalTo(CGRect.zero) == false && imageSize.equalTo(CGSize.zero) == false {
                recoverFromResizing()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        originalFrame = frame
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    fileprivate func initialize() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        decelerationRate = UIScrollViewDecelerationRateFast
        delegate = self
    }
    
    func tapZoom() {
        if isZoom {
            self.setZoomScale(minimumZoomScale, animated: true)
        } else {
            self.setZoomScale(maximumZoomScale, animated: true)
        }
    }
    
    
    func adjustFrameToCenter() {
        
        guard zoomView != nil else {
            return
        }
        
        var frameToCenter = zoomView!.frame
        
        // center horizontally
        if frameToCenter.size.width < bounds.width {
            frameToCenter.origin.x = (bounds.width - frameToCenter.size.width) / 2
        }
        else {
            frameToCenter.origin.x = 0
        }
        
        // center vertically
        if frameToCenter.size.height < bounds.height {
            frameToCenter.origin.y = (bounds.height - frameToCenter.size.height) / 2
        }
        else {
            frameToCenter.origin.y = 0
        }
        
        zoomView!.frame = frameToCenter
    }
    
    fileprivate func prepareToResize() {
        let boundsCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        pointToCenterAfterResize = convert(boundsCenter, to: zoomView)
        
        scaleToRestoreAfterResize = zoomScale
        
        // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
        // allowable scale when the scale is restored.
        if scaleToRestoreAfterResize <= minimumZoomScale + CGFloat(Float.ulpOfOne) {
            scaleToRestoreAfterResize = 0
        }
    }
    
    fileprivate func recoverFromResizing() {
        setMaxMinZoomScalesForCurrentBounds()
        
        // restore zoom scale, first making sure it is within the allowable range.
        let maxZoomScale = max(minimumZoomScale, scaleToRestoreAfterResize)
        zoomScale = min(maximumZoomScale, maxZoomScale)
        
        // restore center point, first making sure it is within the allowable range.
        
        // convert our desired center point back to our own coordinate space
        let boundsCenter = convert(pointToCenterAfterResize, to: zoomView)
        
        // calculate the content offset that would yield that center point
        var offset = CGPoint(x: boundsCenter.x - bounds.size.width/2.0, y: boundsCenter.y - bounds.size.height/2.0)
        
        // restore offset, adjusted to be within the allowable range
        let maxOffset = maximumContentOffset()
        let minOffset = minimumContentOffset()
        
        var realMaxOffset = min(maxOffset.x, offset.x)
        offset.x = max(minOffset.x, realMaxOffset)
        
        realMaxOffset = min(maxOffset.y, offset.y)
        offset.y = max(minOffset.y, realMaxOffset)
        
        contentOffset = offset
    }
    
    fileprivate func maximumContentOffset() -> CGPoint {
        return CGPoint(x: contentSize.width - bounds.width,y:contentSize.height - bounds.height)
    }
    
    fileprivate func minimumContentOffset() -> CGPoint {
        return CGPoint.zero
    }
    
    // MARK: - Display image
    
    open func display(image: UIImage) {
        
        if let zoomView = zoomView {
            zoomView.removeFromSuperview()
        }
        
        zoomView = UIImageView(image: image)
        zoomView!.isUserInteractionEnabled = true
        addSubview(zoomView!)
        
        let tapOnceGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOnceGuestre))
        tapOnceGesture.numberOfTapsRequired = 1
        zoomView!.addGestureRecognizer(tapOnceGesture)
        
        let tapTwiceGesture = UITapGestureRecognizer(target: self, action: #selector(ImageScrollView.doubleTapGestureRecognizer(_:)))
        tapTwiceGesture.numberOfTapsRequired = 2
        zoomView!.addGestureRecognizer(tapTwiceGesture)
        
        
        tapOnceGesture.require(toFail: tapTwiceGesture)
        configureImageForSize(size: image.size)
    }
    
    func tapOnceGuestre()
    {
        if let delegate = zoomDelegate
        {
            delegate.tapOnce()
        }
        print("tap once")
    }
    
    fileprivate func configureImageForSize( size: CGSize) {
        let size = size
        imageSize = size
        contentSize = imageSize
        setMaxMinZoomScalesForCurrentBounds()
        zoomScale = minimumZoomScale
        contentOffset = CGPoint.zero
    }
    
    fileprivate func setMaxMinZoomScalesForCurrentBounds() {
        // calculate min/max zoomscale
        
        
        let xScale = bounds.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = bounds.height / imageSize.height   // the scale needed to perfectly fit the image height-wise
        
        
        // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
        
        let imagePortrait = imageSize.height > imageSize.width
        let phonePortrait = bounds.height >= bounds.width
        
        var minScale = (imagePortrait == phonePortrait) ? xScale : min(xScale, yScale)
        
        
        switch (xScale,yScale) {
        case let (xScale,yScale) where xScale > 1.0  && yScale > 1.0:
            //            print("both bigger")
            minScale = min(xScale, yScale)
        case let (xScale,yScale) where xScale < 1.0  && yScale > 1.0:
            //            print("x smaller than 1, y bigger than 1")
            minScale = xScale
        case let (xScale,yScale) where xScale > 1.0  && yScale < 1.0:
            //            print("x bigger than 1, y smaller than 1")
            minScale = yScale
        case let (xScale,yScale) where xScale < 1.0  && yScale < 1.0:
            //            print("x smaller than 1, y smaller than 1")
            minScale = min(xScale, yScale)
        default: break
            //            print("you are stupid")
        }
        
        
        let maxScale = maxScaleFromMinScale*minScale
        
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
        
        if minScale > maxScale {
            minScale = maxScale
        }
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale
        // the multiply factor to prevent user cannot scroll page while they use this control in UIPageViewController
    }
    
    // MARK: - Gesture
    
    func doubleTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        tapZoom()
        if !isZoom {
            isZoom = true
        }else
        {
            isZoom = false
        }
    }
    
    fileprivate func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        
        // the zoom rect is in the content view's coordinates.
        // at a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
        // as the zoom scale decreases, so more content is visible, the size of the rect grows.
        zoomRect.size.height = frame.size.height / scale
        zoomRect.size.width  = frame.size.width  / scale
        
        // choose an origin so as to get the right center.
        zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0)
        zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
    open func refresh() {
        if let image = zoomView?.image {
            display(image: image)
        }
    }
}

extension ImageScrollView: UIScrollViewDelegate{
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustFrameToCenter()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y < -50
        {
                zoomDelegate?.dragFromTop()
        }
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if zoomDelegate != nil
        {
            zoomDelegate?.imageViewDidEndZoomingInOriginalSize(originalSize: minimumZoomScale == scale)
        }
    }
    
}
