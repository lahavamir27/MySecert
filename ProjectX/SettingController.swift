//
//  SettingController.swift
//  ProjectX
//
//  Created by amir lahav on 27.11.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//
import Foundation
import Eureka
import UIKit

class SettingController: FormViewController {
    
    var settingHelper = UserSettingHelper()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.navigationItem.title = "Setting"
        
       form +++ Section()
            <<< ButtonRow() {
                $0.title = "Tell a Friend"
                }.cellUpdate { cell, row in
                    cell.textLabel?.textAlignment = .left
        }
            <<< ButtonRow() {
                $0.title = "About"
                }.cellUpdate { cell, row in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = .black
        }
        
        
        +++ Section(header: "Setting", footer: "Media will automatically delete from Camera Roll")
            
            <<< ActionSheetRow<ThemeColor>() {[unowned self] in
                $0.title = "Theme Color"
                $0.selectorTitle = "Pick a color"
                $0.options = [.Blue,.Black,.Purple]
                $0.value = self.settingHelper.themeColorValue  // initially selected
                }.onChange({ [unowned self] (cell) in 
                    self.settingHelper.themeColorValue = cell.value!
                    ThemeManager.applayTheme(theme: cell.value!)
                })
        
            <<< SwitchRow() {
                $0.title = "Automatic Delete"
                $0.value = true
                }.onChange({ (row) in
                })
            
            +++ Section(footer: "Automatically save photos and videos in your Camera Roll")
            
            <<< SwitchRow() {
                $0.title = "Save to Camera Roll"
                $0.value = false
                }.onChange({ (row) in
                })
        

        
        +++ Section()
        <<< ButtonRow() {
            $0.title = "Special Thanks"
            }.cellUpdate { cell, row in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = .black

        }
        
        }
    
        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = .white
            }
        
        }
    
        func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
            
            if let header = view as? UITableViewHeaderFooterView {
                header.backgroundView?.backgroundColor = .white
            }
        }
}

