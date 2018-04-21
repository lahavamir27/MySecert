import UIKit




protocol ViewAction: UIGestureRecognizerDelegate {
    var view: UIView { get }
}

extension ViewAction where Self:UIView
{
    var view: UIView { get { return self } }
    
}


protocol Draggable:class, ViewAction {
    
    var initialLocation: CGPoint { get set }
    
    func registerDraggability()
    func removeDraggability()
    func didPan(panGesture: UIPanGestureRecognizer)
}

extension Draggable where Self: UIView {
    
    var parentView: UIView? { get { return self.view.superview } }
    
    func registerDraggability() {
        let panGesture = UIPanGestureRecognizer()
        print("register")
        panGesture.handler = { gesture in
            gesture.delegate = self
            self.didPan(panGesture: gesture as! UIPanGestureRecognizer)
        }
        self.view.addGestureRecognizer(panGesture)
    }
    
    func didPan(panGesture: UIPanGestureRecognizer) {
        
        if panGesture.state == .began{
            print("began")
        }
        let translation = panGesture.translation(in: self.superview)
        self.view.center = CGPoint(x:self.initialLocation.x + translation.x, y: self.initialLocation.y + translation.y)
        if  panGesture.state == .ended
        {
            initialLocation = (self.superview?.convert(self.view.center, to: self.superview))!
        }
    }
    
    func removeDraggability() {
        print("Remove register")
        guard self.gestureRecognizers != nil else {
            return
        }
        let _ = self.gestureRecognizers!
            .filter({ $0.delegate is UIGestureRecognizer.GestureDelegate })
            .map({ self.removeGestureRecognizer($0) })
    }
    
}

protocol Rotateable: class, ViewAction {
    
    var lastRotation: CGFloat {get set}
    func registerRotateability()
    func removeRotateability()
    func didRotate(rotateGesture:  UIRotationGestureRecognizer)
}


extension Rotateable where Self: UIView {

    var parentView: UIView? { get { return self.view.superview } }
    var lastRotation:CGFloat  {
        get {
            return self.lastRotation
        }
        set{
            self.lastRotation = newValue
        }
    }
    
    func registerRotateability() {
        let rotateGesture = UIRotationGestureRecognizer()
        rotateGesture.handler = { gesture in
            gesture.delegate = self
            self.didRotate(rotateGesture: gesture as! UIRotationGestureRecognizer)
        }
        self.view.addGestureRecognizer(rotateGesture)
    }
    
    func removeRotateability() {
        guard self.gestureRecognizers != nil else {
            return
        }
        let _ = self.gestureRecognizers!
            .filter({ $0.delegate is UIGestureRecognizer.GestureDelegate })
            .map({ self.removeGestureRecognizer($0) })
    }
    
    func didRotate(rotateGesture:  UIRotationGestureRecognizer)
    {

        var originalRotation = CGFloat()

        switch rotateGesture.state {

        case .possible:
            break
        case .began:
            rotateGesture.rotation = lastRotation
            originalRotation = rotateGesture.rotation
        case .changed:
            let newRotation = rotateGesture.rotation + originalRotation
            rotateGesture.view?.transform = CGAffineTransform(rotationAngle: newRotation)
        case .ended:
            lastRotation = rotateGesture.rotation
            rotateGesture.rotation = 0.0
            break
        case .cancelled:
            break
        case .failed:
            break
        }
    }

}



protocol Scaleable: class, ViewAction {
    
    var lastScale: CGFloat {get set}

    func registerRotateability()
    func removeRotateability()
    func didScale(scaleGesture:  UIPinchGestureRecognizer)
}


extension Scaleable where Self: UIView {

    
    func registerScaleability() {
        let rotateGesture = UIPinchGestureRecognizer()
        rotateGesture.handler = { gesture in
            gesture.delegate = self
            self.didScale(scaleGesture: gesture as! UIPinchGestureRecognizer)
        }
        self.view.addGestureRecognizer(rotateGesture)
    }
    
    func removeScaleability() {
        guard self.gestureRecognizers != nil else {
            return
        }
        let _ = self.gestureRecognizers!
            .filter({ $0.delegate is UIGestureRecognizer.GestureDelegate })
            .map({ self.removeGestureRecognizer($0) })
    }
    
    func didScale(scaleGesture:  UIPinchGestureRecognizer)
    {
        var originalScale = CGFloat()
        
        switch scaleGesture.state {


        case .began:
            scaleGesture.scale = lastScale
            originalScale = scaleGesture.scale
        case .changed:
            let newScale = scaleGesture.scale + originalScale
            self.transform = CGAffineTransform(scaleX: newScale, y: newScale)
        case .ended:
            lastScale = scaleGesture.scale
        case .cancelled:
            break
        case .failed:
            break
        case .possible:
            break
        }
    }

    
}

extension UIGestureRecognizer {
   
    private class ClosureWrapper: NSObject {
        
        let handler: (UIGestureRecognizer) -> Void
        
        init(handler: @escaping (UIGestureRecognizer) -> Void) {
            self.handler = handler
        }
    }
    
    class GestureDelegate: NSObject, UIGestureRecognizerDelegate {
        static var delegateKey: String = "delegateKey"
        @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return gestureRecognizer.delegate is GestureDelegate && otherGestureRecognizer.delegate is GestureDelegate
        }
        
        @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            return true
        }
        
        @objc func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
    
    private var multiDelegate: GestureDelegate {
        get {
            return objc_getAssociatedObject(self, &GestureDelegate.delegateKey) as! GestureDelegate
        }
        set {
            objc_setAssociatedObject(self, &GestureDelegate.delegateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private static var handlerKey: String = "handlerKey"
    var handler: (UIGestureRecognizer) -> Void {
        get {
            let closureWrapper: ClosureWrapper = objc_getAssociatedObject(self, &UIGestureRecognizer.handlerKey) as! ClosureWrapper
            return closureWrapper.handler
        }
        set {
            self.addTarget(self, action: #selector(UIGestureRecognizer.handleAction))
            self.multiDelegate = GestureDelegate()
            self.delegate = self.multiDelegate
            objc_setAssociatedObject(self, &UIGestureRecognizer.handlerKey, ClosureWrapper(handler: newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func handleAction() {
        self.handler(self)
    }
}




