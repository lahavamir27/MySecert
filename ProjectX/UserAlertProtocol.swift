//
//  UserAlertProtocol.swift
//  ProjectX
//
//  Created by amir lahav on 5.12.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import  UIKit

protocol UserAlertProtocol {
    func userAlert(title:String, message:String)
}

extension UserAlertProtocol where Self:UIViewController
{
    func userAlert(title:String, message:String)
    {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                alertController.dismiss(animated: true, completion: {
                })
            }))
            self.present(alertController, animated: true, completion: nil)
        }        
    }

}
