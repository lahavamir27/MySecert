//
//  UIColor + Extention.swift
//  PhotoViewer
//
//  Created by amir lahav on 14.1.2017.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import UIKit


extension UIColor
{
    class func secretRed() -> UIColor
    {
        return UIColor(red: 1, green: 59/255, blue: 48/255, alpha: 1)
    }
    class func secretBlue() -> UIColor
    {
        return UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
    }
    class func secretPurple() -> UIColor
    {
        return UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1)
    }
    class func secretYellow() -> UIColor
    {
        return UIColor(red: 255, green: 204/255, blue: 0/255, alpha: 1)
    }
    class func secretTealBlue() -> UIColor
    {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1)
    }
    class func secretGreen() -> UIColor
    {
        return UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
    }
    class func secretPink() -> UIColor
    {
        return UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
    }
    class func secretOrange() -> UIColor
    {
        return UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
    }
    class func secretGray() -> UIColor
    {
        return UIColor(red: 135/255, green: 135/255, blue: 135/255, alpha: 1)
    }
}

extension UserDefaults {
    func set(_ color: UIColor, forKey key: String) {
        set(NSKeyedArchiver.archivedData(withRootObject: color), forKey: key)
    }
    func color(forKey key: String) -> UIColor? {
        guard let data = data(forKey: key) else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? UIColor
    }
}


protocol TintColor  {
    var tintColor: UIColor! { get set }
}

extension TintColor 
{
    var tintColor:UIColor! {
        return UIColor.secretRed()
    }
}
