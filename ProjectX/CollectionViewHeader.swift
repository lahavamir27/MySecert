//
//  CollectionViewHeader.swift
//  MySecret
//
//  Created by amir lahav on 26.8.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit
import Cartography

protocol HeaderProtocol:class {
    func selectBtnDidSelect(cell: UICollectionReusableView?, isSelected:Bool, indexPath:IndexPath? )
}
extension HeaderProtocol
{
    func selectBtnDidSelect(cell: UICollectionReusableView?, isSelected:Bool, indexPath:IndexPath? = nil ){}
}

final class CollectionViewHeader: UICollectionReusableView {
    
    
    var title:UILabel = UILabel()
    var subTitle:UILabel = UILabel()
    var selectBtn:UIButton = UIButton()
    var indexPath:IndexPath? = nil
    var headerType:HeaderType = .title
    var titleFrame = CGRect(x: 16, y: 10, width: 313, height: 20)
    var subTitleFrame = CGRect(x: 16, y: 30, width: 313, height: 20)
    var selectButtonFrame = CGRect(x: 16, y: 11, width: 313, height: 35)
    var bloorBackground = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))

    
    var isSelected:Bool = false
        {
        didSet{
            switch isSelected {
            case true: selectBtn.setTitle("Deselect", for: .normal)
            default:   selectBtn.setTitle("Select", for: .normal)
            }
        }
    }
    weak var delegate:HeaderProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()

    }

    
    var headerState:HeaderState = .normal {
        didSet{
            switch headerState {
            case .normal:   selectBtn.isHidden = true
                            isSelected = false
            case .select:   selectBtn.isHidden = false
            }
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView()
    {
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        bloorBackground = UIVisualEffectView(effect: blurEffect)
        bloorBackground.isUserInteractionEnabled = false
        bloorBackground.frame = CGRect(x: 0.0, y: 0, width: 1, height: 1)
        bloorBackground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bloorBackground.isHidden = true


        title = UILabel(frame: titleFrame)
        title.font = UIFont.preferredFont(forTextStyle: .headline)
        subTitle = UILabel(frame: subTitleFrame)
        subTitle.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subTitle.textColor = UIColor.secretGray()
        selectBtn = UIButton(frame: selectButtonFrame)
        
        self.addSubview(bloorBackground)
        self.addSubview(title)
        self.addSubview(subTitle)
        self.addSubview(selectBtn)
        
//        self.backgroundColor = .white
        constrain(bloorBackground, self) {bg, view in
            bg.edges == view.edges
        }
        setupSelectButton()
        
    }
    
    func setupSelectButton()
    {
        selectBtn.setTitle("Select", for: UIControlState.normal)
        selectBtn.setTitleColor(UIColor.secretBlue(), for: .normal)
        selectBtn.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        selectBtn.contentHorizontalAlignment = .right
        constrain(selectBtn, self) {button, view in
            button.width == 120.0
            button.height == 35.0
            button.right == view.right - 8.0
            button.centerY == view.centerY
        }
        selectBtn.addTarget(self, action: #selector(self.isSelect), for: .touchUpInside)
    }
    
    func isSelect()
    {
        isSelected = !isSelected
        delegate?.selectBtnDidSelect(cell: self, isSelected: isSelected, indexPath:indexPath)
    }
    func setTitles(title:String?, subTitle:String?, size:HeaderSize?)
    {
        self.title.text = title
        self.subTitle.text = subTitle

    }
    func configureHeader(title section:AssetCollection)
    {
        let header = TilteAndSubTitleHelper.init(with: section)
        
        if let inputText = header.subTitle
        {
            title.text = header.title
            subTitle.text = inputText
            title.transform = CGAffineTransform(translationX: 0, y: 0)
            selectBtn.transform = CGAffineTransform(translationX: 0, y: 0)

        }else
        {
            title.text = header.title
            subTitle.text = ""
            title.transform = CGAffineTransform(translationX: 0, y: 0)
            selectBtn.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    override func prepareForReuse() {
        indexPath = nil
    }
}

enum HeaderState {
    case normal
    case select
}
enum HeaderType {
    case title
    case titleAndSubtitle
}
