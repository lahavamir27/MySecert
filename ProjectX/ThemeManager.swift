//
//  ThemeManager.swift
//  ProjectX
//
//  Created by amir lahav on 30.12.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import UIKit

class ThemeManager
{
    static var userSettingManager = UserSettingHelper()
    
    static func currentTheme() -> ThemeColor
    {
        return  userSettingManager.themeColorValue
    }
    
    static func applayTheme(theme:ThemeColor)
    {
        
        UINavigationBar.appearance().tintColor = theme.tintColor
        UIToolbar.appearance().tintColor = theme.tintColor
        UITabBar.appearance().tintColor = theme.tintColor
        guard let tabbar =  UIApplication.shared.keyWindow?.rootViewController as? UITabBarController else { return }
        tabbar.tabBar.tintColor = theme.tintColor

    }
}


enum ThemeColor: String{
    
    case Blue = "Blue"
    case Black = "Black"
    case Purple = "Purple"
    
    
    var tintColor:UIColor
    {
        switch self {
        case .Blue:     return UIColor.secretBlue()
        case .Black:    return UIColor.black
        case .Purple:   return UIColor.secretPurple()
        }
    }

}
