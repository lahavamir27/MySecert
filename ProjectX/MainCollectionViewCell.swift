//
//  AlbumCell.swift
//  PhotoViewer
//
//  Created by amir lahav on 3.12.2016.
//  Copyright © 2016 Nathan Blamires. All rights reserved.
//

import UIKit


protocol AlbumCellProtocol:class {
    func deleteAlbumBtnDidPress(cell: MainCollectionViewCell?)
}


class MainCollectionViewCell: UICollectionViewCell, NibLoadableView {

    @IBAction func deleteBtnPress(_ sender: UIButton) {
            delegate?.deleteAlbumBtnDidPress(cell: self)
    }
    
    weak var delegate: AlbumCellProtocol?

    @IBOutlet weak var albumIcon: UIImageView!
    @IBOutlet weak var iconBackground: UIImageView!
    @IBOutlet weak var numberOfPhotosLbl: UILabel!
    @IBOutlet weak var albumNameLbl: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var minusIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        // Initialization code
    }
    
    
    func removeCorenrRaidus()
    {
        iconBackground.layer.cornerRadius = 4.0
        iconBackground.layer.borderWidth = 2.0
        iconBackground.layer.borderColor = UIColor.white.cgColor
    }
    
    func addCorenerRadius()
    {
        iconBackground.layer.cornerRadius = iconBackground.bounds.size.width/2
        iconBackground.layer.borderWidth = 0.0
        iconBackground.layer.borderColor = UIColor.white.cgColor
        iconBackground.backgroundColor = .lightGray
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.contentView.backgroundColor = isHighlighted ? UIColor(white: 217.0/255.0, alpha: 1.0) : nil
        }
    }

}
