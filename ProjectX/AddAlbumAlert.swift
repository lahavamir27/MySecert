//
//  AddAlbumAlert.swift
//  ProjectX
//
//  Created by amir lahav on 18.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit

protocol AddAlbumProtocol:class {

    func saveNewAlbum(name: String)
    func cancelDidPress()
}



class AddAlbumAlert: UIAlertController {

 
    fileprivate var inputTextField: UITextField?
    weak var albumDelegate:AddAlbumProtocol?
    
    
    func addButtonsToAlert()
    {
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) {[weak self] (action) in
            self?.cancelDidPress()
            //Do some stuff
        }
        self.addAction(cancelAction)
        //Create and an option action
        let saveAction: UIAlertAction = UIAlertAction(title: "Save", style: .default) {[weak self] (action) in
            
            let albumName = (self?.inputTextField?.text)!.uppercaseFirst
            self?.albumDelegate?.saveNewAlbum(name: albumName)
            
        }
        self.addAction(saveAction)
        //Add a text field
        self.addTextField { textField  in
            // you can use this text field
            self.inputTextField = textField
            self.actions[1].isEnabled = false
        }
        
        //Present the AlertController
        inputTextField?.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
    }
    

    
    func textFieldDidChange(textField: UITextField) {
        if textField.text?.characters.count == 0 {
            self.actions[1].isEnabled = false
        }else
        {
            self.actions[1].isEnabled = true
        }
    }
    
    deinit {
        print("add album alert deinit")
    }
    
    func cancelDidPress(){ albumDelegate?.cancelDidPress()}

}
