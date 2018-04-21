//
//  NavigationHelper.swift
//  ProjectX
//
//  Created by amir lahav on 16.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import UIKit


class NavigationHelper{
    

    
    static func getGridTitle(title:String) -> UIView
    {
        let width = UIScreen.main.bounds.size.width
        let titleLabel = UILabel(frame: CGRect(x:0, y: 6, width: width - 220, height: 20))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightSemibold)
        titleLabel.text = title
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .center
        
        let titleView = UIView(frame: CGRect(x:0, y:0, width: width - 220, height:30))
        titleView.addSubview(titleLabel)
        
        return titleView
    }
    
    static func setTitle(title:String?, subtitle:String?, oriantetion:UIDeviceOrientation) -> UIView {
        let width = UIScreen.main.bounds.size.width
        let titleLabel = UILabel(frame: CGRect(x:0, y:-4, width: width - 100, height: 20))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = .black
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.text = title
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel(frame: CGRect(x:0, y:20, width: width - 100, height: 10))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = .black
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        subtitleLabel.text = subtitle
        subtitleLabel.adjustsFontSizeToFitWidth = false
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.textAlignment = .center
    
        let titleView = UIView(frame: CGRect(x:0, y:0, width: width - 100, height:30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        switch oriantetion {

         case .landscapeLeft,.landscapeRight, .portraitUpsideDown :
            titleLabel.transform = CGAffineTransform.init(translationX: 0, y: 8)
            titleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
         default:
            break
        }

    
    return titleView
    }
    
    
    static func getTitle(with titleData:NCTitleData, oriantetion:UIDeviceOrientation ) -> NCTitle
    {
        switch oriantetion {
        case .portrait,.faceDown,.faceUp, .unknown :
            if let adress = titleData.adress
            {
               return NCTitle(title: adress, subTitle:"\(String.getDate(date: titleData.date)) \u{00B7} \(String.getTimeFromDateString(date: titleData.date))")
            }else{
               return NCTitle(title: String.getDate(date: titleData.date), subTitle: String.getTimeFromDateString(date: titleData.date))
            }
        case .landscapeLeft,.landscapeRight, .portraitUpsideDown :
            if let adress = titleData.adress
            {
                return NCTitle(title: adress)
            }else{
                return NCTitle(title: "\(String.getDate(date: titleData.date)) \u{00B7} \(String.getTimeFromDateString(date: titleData.date))")
            }
        }
    }
    
    static func updateNavigaitonBar(at state:AppState, tabType:TabType, albumType:AlbumType) -> ([NavigationBarButtonsType?], [NavigationBarButtonsType?])
    {
        switch tabType {
        case .albumGrid:
            switch state {
            case .normal:
                return([nil], [.select])
            case .empty:
                switch albumType {
                case .userAlbum:
                    return ([nil],[.editAlbum])
                default:
                    return ([nil],[nil])
                }
            default:
                return([nil],[.cancel])
            }
        case .photoGrid:
            switch state {
            case .normal:
                return ([.newPhoto], [.select,.search])
            case  .empty:
                return ([.newPhoto],[ nil])
            case  .addPhotosToAlbum:
                return ([nil], [.doneEditAlbum])
            default:
                return([.newPhoto],[.cancel])
            }
        }
    }
    
    
    
}


struct NCTitleData {
    var adress:String?
    var date:Date
    init(adress:String? = nil, date:Date) {
        self.adress = adress
        self.date = date
    }
}

struct NCTitle {
    var title:String
    var subTitle:String?
    init(title:String, subTitle:String? = nil) {
        self.title = title
        self.subTitle = subTitle
    }
}
