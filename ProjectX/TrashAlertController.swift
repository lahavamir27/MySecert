//
//  TrashAlertController.swift
//  MySecret
//
//  Created by amir lahav on 28.8.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit


protocol TrashAlertProtocol:class {
    func removeFromAlbum()
    func deletePhotos()
}



class TrashAlertController: UIAlertController {

    
    weak var delegate:TrashAlertProtocol?
    
    convenience init(numOfPhotoToDelete:Int, isUserAlbum:Bool) {
        self.init()
        
        message = nil
        title = nil
        
        let text = { () -> String in
            if numOfPhotoToDelete == 0 {return "Delete Photo"}
            return numOfPhotoToDelete == 1 ? "Delete 1 photo" : "Delete \(numOfPhotoToDelete) Photos"
        }
        
        let titleHeader = { () -> String in
        
            return numOfPhotoToDelete == 1 ? "photo" : "Photos"
        }
        switch isUserAlbum {
        case true:
            
            
            self.addAction(UIAlertAction(title: "Remove from Album", style: .destructive, handler: {[weak self] (alertAction) in self?.delegate?.removeFromAlbum()
                self?.dismiss(animated: true, completion: {
                })
            }))
            
            self.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] (alertAction) in self?.delegate?.deletePhotos()
                self?.dismiss(animated: true, completion: {
                })
            }))
            
        default:
            
            title = "This \(titleHeader()) will be removed from Privte Albums"

            self.addAction(UIAlertAction(title: text(), style: .destructive, handler: {[weak self] (alertAction) in self?.delegate?.deletePhotos()
                self?.dismiss(animated: true, completion: {
                })
            }))
        }
        
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self] (alertAction) in
            self?.dismiss(animated: true, completion: {
            })
        }))
    }
    
    deinit {
        print("trash controller deinit")
    }
    


}
