//
//  PhotoPermissionAlertController.swift
//  ProjectX
//
//  Created by amir lahav on 25.1.2018.
//  Copyright © 2018 LA Computers. All rights reserved.
//

import UIKit

class PhotoPermissionAlertController: UIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ohh No "
        self.message = "The Photo Library permission was not authorized. Please press Photos in Settings to enable it."
        
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            
            // THIS IS WHERE THE MAGIC HAPPENS!!!!
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: { (succ) in
                    
                })
            }
        }
        self.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        self.addAction(cancelAction)

        // Do any additional setup after loading the view.
    }
           

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
