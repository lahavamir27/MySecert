//
//  SourcePickerViewController.swift
//  MySecret
//
//  Created by amir lahav on 28.8.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit


protocol ExportAlertProtocol:class {
    func export()
    func dismiss()
}

class ExportAlertController: UIAlertController {
    
    weak var delegate:ExportAlertProtocol?
    
    convenience init(titleAlert:String)
    {
        self.init()
        
        title = titleAlert
        
            self.addAction(UIAlertAction(title: "Export", style: .destructive, handler: {[weak self] (alertAction) in
                self?.delegate?.export()
                self?.dismiss(animated: true, completion: {
                    
                })
            }))

        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self] (alertAction) in
            
            self?.delegate?.dismiss()
            
            self?.dismiss(animated: true, completion: {
            })
        }))
        
    }
    deinit {
        print("deinit exporter alert")
    }
    
}

