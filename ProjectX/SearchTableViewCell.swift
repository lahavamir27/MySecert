//
//  SearchTableViewCell.swift
//  ProjectX
//
//  Created by amir lahav on 9.12.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit
import Cartography
class SearchTableViewCell: UITableViewCell {

    
    
    var assetImageView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
//        setupCell()
    }
    
    
    func setupCell()
    {
        assetImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        assetImageView.image = #imageLiteral(resourceName: "photo_57.png")
        assetImageView.clipsToBounds = true
        assetImageView.cornerRadius = 4.0
        assetImageView.contentMode = UIViewContentMode.scaleToFill
        self.contentView.addSubview(assetImageView)
        
        constrain(self.contentView, assetImageView){ view, image in
            image.width == 48
            image.height == 48
            view.left == image.left - 6
            view.top  == image.top - 6
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.imageView?.image = nil
        self.textLabel?.attributedText = nil
    }

}
