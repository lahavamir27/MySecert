//
//  PhotoDetail.swift
//  ProjectX
//
//  Created by amir lahav on 15.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit
import Cartography
import RealmSwift
import Cache
import AVKit
import AVFoundation
class PhotoDetail: UIViewController, UserAlertProtocol {

    fileprivate var lastContentOffset:CGPoint = CGPoint(x: 0.0, y: 0.0)
    fileprivate var scrollRight = false
    fileprivate var lastIndexPath = IndexPath()
    fileprivate var slideShow:UICollectionView? = nil
    fileprivate var albumName:String = ""
    fileprivate let thumbnailCache = HybridCache(name: "Mix")
    fileprivate var exporter :ExportImage? = nil
    fileprivate let cache = HybridCache(name: "Detail")
    fileprivate var toolBar:DetailVCToolBar? = nil
    fileprivate var trashAlert: TrashAlertController? = nil
    fileprivate var exportAlert: ExportAlertController? = nil
    fileprivate var viewModel:DetailViewModelController? = nil
    fileprivate var photoEditinigController: SHViewController? = nil
    fileprivate let itemSpacing:CGFloat = 44.0
    fileprivate var indexsToDelete = Set<IndexPath>()
    fileprivate var modelController:PhotoModelController? = nil
    fileprivate var loadImageHelper = LoadImageHelper()
    fileprivate var imageEditorController:EditImageViewController? = nil
    fileprivate var editNavigationController:UINavigationController!

    typealias CurrentVideo = (item:AVPlayerItem?,indexPath: IndexPath?)?
    fileprivate var currentVideo:CurrentVideo = nil
    
    fileprivate var deviceOrientation:DeviceOrientation = .portrait
    
    fileprivate var slideShowState:SlideShowState = .normal
    {
        didSet{
            switch slideShowState
            {
                case .normal:
                     toolBar?.setToolBar(state: .normal)

                case .playVideo:
                     displayState = .fullScreen
                     toolBar?.setToolBar(state: .playVideo)

                case .pauseVideo:
                    toolBar?.setToolBar(state: .normal)
            }
        }
    }

    
    fileprivate var fullScreenMode:Bool = false {
        didSet
        {
            hideNavigationBar(fullScreenMode,(segueData?.tabType)!)
            switch fullScreenMode
            {
            case true:
                self.slideShow?.backgroundColor = .black
                self.view.backgroundColor = .black
                toolBar?.alpha = 0.0
            case false:
                self.slideShow?.backgroundColor = .white
                self.view.backgroundColor = .white
                toolBar?.alpha = 1.0
            }
//            setNeedsStatusBarAppearanceUpdate()
        }
    }
    fileprivate var displayState:DisplayState = .notFullScreen
    {
        didSet
        {
            switch displayState
            {
                case .fullScreen: fullScreenMode = true
                case .notFullScreen: fullScreenMode = false
            }
        }
    }
    open var hideNavigationBar:( _ hide:Bool, _ tabType: TabType) -> () = {_ in }
    open var hideButtomTabBar:(Bool) -> () = { _ in }
    open var dismissPhotoDetail:(DismissData) -> () = { _ in }
    open var segueData:SegueData? = nil
    
    open var currentImageIndex:IndexPath? = nil {
        didSet{
            updateNCTitle()
        }
    }

    convenience init(albumName:String) {
        self.init(nibName:nil, bundle:nil)
        self.albumName = albumName
        viewModel = DetailViewModelController(albumName: albumName)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView()
    {
        guard let segueData = segueData else { return  }
        modelController = PhotoModelController(albumName: albumName)
        currentImageIndex = segueData.indexPath
        
        configeNV()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .white
        
        configeCollectionView()
        registerObserver()
        configToolBar()
    }

    
//    override var prefersStatusBarHidden: Bool {
//        switch fullScreenMode {
//        case true : return true
//        default:
//            switch deviceOrientation {
//            case .landscape:
//                return true
//            case .portrait:
//                return false
//            }
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerObserver()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
    }
    
