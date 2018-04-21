//
//  UIToolbar + Extention.swift
//  PhotoViewer
//
//  Created by amir lahav on 4.11.2016.
//  Copyright © 2016 Nathan Blamires. All rights reserved.
//

import UIKit



extension UIToolbar
{
    
    func disableButton() {
        guard !(self.items?.isEmpty)! else {
            return
        }
        for item:UIBarButtonItem in self.items!
        {
            item.isEnabled = false
        }
    }
    
    func enableButton()
    {
        guard !(self.items?.isEmpty)! else {
            return
        }
        for item:UIBarButtonItem in self.items!
        {
            item.isEnabled = true
        }
        
    }
    
    func enableFirst()
    {
        guard let items = self.items else {
            return
        }
        items.first?.isEnabled = true
    }
    
    func disableLast()
    {
        guard let items = self.items else {
            return
        }
        items.last?.isEnabled = false
    }
    
    func removeButtons()
    {
        guard var items = self.items else {
            return
        }
        items.removeAll()
    }
    
    func updateBarItems(buttonType:[NavigationBarButtonsType?],delegate: UIViewController)
    {
        self.items = nil
        var barButtonItem = [UIBarButtonItem]()
        
        for button in buttonType{
            guard let buttonType = button else { return }
            let NCRightButton = NavigationBarButton.init(buttonType: buttonType)
            NCRightButton.buttonDelegate = delegate as? NavigatinoBarButtonsProtocol
            barButtonItem.append(NCRightButton)
        }
        self.items = barButtonItem
    }
    
    func updateButtonTint(color:UIColor, atIndex:Int)
    {
        guard let items = self.items else {return}
        if items.indices.contains(atIndex){
            let button = items[atIndex]
            button.tintColor = color
            print(button)
        }

    }
}
