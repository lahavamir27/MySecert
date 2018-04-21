//
//  BaseAssetCell.swift
//  ProjectX
//
//  Created by amir lahav on 4.10.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import UIKit
import Cartography



class BaseCell: UICollectionViewCell {
    
    var imageView:UIImageView
    var highlightView:UIView
    var likeIamge: UIImageView
    var badgeView:UIView
    var typeView:UIImageView
    var gradientView:UIView
    
    let highlightedBlueColor = UIColor(red: 40/255, green: 104/255, blue: 244/255, alpha: 1)
    let highlightedColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    let highlightedBrightColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
    
    override init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        imageView.backgroundColor = .lightGray
        highlightView = UIView(frame: frame)
        likeIamge = UIImageView()
        badgeView = UIView()
        typeView = UIImageView()
        gradientView = UIView()
        super.init(frame: frame)
        setupSubView()
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func setupSubView()
    {
        contentView.addSubview(imageView)
        contentView.addSubview(gradientView)
        contentView.addSubview(highlightView)
        contentView.addSubview(badgeView)
        contentView.addSubview(typeView)
        
        setupHighlightView()
        setupImageView()
        setupBadge()
        addgradient()
        setypTypeView()
    }
    func setypTypeView()
    {
        constrain(typeView ,self.contentView) {typeView, cell in
            typeView.width == 16
            typeView.height == 16
            typeView.bottom == cell.bottom - 4
            typeView.left == cell.left + 4
        }
    }
    
    func setupHighlightView()
    {
        constrain(highlightView ,self.contentView) {highlightView, cell in
            highlightView.edges == cell.edges
        }
    }
    func setupImageView()
    {
        imageView.contentMode = .scaleAspectFill
        constrain(imageView ,self.contentView) {image, cell in
            image.edges == cell.edges
        }
        imageView.clipsToBounds = true
    }
    
    func setupBadge()
    {
        badgeView.layer.cornerRadius = 12.0
        badgeView.layer.borderColor = UIColor.white.cgColor
        badgeView.layer.borderWidth = 1.0
        badgeView.backgroundColor = highlightedBlueColor
        badgeView.isHidden = true
        
        constrain(badgeView ,self.contentView) {badge, cell in
            badge.width == 24
            badge.height == 24
            badge.bottom == cell.bottom - 4
            badge.right == cell.right - 4
        }
    }
    
    func addgradient()
    {

        constrain(gradientView ,self.contentView) {gradientView, cell in
            gradientView.height == 20
            gradientView.bottom == cell.bottom
            gradientView.right == cell.right
            gradientView.left == cell.left
        }
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.frame = CGRect(x: 0, y: 0, width: self.contentView.bounds.size.width, height: 20)
        gradientView.layer.addSublayer(gradient)


    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addgradient(_ add:Bool)
    {
        gradientView.isHidden = !add
    }
    
    func like(_ like:Bool)
    {
        addgradient(like)
        switch like {
        case true: typeView.image = #imageLiteral(resourceName: "Like Filled")
        default: typeView.image = nil
        }
    }

}


protocol AssetCellProtocl {
    
    func isHighlighted(_ bool:Bool)
    func isSelected(_ bool:Bool)
}

extension AssetCellProtocl where Self:BaseCell
{
    
    func isHighlighted(_ highlighted:Bool)
    {
        highlightView.backgroundColor = highlightedColor
        highlightView.isHidden = highlighted ? false : true
    }
    
    func isSelected(_ selected:Bool)
    {
        highlightView.backgroundColor = highlightedBrightColor
        highlightView.isHidden = selected ? false : true
        badgeView.isHidden = selected ? false : true
        self.contentView.bringSubview(toFront: badgeView)
    }
    
}