    func appMovedToBackground() {
        trashAlert?.dismiss(animated: false, completion: {[unowned self] _ in self.trashAlert = nil})
        exportAlert?.dismiss(animated: false, completion: {[unowned self] _ in self.exportAlert = nil})
        imageEditorController?.dismiss(animated: false, completion: {[unowned self] _ in self.imageEditorController = nil})
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.titleView = nil
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        print("photo detail deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateScrollOffset()
        updateNCTitle()
        updateOreintation()
        self.slideShow?.contentInsetAdjustmentBehavior =  .never

    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let cell = slideShow?.cellForItem(at: currentImageIndex!) as? VideoDetailCell
        {
            let item = cell.avPlayer.currentItem
            currentVideo = CurrentVideo(item: item,indexPath: currentImageIndex!)
        }
        toolBar?.updateToolbarFrame(size: size)
    }

}

extension PhotoDetail
{
    func updateNCTitle()
    {
        let oriantetion = UIDevice.current.orientation
        guard  let currentIndex = currentImageIndex else { return  }
        let titleData = modelController?.getPhotoTitleData(at: currentIndex)
        if titleData == nil {print("no title data") }
        let title = NavigationHelper.getTitle(with: titleData!, oriantetion: oriantetion)
        self.navigationItem.titleView = NavigationHelper.setTitle(title: title.title, subtitle: title.subTitle, oriantetion: oriantetion)
        
    }
    func configeNV()
    {
        self.navigationItem.updateLeftBarItems(buttonType: [.back], delegate: self)
        self.navigationItem.updateRightBarItems(buttonType: [.editAlbum], delegate: self)

    }
}

extension PhotoDetail
{
    func configeCollectionView()
    {
        let layout = SlideShowFlowLayout()
        
        let bounds = CGRect(x: 0, y: 0, width: self.view.bounds.size.width + itemSpacing , height: self.view.bounds.size.height)
        slideShow = UICollectionView(frame: bounds, collectionViewLayout: layout)
        slideShow?.isPagingEnabled = true
        self.view.addSubview(slideShow!)
//        constrain(slideShow!, self.view) {table, vc in
//            table.top == vc.top
//            table.height == self.view.bounds.size.height
//        }
        slideShow?.backgroundColor = .white
        slideShow?.delegate = self
        slideShow?.dataSource = self
        slideShow?.register(ImageCollectionViewCell.self)
        slideShow?.register(VideoDetailCell.self)

    }
    func rotated() {
        let bounds = CGRect(x: 0, y: 0, width: self.view.bounds.size.width + itemSpacing , height: self.view.bounds.size.height)
//        hideNavigationBar(fullScreenMode,(segueData?.tabType)!)
        slideShow?.collectionViewLayout.invalidateLayout()
        slideShow?.frame = bounds
        slideShow?.collectionViewLayout.invalidateLayout()
        updateScrollOffset()
        updateNCTitle()
        updateOreintation()
//        setNeedsStatusBarAppearanceUpdate()
    }
    
    func updateOreintation()
    {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight, .portraitUpsideDown:
            deviceOrientation = .landscape
        case .portrait,.faceDown,.faceUp, .unknown:
            deviceOrientation = .portrait
        }
    }
    
    func updateScrollOffset()
    {
        let factor:CGFloat = CollectionViewHelper.getContentOffsetFactor(with: currentImageIndex!, and: albumName)
        slideShow?.contentOffset = CGPoint(x: self.view.frame.width * CGFloat(factor) + itemSpacing * CGFloat(factor), y: 0)
        slideShow?.reloadData()
    }
    
    func updateCurrentIndex() {
        guard let indexPaths = slideShow?.indexPathsForVisibleItems else {return}
        currentImageIndex = CollectionViewHelper.updateCurrentIndex(from: indexPaths, and: scrollRight)
    }
    
     func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = (scrollView.contentOffset)
        lastIndexPath = currentImageIndex!
        setDiraction()
        if slideShowState == .playVideo || slideShowState == .pauseVideo { resetVideo()}
    }
     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        setDiraction()
        updateCurrentIndex()
        let cellData = modelController?.getCellData(at: currentImageIndex!)
        toolBar?.updateLikeButton(like: (cellData?.isFavorite)!)
    }

    func setDiraction()
    {
        if (lastContentOffset.x) < (slideShow?.contentOffset.x)! {
            scrollRight = true
        }
        else if (lastContentOffset.x) > (slideShow?.contentOffset.x)! {
            scrollRight = false
        }
    }
}


