//
//  EditImageViewController.swift
//  ProjectX
//
//  Created by amir lahav on 7.1.2018.
//  Copyright © 2018 LA Computers. All rights reserved.
//

import UIKit
import Cartography



class EditImageViewController: UIViewController {

    

    fileprivate var viewModel:ModelViewEditController
    fileprivate var filterImagesCollectionView:FilterImageCollectionView!
    fileprivate var mainImageView:UIImageView!
    fileprivate var toolBar:EditImageToolbar!
    fileprivate var navigationBar:EditImageNavigationBar!
    fileprivate var labels:[UILabel]!
    fileprivate var filteredImages:[FilterImageCellData]?
    fileprivate var FXfilteredImages:[FilterImageCellData]?
    fileprivate var editNavigationBar:UINavigationController!
    fileprivate let group = ConstraintGroup()
    fileprivate var paintNavigationBar:NavigationBarToolBar!

//    fileprivate var tempImageView:UIImageView!
    
    override public var prefersStatusBarHidden: Bool {
        switch shouldHideStatusBar {
        case true:
            return true
        default:
            return false
        }
    }
    
    fileprivate var shouldHideStatusBar = false
    
    fileprivate var viewState:EditState? = nil {
        didSet{
            switch viewState! {
            case .normal:
                updateConstraints(state: .normal, animated: true)
                showPaintNavigationBar(fade: true)
                showAddOns(fade: false)
            case .filter:
                updateConstraints(state: .filter, animated: true)
                showPaintNavigationBar(fade: true)
                showAddOns(fade: true)
                filterImagesCollectionView.reloadData()

            case .paint:
                updateConstraints(state: .paint, animated: true)
                showPaintNavigationBar(fade: false)
                showAddOns(fade: false)

            case .FX:
                updateConstraints(state: .FX, animated: true)
                showPaintNavigationBar(fade: true)
                showAddOns(fade: true)
                filterImagesCollectionView.reloadData()

            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        labels = [UILabel]()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateViewAfterAppear()
    }

    func updateViewAfterAppear()
    {
        guard let cell = filterImagesCollectionView.cellForItem(at: [0,0]) as? FilteredImageCollectionViewCell else {return}
        cell.isSelected = true
        shouldHideStatusBar = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    func setupView()
    {

        initMainImageView()
        initFilteredCollectionView()
        initToolbar()
        initNavigationBar()
        updateConstraints(state: .normal, animated: false)
        getFilteredImages()
        getFXFilteredImages()
    }
   
    func initToolbar()
    {
        toolBar = EditImageToolbar(frame: CGRect(x: 0, y: 0, width: 1, height: 1), viewController: self)
        self.view.addSubview(toolBar)
 
    }
    
    func initNavigationBar()
    {
        paintNavigationBar = NavigationBarToolBar(frame: CGRect(x: 0, y: 0, width: 1, height: 1), viewController: self)
        self.view.addSubview(paintNavigationBar)
        paintNavigationBar.alpha = 0.0
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func initMainImageView()
    {
        mainImageView = UIImageView(image: viewModel.originialImage)
        self.view.addSubview(mainImageView)
        mainImageView.contentMode = .scaleAspectFit

    }
    
    func initFilteredCollectionView()
    {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80.0, height: 100.0)
        layout.minimumLineSpacing = 3.0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 4, left: 3.0, bottom: 0, right: 3.0)
        
        filterImagesCollectionView = FilterImageCollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)
        filterImagesCollectionView.register(FilteredImageCollectionViewCell.self)
        filterImagesCollectionView.delegate = self
        filterImagesCollectionView.dataSource = self
        filterImagesCollectionView.contentInsetAdjustmentBehavior =  .never
        filterImagesCollectionView.showsHorizontalScrollIndicator = false
        filterImagesCollectionView.allowsMultipleSelection = false
        self.view.addSubview(filterImagesCollectionView)

    }
    
    func updateConstraints(state:EditState, animated:Bool)
    {
        switch state {
        case .normal:
            constrain(toolBar, mainImageView, filterImagesCollectionView,paintNavigationBar, replace: group) { (toolbar, image, filter, navBar) in
                navBar.width == navBar.superview!.width
                navBar.top == navBar.superview!.top + 12
                navBar.left == navBar.superview!.left + 12
                navBar.right == navBar.superview!.right + 12
                navBar.height == 44
                
                toolbar.width == toolbar.superview!.width
                toolbar.bottom == toolbar.superview!.bottom
                toolbar.left == toolbar.superview!.left
                toolbar.right == toolbar.superview!.right
                toolbar.height == 44
                
                image.edges == image.superview!.edges
                
                filter.height == 105
                filter.width == filter.superview!.width
                filter.left == filter.superview!.left
                filter.right == filter.superview!.right
                filter.top == toolbar.top
                
            }

        case .filter,.FX:
            constrain(self.view, mainImageView, filterImagesCollectionView, toolBar,paintNavigationBar, replace: group) { (view, image, filter, toolbar, navBar) in
                toolbar.height == 44
                toolbar.bottom == view.bottom
                toolbar.width == view.width
                toolbar.left == view.left
                toolbar.right == view.right
                filter.height == 105
                filter.width == view.width
                filter.left == view.left
                filter.right == view.right
                filter.bottom == toolbar.top
                image.bottom == filter.top
                image.top == view.top
                image.left == view.left
                image.right == view.right
                navBar.width == navBar.superview!.width
                navBar.top == navBar.superview!.top + 12
                navBar.left == navBar.superview!.left + 12
                navBar.right == navBar.superview!.right + 12
                navBar.height == 44
            }
            filterImagesCollectionView.alpha = 0.0
        case .paint:
                constrain(self.view, toolBar, mainImageView, filterImagesCollectionView,paintNavigationBar, replace: group) { (view, toolbar, image, filter, navBar) in
                    toolbar.width == view.width
                    toolbar.bottom == view.bottom
                    toolbar.left == view.left
                    toolbar.right == view.right
                    toolbar.height == 49
                    image.edges == view.edges
                    filter.height == 105
                    filter.width == view.width
                    filter.left == view.left
                    filter.right == view.right
                    filter.top == toolbar.top
                    navBar.width == navBar.superview!.width
                    navBar.top == navBar.superview!.top + 12
                    navBar.left == navBar.superview!.left + 12
                    navBar.right == navBar.superview!.right + 12
                    navBar.height == 44
                }
        }
        
        if animated {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
                self.filterImagesCollectionView.fadeView(fade: false, time: 0.15)
                
            }, completion: { (succ) in })

        }
    }
    

    
    func showPaintNavigationBar(fade:Bool)
    {
        self.paintNavigationBar.fadeView(fade: fade, time: 0.15)
    }
    func showAddOns(fade:Bool)
    {
        for label in labels
        {
            label.fadeView(fade: fade, time: 0.25)
        }
    }
    
    func getFilteredImages()
    {
        DispatchQueue.global().async {
            guard let filterImages =  self.viewModel.getFilteredImages() else {
                self.filteredImages = [FilterImageCellData]()
                return
            }
            self.filteredImages = filterImages
            DispatchQueue.main.async {
                self.filterImagesCollectionView.reloadData()
            }
        }
    }
    func getFXFilteredImages()
    {
        DispatchQueue.global().async {
            guard let filterImages =  self.viewModel.getFXFilteredImages() else {
                self.FXfilteredImages = [FilterImageCellData]()
                return
            }
            self.FXfilteredImages = filterImages
            DispatchQueue.main.async {
                self.filterImagesCollectionView.reloadData()
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public init(assetID:String)
    {
        viewModel = ModelViewEditController(imageID: assetID)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit image editor")
    }
   

}

extension EditImageViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let currentViewState = viewState == nil ? .normal : viewState!
        
        switch currentViewState {
        case .filter:
            guard let numberOfItemsInSection = filteredImages?.count else { return 0}
            return numberOfItemsInSection
        case .FX:
            guard let numberOfItemsInSection = FXfilteredImages?.count else { return 0}
            return numberOfItemsInSection
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let currentViewState = viewState == nil ? .normal : viewState!

        switch currentViewState {
            
        case .filter:
            let cell:FilteredImageCollectionViewCell = filterImagesCollectionView.dequeueReusableCell(forIndexPath: indexPath)
            let data = filteredImages![indexPath.item]
            cell.filterName.text = data.filterName
            cell.imageView.image = data.filterImage
            return cell
        case .FX:
            let cell:FilteredImageCollectionViewCell = filterImagesCollectionView.dequeueReusableCell(forIndexPath: indexPath)
            let data = FXfilteredImages![indexPath.item]
            cell.filterName.text = data.filterName
            cell.imageView.image = data.filterImage
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentViewState = viewState == nil ? .normal : viewState!
        switch currentViewState {
        case .filter:
            if let cellZero = filterImagesCollectionView.cellForItem(at: [0,0]) as? FilteredImageCollectionViewCell { cellZero.isSelected = false }
            let filter = filteredImages![indexPath.item]
            updateMainImage(withFilter: filter.filterImageType)
            filterImagesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        case .FX:
            if let cellZero = filterImagesCollectionView.cellForItem(at: [0,0]) as? FilteredImageCollectionViewCell { cellZero.isSelected = false }
            let filter = FXfilteredImages![indexPath.item]
            updateMainImage(withFilter: filter.fxFilterType)
            filterImagesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        default:
            break
        }
    }
}


extension EditImageViewController
{
    func updateMainImage(withFilter:FilterName)
    {
        mainImageView.image = viewModel.getFilteredImage(forFiltered: withFilter)
    }
    func updateMainImage(withFilter:FXFilter)
    {
        mainImageView.image = viewModel.getFXFilteredImage(forFiltered: withFilter)
    }
}

extension EditImageViewController: FilterImageToolbarProtocol
{
    func buttonDidPress(button: UIButton) {
        switch button.userButtonType {
        case .cancel:               self.dismiss(animated: true, completion: nil)
        case .doneEditAlbum:        saveImage()

        default:                    print("unknown button pressed")
        }
    }
    
    func saveImage()
    {
        if !labels.isEmpty{
            for label in labels{
                mainImageView.addSubview(label)
            }
        }
        var filterImage = UIImage()
        UIGraphicsBeginImageContextWithOptions(mainImageView.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            mainImageView.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            filterImage = image!
        }
        viewModel.fillteredImage = filterImage
        viewModel.saveFillterImage()
        dismiss(animated: true, completion: nil)
    }
}

extension EditImageViewController: ViewUpdater, UserTextLabelProtocol, NavigatinoBarButtonsProtocol
{
    func navigationBarButtonDidPress(sender: NavigationBarButtonsType) {
        switch sender {
        case .text:             addNewLabel()
        case .pan:              break
        case .filter:           viewState = viewState == .filter ? .normal: .filter
        case .paint:            viewState = viewState == .paint ? .normal: .paint
        case .FX:               viewState = viewState == .FX ? .normal: .FX
        case .doneEditAlbum:    saveImage()
        case .cancel:           self.dismiss(animated: true, completion: nil)
        default:                print("unknown button pressed")
        }
    }
    
    func didTap(sender:UILabel) {
        
        let vc = EditTextViewController(text: sender.text!)
        vc.saveText = {[unowned self] (text) in  self.changeText(label: sender, text: text) }
        editNavigationBar = UINavigationController(rootViewController: vc)
        editNavigationBar.modalPresentationStyle = .overCurrentContext
        self.present(editNavigationBar, animated: false, completion: nil)
    }
    
    func changeText(label:UILabel, text:String)
    {
        let center = label.center
        label.text = text
        label.sizeToFit()
        label.center = center
    }
    
    func view(center: CGPoint) {
    }

    func addNewLabel(){
        
        let newLabel = TextLabelAddOn(frame: CGRect(x: 200, y: 200, width: 300, height: 90))
        didTap(sender: newLabel)
        newLabel.delegate = self
        newLabel.text = ""
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.view.addSubview(newLabel)
            self.view.bringSubview(toFront: newLabel)
            newLabel.isUserInteractionEnabled = true
            newLabel.initialLocation = self.view.center
            newLabel.center = self.view.center
            newLabel.viewDelegate = self
            self.labels.append(newLabel)
        }
    }
    
}

enum EditState {
    case normal
    case filter
    case paint
    case FX
}

