//
//  DetailViewModelController.swift
//  ProjectX
//
//  Created by amir lahav on 22.11.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift


protocol ViewModelProtocol {
    
    var albumName:String {set get}

}

extension ViewModelProtocol
{
    
    var numberOfSections:Int {  return album.numberOfSections }
    
    var needHeader:Bool { return album.needHeader }
    
    var isLastPhoto:Bool { return numberOfPhotosInAlbum == 1}
    
    var isEmptyAlbum:Bool { return numberOfPhotosInAlbum == 0 }
    
    var isUserAlbum:Bool { return album.isUserAlbum  }
    
    var isMultypleSection:Bool  {  return album.isMultypleSection  }
    
    var numberOfPhotosInAlbum:Int {  return album.numberPhotosInAlbum()  }
    
    var album:Album {
        guard let realm = try? Realm() else { return Album() }
        guard let album = realm.objects(Album.self).filter("albumName == '\(albumName)'").first else {
            return Album()
        }
        return album
    }
    
    func getCellData(at indexPath:IndexPath)  -> CellData
    {
        return album.getCell(at: indexPath)
    }
    
    func numberOfItemsIn(_ section: Int) -> Int  {  return album.numberOfPhotos(in:section) }
    
}


struct DetailViewModelController:ViewModelProtocol {
    
   
    fileprivate var photoModelController:PhotoModelController
    var albumName: String
    
    init(albumName:String) {
        self.albumName = albumName
        photoModelController = PhotoModelController(albumName: albumName)
    }
    
    func cellInstance<T:GeustureHendler>(_ collectionView: UICollectionView, indexPath: IndexPath) -> T {
        // Dequeue a cell

        let cellData = photoModelController.getCellData(at: indexPath)
        let id = cellData.photoId
        
        switch cellData.assetType! {
        case .image:
            let imageCell: ImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            imageCell.imageView.zoomView?.image = nil
            photoModelController.getImage(id: id, imageSize: .fullSize , handler: { (image, imageID) in
                DispatchQueue.main.async { if imageID == id{  imageCell.imageView.display(image: image) }  }})
            
            return imageCell as! T
        case .video:
            let videoCell: VideoDetailCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            
            return videoCell as! T
        default:
            let imageCell: ImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            return imageCell as! T
        }
        // Return the cell
    }
    
    
}
