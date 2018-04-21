//
//  CollectionViewToolBar.swift
//  MySecret
//
//  Created by amir lahav on 2.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit

protocol ToolbarButtonsProtocol:class {

    func toolBarBtnDidPress(sender:ToolbarButtonsType)

}


class CollectionViewToolBar: UIToolbar {

    weak var delegateToolBar: ToolbarButtonsProtocol?
    
    fileprivate var spaceButton = UIBarButtonItem()
    fileprivate var trashBtn = UIBarButtonItem()
    fileprivate var addToBtn = UIBarButtonItem()
    fileprivate var addBtn = UIBarButtonItem()
    fileprivate var selectAllBtn = UIBarButtonItem()
    fileprivate var deSelectAllBtn = UIBarButtonItem()

    fileprivate var kToolBarHeight:CGFloat {
        
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight, .portraitUpsideDown:
            return 32.0
        default:
            return 44.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initBtn()
    }
    
    func initBtn()
    {
        spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        spaceButton.toolbarButtonType = .unknown
        trashBtn = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(btnDidPress(sender:)))
        trashBtn.toolbarButtonType = .trash
        addToBtn = UIBarButtonItem(title: "Add To", style: .plain, target: self, action: #selector(btnDidPress(sender:)))
        addToBtn.toolbarButtonType = .addTo
        addBtn = UIBarButtonItem(title: "Add", style: .plain, target: self, action:#selector(btnDidPress(sender:)))
        addBtn.toolbarButtonType = .add
        selectAllBtn = UIBarButtonItem(title: "Select All", style: .plain, target: self, action:#selector(btnDidPress(sender:)))
        selectAllBtn.toolbarButtonType = .selectAll
        deSelectAllBtn = UIBarButtonItem(title: "Deselect All", style: .plain, target: self, action:#selector(btnDidPress(sender:)))
        deSelectAllBtn.toolbarButtonType = .deSelectAll
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateToolBarButton(isUserAlbum:Bool, selectedPhotos:Int)
    {

        switch (selectedPhotos, isUserAlbum) {
        case (0, true):
            self.setItems([spaceButton, addBtn ,spaceButton, trashBtn], animated: true)
            self.enableButton()
            self.disableLast()
        case (0, false):
            self.setItems([selectAllBtn, spaceButton, addToBtn ,spaceButton, trashBtn], animated: true)
            self.disableButton()
            self.enableFirst()
        default:
            self.setItems([selectAllBtn, spaceButton, addToBtn ,spaceButton, trashBtn], animated: true)
            self.enableButton()
        }
    }
    
    @IBAction func btnDidPress(sender:UIBarButtonItem)
    {
        delegateToolBar?.toolBarBtnDidPress(sender:sender.toolbarButtonType)
        swithSelectAl(sender: sender.toolbarButtonType)
    }
    
    func swithSelectAl(sender: ToolbarButtonsType)
    {
        switch sender {
        case .selectAll:
            self.setItems([deSelectAllBtn, spaceButton, addToBtn ,spaceButton, trashBtn], animated: true)
        case .deSelectAll:
            self.setItems([selectAllBtn, spaceButton, addToBtn ,spaceButton, trashBtn], animated: true)
        default: break
        }
    }
        
    func updateToolbarFrame()
    {
        self.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - kToolBarHeight, width: UIScreen.main.bounds.size.width, height: kToolBarHeight)
    }
    
    deinit {
        print("deinit tool bar")
    }
 }


enum ToolbarButtonsType:String {
    
    // tool bar buttons
    case unknown
    case addTo
    case add
    case trash
    case selectAll
    case deSelectAll
    
    var description: String {
        return "\(hashValue) did press"
    }
}








protocol NavigatinoBarButtonsProtocol:class {
    
    func navigationBarButtonDidPress(sender:NavigationBarButtonsType)
}

class NavigationBarButton: UIBarButtonItem {
    
    weak var buttonDelegate:NavigatinoBarButtonsProtocol?
    
    convenience init(buttonType:NavigationBarButtonsType) {
        
        switch buttonType {
        case .select:
            self.init(title: "Select", style: .plain, target: nil, action:#selector(self.btnDidPress(sender:)))
            self.navigationBarButtonType = .select
        case .cancel:
            self.init(title: "Cancel", style: .done, target: nil, action:#selector(self.btnDidPress(sender:)))
            self.navigationBarButtonType = .cancel

        case .back:
            self.init(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action:#selector(self.btnDidPress(sender:)))
            self.imageInsets = UIEdgeInsetsMake(0, -8, 0, 0)
            self.navigationBarButtonType = .back

        case .detail:
            self.init(title: "Details", style: .plain, target: nil, action:#selector(self.btnDidPress(sender:)))
            self.navigationBarButtonType = .detail

        case .newPhoto:
            self.init(image: #imageLiteral(resourceName: "camera_44_line.png"), style: .plain, target: nil, action:#selector(self.btnDidPress(sender:)))
            self.imageInsets = UIEdgeInsetsMake(0, -4, 0, 0)
            self.navigationBarButtonType = .newPhoto

        case .newAlbum:
            self.init(barButtonSystemItem: .add, target: nil, action:#selector(self.btnDidPress(sender:)))
            self.navigationBarButtonType = .newAlbum

        case .editAlbum:
            self.init(title: "Edit", style: .plain, target: nil, action:#selector(self.btnDidPress(sender:)))
            self.navigationBarButtonType = .editAlbum

        case .doneEditAlbum:
            self.init(title: "Done", style: .done, target: nil, action:#selector(self.btnDidPress(sender:)))
            self.navigationBarButtonType = .doneEditAlbum

        case .search:
            self.init(barButtonSystemItem: .search, target: nil, action:#selector(self.btnDidPress(sender:)))
            self.navigationBarButtonType = .search

        case .lightCancel:
            self.init(title: "Cancel", style: .plain, target: nil, action:#selector(self.btnDidPress(sender:)))
            self.navigationBarButtonType = .lightCancel

        case .unknown:
            print("asked for unknown button")
            self.init()
            self.navigationBarButtonType = .unknown

        case .pan:
            let panBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            panBtn.setImage(#imageLiteral(resourceName: "icons8-pencil-72"), for: .normal)
            panBtn.imageEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
            panBtn.userButtonType = .pan
            self.init(customView: panBtn)
            panBtn.addTarget(self, action: #selector(self.customBtnPress(sender:)), for: .touchUpInside)
            self.action = #selector(self.btnDidPress(sender:))
            self.navigationBarButtonType = .pan
        
        case .text:
            let textBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            textBtn.setImage(#imageLiteral(resourceName: "Aa"), for: .normal)
            textBtn.userButtonType = .text
            textBtn.imageEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
            self.init(customView: textBtn)
            textBtn.addTarget(self, action: #selector(self.customBtnPress(sender:)), for: .touchUpInside)
            self.navigationBarButtonType = .text
       
        case .newLabel:
            let newLabelBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            newLabelBtn.setImage(#imageLiteral(resourceName: "icons8-happy-72-2 copy.png"), for: .normal)
            newLabelBtn.userButtonType = .newLabel
            newLabelBtn.imageEdgeInsets = UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0)
            self.init(customView: newLabelBtn)
            newLabelBtn.addTarget(self, action: #selector(self.customBtnPress(sender:)), for: .touchUpInside)
            self.navigationBarButtonType = .newLabel
        case .space:
            self.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        case .filter:
            self.init(title: "Filter", style: .plain, target: nil, action:#selector(self.btnDidPress(sender:)))
            self.navigationBarButtonType = .filter
        case .paint:
            self.init(title: "Paint", style: .plain, target: nil, action:#selector(self.btnDidPress(sender:)))
            self.navigationBarButtonType = .paint
        case .FX:
            self.init(title: "FX", style: .plain, target: nil, action:#selector(self.btnDidPress(sender:)))
            self.navigationBarButtonType = .FX
        }
        

    }
    
    func customBtnPress(sender:UIButton)
    {
        switch sender.userButtonType {
        case .pan:
            buttonDelegate?.navigationBarButtonDidPress(sender:.pan)
        case .text:
            buttonDelegate?.navigationBarButtonDidPress(sender:.text)
        case .newLabel:
            buttonDelegate?.navigationBarButtonDidPress(sender:.newLabel)
        default:print("unknow button press")
        }
    }
    
    @IBAction func btnDidPress(sender:NavigationBarButton)
    {
        buttonDelegate?.navigationBarButtonDidPress(sender:sender.navigationBarButtonType)
    }
}


enum NavigationBarButtonsType:String {
    
    // navigation bar buttons
    
    case unknown
    case select
    case cancel
    case back
    case detail
    case newPhoto
    case newAlbum
    case editAlbum
    case doneEditAlbum
    case search
    case lightCancel
    case pan
    case text
    case newLabel
    case space
    case filter
    case paint
    case FX
    
    var description: String {
        return "\(rawValue) did press"
    }
}


private var AssociatedObjectHandle: ToolbarButtonsType = .unknown

extension UIBarButtonItem
{
    var toolbarButtonType:ToolbarButtonsType {
        get {
            if let btn = objc_getAssociatedObject(self, &AssociatedObjectHandle) as? ToolbarButtonsType {
                return btn
            }
            return .unknown
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var navigationBarButtonType:NavigationBarButtonsType {
        get {
            if let btn = objc_getAssociatedObject(self, &AssociatedObjectHandle) as? NavigationBarButtonsType {
                return btn
            }
            return .unknown
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
