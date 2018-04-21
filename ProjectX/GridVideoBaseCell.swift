//
//  GridMovieCell.swift
//  ProjectX
//
//  Created by amir lahav on 4.10.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import UIKit
import Cartography


class VideoCell: BaseCell, AssetCellProtocl  {
    
    let timeLabel:UILabel
    let cellVideoTypeIcon:UIImageView
    
    override init(frame: CGRect) {
        timeLabel = UILabel()
        cellVideoTypeIcon = UIImageView()
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var isHighlighted: Bool {
        willSet {
            isHighlighted(newValue)
        }
    }
    override var isSelected: Bool {
        willSet {
            isSelected(newValue)
        }
    }
    
    override func prepareForReuse() {
        isSelected = false
        isHighlighted = false
        timeLabel.text = ""
    }
    
}


protocol MediaCell {
    func setupTimeLabel(_ time:String?)
    func setupIconType(_ icon:VideoTypeIcon)
}

extension MediaCell where Self:VideoCell
{
    func setupTimeLabel(_ time:String?)
    {
        self.contentView.addSubview(timeLabel)
        constrain(timeLabel, self.contentView) { label, view in
            label.width == 60
            label.height == 14
            label.right == view.right - 4
            label.bottom == view.bottom - 4
        }
        timeLabel.text = time
        timeLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        timeLabel.textAlignment = .right
        timeLabel.textColor = .white
    }
    
    func setupIconType(_ icon:VideoTypeIcon)
    {
        self.contentView.addSubview(cellVideoTypeIcon)
        constrain(cellVideoTypeIcon, self.contentView) { label, view in
            label.width == 14
            label.height == 14
            label.left == view.left + 4
            label.top == view.top + 4
        }
        cellVideoTypeIcon.image = icon.image
    }
    
}

enum VideoTypeIcon
{
    case sloMo
    case liveVideo
    
    var image: UIImage? {
        switch self {
        case .sloMo: return #imageLiteral(resourceName: "slomo")
        case .liveVideo: return #imageLiteral(resourceName: "Like Filled")
        }
    }
}
