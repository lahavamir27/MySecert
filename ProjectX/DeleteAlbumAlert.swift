//
//  DeleteAlbumAlert.swift
//  ProjectX
//
//  Created by amir lahav on 20.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit

protocol DeleteAlbumProtocol:class {
    func shouldDeleteAlbum()
    func cancelDeleteAlbum()

}

class DeleteAlbumAlert: UIAlertController {

    var deleteAlbumAlertDelegate:DeleteAlbumProtocol?
    convenience init(albumName:String){
        self.init()
        
        title = "Delete \(albumName)"
        message = "Are you sure you want to delete the album \(albumName)? The photos will not be deleted"
        
        self.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] (alertAction) in self?.deleteAlbumAlertDelegate?.shouldDeleteAlbum()
            self?.dismiss(animated: true, completion: {
            })
        }))
        
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self] (alertAction) in
            self?.deleteAlbumAlertDelegate?.cancelDeleteAlbum()
            self?.dismiss(animated: true, completion: {
            })
        }))
    }
    
    deinit {
        print("album delete alert deinit")
    }
    

}
