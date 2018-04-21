//
//  UserSettingHelper.swift
//  ProjectX
//
//  Created by amir lahav on 30.12.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import UIKit


struct UserSettingHelper {
    
    let defaults = UserDefaults.standard

    var themeColorValue:ThemeColor {
        set
        {
            defaults.set(newValue.rawValue, forKey: UserDefaultsKeys.themeColorValue.rawValue )
            UserDefaults.standard.synchronize()

        }
        get
        {
            guard let colorValue = defaults.value(forKey: UserDefaultsKeys.themeColorValue.rawValue) as? String else { return .Blue}
            guard let themeValue =  ThemeColor(rawValue:colorValue) else {return .Blue}
            return themeValue
        }
    }
    
    var autoDelete:Bool {
        set
        {
            defaults.set(newValue, forKey: UserDefaultsKeys.autoDelete.rawValue)
            UserDefaults.standard.synchronize()

        }
        get
        {
            return defaults.bool(forKey:UserDefaultsKeys.autoDelete.rawValue)
        }
    }
    
    var autoExporterBool:Bool {
        set
        {
            defaults.set(newValue, forKey: UserDefaultsKeys.autoExporter.rawValue)
            UserDefaults.standard.synchronize()

        }
        get
        {
            return defaults.bool(forKey:UserDefaultsKeys.autoExporter.rawValue)
        }
    }
}



enum UserDefaultsKeys:String {
    case themeColor
    case themeColorValue
    case autoDelete
    case autoExporter
}
