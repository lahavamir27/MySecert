//
//  EmptySatateView.swift
//  ProjectX
//
//  Created by amir lahav on 29.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit
import Cartography

class EmptySatateView: UIView {

    fileprivate var emptyLabel:EmptyStateHeader? = nil
    fileprivate var emptyBodyLabel:UITextView? = nil
    fileprivate let color:CGFloat = 160/256

    init(frame: CGRect, albumType:AlbumType) {
        super.init(frame: frame)
        self.frame = UIScreen.main.bounds
        setupViewWith(albumType)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViewWith(_ albumType:AlbumType)
    {
        emptyLabel = EmptyStateHeader(frame: CGRect.zero, title: "No Photos or Videos")
        self.addSubview(emptyLabel!)
        constrain(emptyLabel!) {label in
            label.centerX == label.superview!.centerX
            label.centerY == label.superview!.centerY - 28.0
        }
        
        emptyBodyLabel = UITextView(frame: CGRect.zero)
        emptyBodyLabel?.text = "You can sync photos and videos onto Project X using 'New'"
        emptyBodyLabel?.textAlignment = .center
        emptyBodyLabel?.textContainerInset = UIEdgeInsets.zero;
        emptyBodyLabel?.textContainer.lineFragmentPadding = 0;
        emptyBodyLabel?.isUserInteractionEnabled = false; // Don't allow interaction
        emptyBodyLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular)
        emptyBodyLabel?.textColor = UIColor(red: color, green: color, blue: color, alpha: 1)
        self.addSubview(emptyBodyLabel!)
        constrain(emptyBodyLabel!) {view in
            view.left == view.superview!.left + 44
            view.right == view.superview!.right - 44
            view.height == 200
            view.centerY == view.superview!.centerY + 101.0
        }
        
        switch albumType {
        case .userAlbum:
            emptyBodyLabel?.text = "Press 'Edit' and then 'Add' to add photos to album"
        case .places:
            emptyBodyLabel?.text = "Project x consistently scans your library to create Places Album, Geotagged photos will automatically add to this album"
        case .people:
            emptyBodyLabel?.text = "Project x consistently scans your library to create People album for familiar faces"
        default:
            break
        }
    }
    deinit {
        print("empty view deinit")
    }

}

class EmptyStateHeader: UILabel {
    
    fileprivate let color:CGFloat = 170/256
    init(frame: CGRect, title:String) {
        super.init(frame: frame)
        text = title
        self.frame.size = CGSize(width: 200.0, height: 35)
        font = UIFont.systemFont(ofSize: 28, weight: UIFontWeightRegular)
        textColor = UIColor(red: color, green: color, blue: color, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