extension PhotoDetail:UICollectionViewDataSource, UICollectionViewDelegate
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel!.numberOfSections

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel!.numberOfItemsIn(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cellData = viewModel!.getCellData(at: indexPath)
        let id = cellData.photoId
        
        switch cellData.assetType! {
        case .image:
            let imageCell: ImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            imageCell.imageView.zoomView?.image = nil
            imageCell.imageView.zoomView?.image = modelController?.getImage(at: indexPath, imageSize: .thumbnail)
            modelController?.getImage(id: id, imageSize: .fullSize , handler: { (image, imageID) in
                DispatchQueue.main.async { if imageID == id{  imageCell.imageView.display(image: image) }  }})
            imageCell.imageView.zoomDelegate = self

            return imageCell
        case .video:
            let videoCell: VideoDetailCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            videoCell.imageView.zoomDelegate = self
            videoCell.delegate = self
            if let data = currentVideo {
                if currentImageIndex == data.1
                {
                    videoCell.replaceVideoWith(item: data.0!)
                }
            }else if let url = loadImageHelper.getVideoURL(id:cellData.photoId){
                videoCell.setupVideo(url: url)
            }
            currentVideo = nil
            
            return videoCell
            default:
            let imageCell: ImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            return imageCell
        }

    }
}

extension PhotoDetail: ImageZoomedDelegate
{
    func imageViewDidEndZoomingInOriginalSize(originalSize : Bool){}
    func tapOnce(){
        if displayState == .notFullScreen { displayState = .fullScreen} else { displayState = .notFullScreen}
    }
    func dragFromTop(){}
}

extension PhotoDetail: NavigatinoBarButtonsProtocol
{
    func navigationBarButtonDidPress(sender: NavigationBarButtonsType) {
        switch sender {
        case .back: backButtonDidPress()
        case .editAlbum: loadEditPhotoController()
        default: print("un wnated button did press")
        }
    }
    
    func backButtonDidPress() {
        let segueData = DismissData(indexPath: indexsToDelete, currentIndex: currentImageIndex!)
        dismissPhotoDetail(segueData)
    }
}

extension PhotoDetail: DetailVCToolBarDelegate, ExportImageProtocol, ExportAlertProtocol
{
    func export() {
        guard let mediaType = modelController?.getAssetMediaType(at: currentImageIndex!) else {userAlert(title: "Ohh No", message: "We can't export, Please try again later"); return }
        switch mediaType {
        case .image: export(image: (modelController?.getImage(at: currentImageIndex!, imageSize: .fullSize)!)!)
            print("export image")
        case .video: guard let videoPath = modelController?.getAssetID(at: currentImageIndex!) else { userAlert(title: "Ohh No", message: "We can't export this video, Please try again later"); return }
            guard let path = loadImageHelper.getVideoPath(id: videoPath) else { userAlert(title: "Ohh No", message: "We can't export this video, Please try again later"); return }
                exportVideo(atPath: path)
        print("export video")

         default: print("unkonwn type")
           
        }
        exportAlert = nil
    }
    
    func dismiss() {
        exportAlert = nil
    }

    func toolBarBtnDidPress(sender:ToolbarBtnType)
    {
        switch sender {
        case .edit:          showExportAlert()
        case .like:          like()
        case .pause:         pause()
        case .trash:         addTrashAlert()
        default: print("unkown")
        }
    }
    
    func showExportAlert()
    {
        exportAlert = ExportAlertController(titleAlert: "Are you sure you want to export this photo? the photo will become public and not encrypt")
        exportAlert?.delegate = self
        self.present(exportAlert!, animated: true, completion: nil)
    }
    
    func export(image:UIImage)
    {
        exporter = ExportImage()
        exporter?.delegate = self
        exporter?.export(image: image)
    }
    func exportVideo(atPath:String)
    {
        exporter = ExportImage()
        exporter?.delegate = self
        exporter?.exportVideo(atPath: atPath)
    }
    
    func result(_ resualt: Resualt) {
        switch resualt {
            case .error(let error): userAlert(title: "Oh No", message: error.localizedDescription)
            case .success: userAlert(title: "Asset successfully exported", message: "You can see it now on Photo Gallery")
        }
        exporter = nil
    }
    
    func configToolBar()
    {
        toolBar = DetailVCToolBar(frame: CGRect.zero, state: .normal)
        toolBar?.updateToolbarFrame(size: UIScreen.main.bounds.size)
        toolBar?.delegateToolBar = self
        self.view.addSubview(toolBar!)
        let cellData = viewModel!.getCellData(at: currentImageIndex!)
        toolBar?.updateLikeButton(like: (cellData.isFavorite))
    }
    
    func like(){
        modelController?.updateFavoriteAsset(at: currentImageIndex!)
        let cellData = (modelController?.getCellData(at: currentImageIndex!))!
        toolBar?.updateLikeButton(like: cellData.isFavorite)
        if !cellData.isFavorite{indexsToDelete.insert(currentImageIndex!)
        }else { if (indexsToDelete.contains(currentImageIndex!)){ indexsToDelete.remove(currentImageIndex!)}}
    }

