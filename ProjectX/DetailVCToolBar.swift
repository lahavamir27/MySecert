//
//  DetailVCToolBar.swift
//  MySecret
//
//  Created by amir lahav on 2.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit


protocol DetailVCToolBarDelegate:class {

    func toolBarBtnDidPress(sender:ToolbarBtnType)
}

class DetailVCToolBar: UIToolbar {

    weak var delegateToolBar: DetailVCToolBarDelegate?
    
    fileprivate let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    fileprivate var pauseBtn = UIBarButtonItem()
    fileprivate var trashBtn = UIBarButtonItem()
    fileprivate var likeBtn:UIBarButtonItem = UIBarButtonItem()
    fileprivate var editBtn = UIBarButtonItem()
    
    init(frame: CGRect, state:ToolBarState) {
        super.init(frame: frame)
        initBtn()
        self.clipsToBounds = true
        addNormalStateButtons()
        barState = state
    }
    
    
    func initBtn()
    {
        pauseBtn = UIBarButtonItem(image:#imageLiteral(resourceName: "pause"), style: .plain, target: self, action: #selector(btnDidPress(sender:)))
        pauseBtn.btnType = .pause
        
        trashBtn = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(btnDidPress(sender:)))
        trashBtn.btnType = .trash

//        editBtn = UIBarButtonItem(image:#imageLiteral(resourceName: "photoEdit"), style: .plain, target: self, action:#selector(btnDidPress(sender:)))
        editBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(btnDidPress(sender:)))
        editBtn.btnType = .edit

        likeBtn = UIBarButtonItem(image:#imageLiteral(resourceName: "Like-50"), style: .plain, target: self, action: #selector(btnDidPress(sender:)))
        likeBtn.btnType = .like
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var kToolBarHeight:CGFloat {
       
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight, .portraitUpsideDown:
            return 32.0
        default:
            return 44.0
        }
    }
    
    fileprivate var barState:ToolBarState = .normal
    {
        didSet
        {
            self.removeButtons()
            switch barState {
            case .normal: addNormalStateButtons()
            case .playVideo: addPlayMovieButtons()
            }
        }
    }
    
    public func setToolBar(state: ToolBarState)
    {
        barState = state
    }
    
    func addNormalStateButtons()
    {
        self.setItems([editBtn, spaceButton, likeBtn ,spaceButton, trashBtn], animated: true)
    }
    
    func addPlayMovieButtons()
    {
        self.setItems([spaceButton, pauseBtn ,spaceButton], animated: true)
    }
    
    @IBAction func btnDidPress(sender:UIBarButtonItem)
    {
        delegateToolBar?.toolBarBtnDidPress(sender:sender.btnType)
    }
    
    
    deinit {
        print("detailVC tool bar deinit")
    }
    
    func updateLikeButton(like:Bool){likeBtn.image = like ? #imageLiteral(resourceName: "Like Filled") : #imageLiteral(resourceName: "Like-50")}
    
    
    
    func updateToolbarFrame(size:CGSize)
    {
        self.frame = CGRect(x: 0, y: size.height - kToolBarHeight, width: size.width, height: kToolBarHeight)
    }


}



enum ToolBarState
{
    case normal
    case playVideo
}

enum ToolbarBtnType
{
    case share
    case edit
    case like
    case pause
    case trash
    case unkonw
}

private var AssociatedObjectHandle: ToolbarBtnType = .unkonw


extension UIBarButtonItem
{
    var btnType:ToolbarBtnType {
        get {
            if let btn = objc_getAssociatedObject(self, &AssociatedObjectHandle) as? ToolbarBtnType {
                return btn
            }
            return .unkonw
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
