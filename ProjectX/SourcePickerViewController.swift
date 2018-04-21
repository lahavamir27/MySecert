//
//  SourcePickerViewController.swift
//  MySecret
//
//  Created by amir lahav on 28.8.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit


protocol SourceAlertProtocol:class {
    func showLibrary()
    func dismissPicker()
}

class SourcePickerViewController: UIAlertController {

    
    weak var delegate:SourceAlertProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var showLibrary:()->() = { _ in }

    convenience init(titleAlert:String)
    {
        self.init()
        
        title = titleAlert
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
        {
        self.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {[weak self] (alertAction) in
            self?.delegate?.showLibrary()
                self?.dismiss(animated: true, completion: {
                    
                })
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
            self.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alertAction) in
  
                self.dismiss(animated: true, completion: {
                    
                })
            }))
            
        }
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self] (alertAction) in
            
            self?.delegate?.dismissPicker()

            self?.dismiss(animated: true, completion: {
            })
        }))

    }
    deinit {
        print("deinit picker")
    }
    
}