    func pause() {
        if let cell = slideShow?.cellForItem(at: currentImageIndex!) as? VideoDetailCell
        {
            cell.pauseVideo()
            slideShowState = .pauseVideo
        }
    }
    func resetVideo()
    {
        if let cell = slideShow?.cellForItem(at: currentImageIndex!) as? VideoDetailCell
        {
            cell.resetVideo()
            slideShowState = .normal
        }
    }
    
}

extension PhotoDetail: TrashAlertProtocol
{
    
    internal func deletePhotos() {
        
        AlbumMenagerHelper.deletePhotosFromCameraRoll(indexes: [currentImageIndex!], albumName:albumName, ascending: true, complition:{[unowned self] (section,sectionToDelete, success) in
            if success
            {
                if let cell = slideShow?.cellForItem(at: self.currentImageIndex!) as? VideoDetailCell{
                    cell.fadeIn(withDuration: 0.2, curve: .easeIn)
                }
                self.slideShow?.deleteItems(at: [self.currentImageIndex!])

                
                AlbumMenagerHelper.deleteEmptySections(sections: sectionToDelete, compltion: {[unowned self] (success) in
                    
                    
                    let isEmptyAlbum = modelController?.isEmptyAlbum
                    let isLastPhoto = modelController?.isLastPhoto
                    let isMultypleSection = modelController?.isMultypleSection
                    
                    /////// check if it is multiple sections kind album
                    // if true delete sections from collection view
                    if isMultypleSection! { self.slideShow?.deleteSections(section as IndexSet) }
                    self.updateCurrentIndex()
                    if isLastPhoto! {print("last photo"); self.currentImageIndex = [0,0] }
                    if isEmptyAlbum! {
                        let segueData = DismissData()
                        self.dismissPhotoDetail(segueData)
                    }
                })
            }
        })
    }
    
    func addTrashAlert()
    {
        let isUserAlbum = modelController?.isUserAlbum
        trashAlert = TrashAlertController.init(numOfPhotoToDelete: 0, isUserAlbum:isUserAlbum!)
        trashAlert?.delegate = self
        self.present(trashAlert!, animated: true, completion: nil)
    }
    
    internal func removeFromAlbum()
    {
        
        AlbumMenagerHelper.deletePhotoFromAlbum(indexes: [currentImageIndex!], albumName: albumName, ascending: true, complition: {[unowned self] success in
            let isEmptyAlbum = modelController?.isEmptyAlbum
            let isLastPhoto = modelController?.isLastPhoto
            if success { self.slideShow?.deleteItems(at: [self.currentImageIndex!])
                self.updateCurrentIndex()
                if isLastPhoto! {print("last photo"); self.currentImageIndex = [0,0] }
                if isEmptyAlbum! {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
}

extension PhotoDetail
{

    func loadEditPhotoController()
    {
        DispatchQueue.global().async {
            let imageToEdit:ImageToEdit = (self.modelController?.getImageToEdit(at: self.currentImageIndex!))!
            self.imageEditorController = EditImageViewController(assetID: imageToEdit.photoId)
                DispatchQueue.main.async {
                    self.editNavigationController = UINavigationController(navigationBarClass: UINavigationBar.self, toolbarClass: nil)
                    self.editNavigationController.pushViewController(self.imageEditorController!, animated: false)
                    self.present(self.editNavigationController!, animated:false, completion: nil)
                }
        }
    }
}

extension PhotoDetail: VideoDetailCellDelegate
{
    func playButtonDidPress(){ slideShowState = .playVideo  }
    func tapOnceOnVideoLayer()
    {
        displayState = displayState == .notFullScreen ? .fullScreen : .notFullScreen
    }
    
    func videoDidReachToEnd() {
        slideShowState = .normal
        displayState = .notFullScreen
    }
}

struct DismissData {
    
    var indexPathToDelete:Set<IndexPath>?
    var currentIndex:IndexPath?
    init(indexPath:Set<IndexPath>? = nil, currentIndex:IndexPath? = nil) {
        self.indexPathToDelete = indexPath
        self.currentIndex = currentIndex
    }
   
}

enum DisplayState
{
    case fullScreen
    case notFullScreen
}

enum SlideShowState
{
    case normal
    case playVideo
    case pauseVideo
}

enum DeviceOrientation
{
    case portrait
    case landscape
}


enum DataError: Error {
    case noData
}

