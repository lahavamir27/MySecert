//
//  FirstViewController.swift
//  ProjectX
//
//  Created by amir lahav on 14.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit
import Cache
import Cartography
import Photos
import RealmSwift
import YangMingShan


class PhotoController: UIViewController, UserAlertProtocol {

    
    final let kToolBarHeight:CGFloat = 49.0
    open var hideButtomTabBar:(Bool) -> () = { _ in }
    open var didSelectPhoto:(SegueData)->()  = { _ in }
    open var addPhotoToAlbum:([IndexPath])->() = {_ in }
    
    
    fileprivate var pinnedIndexPath:IndexPath = [0,0]
    fileprivate var selectedSection = [Int]()
    fileprivate var totalnumOfAssetsToSave:Int = 0
    fileprivate var numOfAssetsLeftToSave:Int = 0
    fileprivate var initState:AppState = .normal
    fileprivate var headerState:HeaderState = .normal
    fileprivate let cache = HybridCache(name: "Mix")
    fileprivate var grid:UICollectionView? = nil
    fileprivate var albumName = ""
    fileprivate var albumVC:AlbumVC? = nil
    fileprivate var loadImageHelper = LoadImageHelper()
    fileprivate var fetchViewContrller:FetchAssetController? = nil
    fileprivate var searchController : UISearchController!
    fileprivate var layout:CustomImageFlowLayout!
    open var selectedIndex: IndexPath?
    open var segueData:SegueData? = nil
    open var pushAlbumData: PushAlbumData? = nil
    open var dismissData:DismissData? = nil

    
    
    fileprivate var notificationToken: NotificationToken? = nil
    fileprivate var savingAlertController:SavingProgerAlertConroller? = nil
    fileprivate var toolBar:CollectionViewToolBar? = nil
    fileprivate var albumType:AlbumType = .day
    fileprivate var trashAlert: TrashAlertController? = nil
    fileprivate var sourcePickerAlert: SourcePickerViewController? = nil
    fileprivate var search: SearchViewController? = nil
    fileprivate var saveHelper = SaveAssets()

    fileprivate var userPickedAssets:[PHAsset]? = nil
    fileprivate var userSelectedAssets: [IndexPath]? = nil
    fileprivate var sectionType:SectionType = .day
    fileprivate var hideTabBar:Bool = false
    fileprivate var allowSegue:Bool = false
    fileprivate var tabType:TabType? = .photoGrid
    fileprivate var emptyStateView:EmptySatateView? = nil
    fileprivate var modelController:PhotoModelController? = nil
    fileprivate var addToNavigationController: AddToUINavigationController? = nil
    fileprivate var searchNavController:UINavigationController? = nil
    fileprivate var assets = [[(id:String, isFavorite:Int, mediaAsset:Int)]]()
    fileprivate var selectedHeaders:[IndexPath]? = nil
    fileprivate var numberOfPhotosInAlbum:Int = 0
    { didSet { if numberOfPhotosInAlbum == 0 { self.viewState = .empty }}}
    
    // MARK: View State Controller
    /// controll the view state
    fileprivate var viewState:AppState? = nil {
        
        didSet{
            switch viewState! {
            case .normal:

                updateNavigaitonBar(at: .normal, tabType: tabType!)
                configToolbar(hide: true)
                hideButtomTabBar(false)
                allowSegue = true
                updateTitle()
                emptyStateView?.isHidden = true
                headerState = .normal
                grid?.deselectAll(animated: false)
                selectedSection.removeAll()
                selectButton(add: false)

                grid?.collectionViewLayout.invalidateLayout()
                print(".normal")
                
            case .reloading:
                break
                
            case .selectPhotos:
                
                updateNavigaitonBar(at: .selectPhotos, tabType: tabType!)
                configToolbar(hide: false)
                hideButtomTabBar(true)
                allowSegue = false
                headerState = .select
                updateTitle()
                grid?.deselectAll(animated: false)
                selectButton(add: true)

            case .savingPhotos: showSaveAlert()
           
            case .finishSavingPhotos: dismissSaveAlert()
           
            case .empty:
                
                emptyStateView?.isHidden = false
                updateNavigaitonBar(at: .empty, tabType: tabType!)
                configToolbar(hide: !hideTabBar)
                hideButtomTabBar(false)
                updateTitle()
           
            case .addPhotosToAlbum:

                emptyStateView?.isHidden = true
                updateNavigaitonBar(at: .addPhotosToAlbum, tabType: tabType!)
                updateTitle()
                headerState = .select
                grid?.reloadData()
            }
        }
    }

    

    
    

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("viewDidLoad")

        initilize(data: pushAlbumData)
        configeCollectionView()
        createEmptyView()
        registerObserver()
        
    }
    
    convenience init(albumName:String)
    {
        self.init()
        modelController = PhotoModelController(albumName: albumName)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        notificationToken?.invalidate()
        print("photo grid deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        modelController?.removeUnFavoriteAsstes()
        grid?.reloadData()
        grid?.collectionViewLayout.invalidateLayout()
        numberOfPhotosInAlbum = (modelController?.numberOfPhotosInAlbum)!
        updateTitle()
        switch tabType! {
        case .photoGrid:
            navigationController?.navigationBar.prefersLargeTitles = true
        default:
            navigationController?.navigationBar.prefersLargeTitles = false
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        numberOfPhotosInAlbum = (modelController?.numberOfPhotosInAlbum)!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.titleView = nil
//        grid?.reloadData()
    }
    
    // MARK: Initilizer
    
    func initilize(data:PushAlbumData? = nil)
    {
        let initData:InitiailData = InitiailData(pushData: data)
        albumName = (modelController?.albumName)!
        albumType = (modelController?.albumType)!
        tabType = initData.tabType
        viewState = initData.gridState
    }
 
    func createEmptyView()
    {
        emptyStateView = EmptySatateView(frame: CGRect.zero, albumType: albumType)
        emptyStateView?.isHidden = true
        self.view.addSubview(emptyStateView!)
        constrain(emptyStateView!,self.view) {emptyView, vc in emptyView.edges == vc.edges}
    }
    
    func registerObserver()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    
    }
    func appMovedToBackground() {
        print("App moved to background!")
        viewState = .normal
        dismissAlerts()
    }
    
    func dismissAlerts()
    {
        trashAlert?.dismiss(animated: false, completion: {[unowned self] _ in self.trashAlert = nil})
        sourcePickerAlert?.dismiss(animated: false, completion: {[unowned self] _ in self.sourcePickerAlert = nil})
        addToNavigationController?.dismiss(animated: false, completion: {[unowned self] _ in self.addToNavigationController = nil})
        searchNavController?.dismiss(animated: false, completion: {[unowned self] _ in
            self.search = nil
            self.searchNavController = nil})
        savingAlertController?.dismiss(animated: false, completion:{[unowned self] _ in self.savingAlertController = nil} )
        sourcePickerAlert?.dismiss(animated: false, completion:{[unowned self] _ in self.sourcePickerAlert = nil} )
        fetchViewContrller?.dismiss(animated: false, completion:{[unowned self] _ in self.fetchViewContrller = nil} )
        saveHelper.stop()
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("back to business")
    }
    
    func configeCollectionView()
    {
        layout = CustomImageFlowLayout(withHeader: (modelController?.needHeader)!)
        layout.delegate = self
        grid = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.view.addSubview(grid!)
        constrain(grid!,self.view) {table, vc in table.edges == vc.edges}
        grid?.backgroundColor = .white
        grid?.delegate = self
        grid?.dataSource = self
        grid?.allowsMultipleSelection = true
        grid?.register(PhotoCell.self)
        grid?.register(SloMoCell.self)
        grid?.register(CollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        grid?.register(UINib(nibName: "CollectionReusableViewFooter", bundle: nil ), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer")
    }

}

// MARK: Collection View Delegate

extension PhotoController:UICollectionViewDataSource, UICollectionViewDelegate, CustomImageFlowLayoutProtocol
{
    func pinnedSection(at: IndexPath) {
        
        guard let header =  grid?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: at) as? CollectionViewHeader else { return }
        header.bloorBackground.isHidden = false
        pinnedIndexPath = at
    }
    
    
    func notPinnedSection(at: IndexPath) {
        
        guard let header =  grid?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: at) as? CollectionViewHeader else { return }
        header.bloorBackground.isHidden = true
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (modelController?.numberOfSections)!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return (modelController?.numberOfItemsIn(section))!
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellData = (modelController?.getCellData(at: indexPath))!
        let id = cellData.photoId
        
        switch cellData.assetType! {
        case .video:
            let cell:SloMoCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.imageView.image = nil
            modelController?.getImage(id: id, imageSize: .thumbnail, handler: { (image, imageID) in
                DispatchQueue.main.async { if imageID == id{  cell.imageView.image = image }  }})
            cell.like(cellData.isFavorite)
            cell.setupTimeLabel(cellData.assetDuration)
            return cell
        case .image:
            let cell:PhotoCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.imageView.image = nil
            modelController?.getImage(id: id, imageSize: .thumbnail , handler: { (image, imageID) in
                DispatchQueue.main.async { if imageID == id{  cell.imageView.image = image
                    if (self.modelController?.isNotSafe(at: indexPath))!{
                        cell.imageView.image = #imageLiteral(resourceName: "icons8-do-not-disturb-filled-40.png")
                    }
                    }  }})
            cell.like(cellData.isFavorite)
            cell.likeIamge.isHidden = !cellData.isFavorite
            
            return cell
        default:
            
            let cell:PhotoCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            return cell
        }
 
}
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        if allowSegue
        {
            let segueData = SegueData(indexPath:selectedIndex!, albumName:albumName, tabType:tabType)
            let cell = grid?.cellForItem(at: indexPath)
            cell?.isSelected = false
            didSelectPhoto(segueData)
        }
        if viewState == .addPhotosToAlbum { updatePromptTitle()} else {updateToolbarAfterSelect()}
        guard let numOfPhotos = grid?.indexPathsForSelectedItems?.count else {return}
        if numOfPhotos == modelController?.numberOfPhotosInAlbum { toolBar?.swithSelectAl(sender: .selectAll)}
    }
 
     func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected = false
        if let index = selectedSection.index(of: indexPath.section) {
            selectedSection.remove(at: index)
        }
        if let header = grid?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: indexPath.section)) as? CollectionViewHeader {
            header.isSelected = false
        }
        if viewState == .addPhotosToAlbum { updatePromptTitle()} else { updateToolbarAfterSelect()}
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        let normalSzie = CGSize(width: (grid?.frame.size.width)!, height: 40.0)
        guard let headerData = modelController?.getHeader(for: section) else { return normalSzie }
        if !(modelController?.needHeader)! {return CGSize.zero}
        switch headerData.size {
            case .normal:  return normalSzie
            case .extended: return CGSize(width: (grid?.frame.size.width)!, height: 60.0)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let realm = try! Realm()
        let album = realm.objects(Album.self).filter("albumName == '\(albumName)'").first!
        if  kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! CollectionViewHeader
            let section = modelController?.getSortedListOfSection()[indexPath.section]
            let headerData = modelController?.getHeader(for: indexPath.section)
            headerView.setTitles(title: headerData?.title, subTitle: headerData?.subtitle, size: headerData?.size)
            headerView.headerState = headerState
            headerView.delegate = self
            headerView.indexPath = indexPath
            headerView.isSelected = selectedSection.contains(indexPath.section) ? true : false
            if indexPath == pinnedIndexPath {headerView.bloorBackground.isHidden = false}
            return headerView
        }
        if kind == UICollectionElementKindSectionFooter
        {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath) as! CollectionReusableViewFooter
            print("footer")
            footerView.configure(album:album)
            print(footerView)
            return footerView
            
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize
    {
        let lastSection = (modelController?.numberOfSections)! - 1
        return section == lastSection ? CGSize(width: UIScreen.main.bounds.size.width, height: 60) : CGSize.zero
    }
    
    func selectButton(add:Bool){
        guard let indexs = grid?.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionHeader) else { return }
        print(indexs)
        for index in indexs
        {
            guard let header = grid?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: index) as? CollectionViewHeader else {return}
            switch add{
            case true: header.headerState = .select
            case false: header.headerState = .normal
            }
        }
    }
}

// MARK: Tool Bar Delegate


extension PhotoController
{
    func updatePromptTitle()
    {
        guard let assets = grid?.indexPathsForSelectedItems else { return  }
        self.navigationController?.navigationBar.topItem?.prompt = TitleHelper.getPrompTitle(with: assets.count, and: (pushAlbumData?.promptName)!)
    }
}

// MARK: Header delegate

extension PhotoController:HeaderProtocol
{
    func selectBtnDidSelect(cell: UICollectionReusableView?, isSelected:Bool, indexPath:IndexPath?)
    {
        guard  let section = indexPath?.section else { return }
        switch isSelected {
            case true: grid?.selectAllItems(inSection: section, animated: true)
            selectedSection.append(section)
            default: grid?.deselectAllItems(inSection: section, animated: true)
            if let posistion = selectedSection.index(of: section) {
                selectedSection.remove(at: posistion)
            }
        }
        switch viewState! {
            case .addPhotosToAlbum: updatePromptTitle()
            case .selectPhotos: updateToolbarAfterSelect()
        default: break
        }
    }
}

// MARK: roatated view

extension PhotoController
{
    func rotated() {
        layout.barHeight = self.navigationController?.navigationBar.height
        grid?.collectionViewLayout.invalidateLayout()
        toolBar?.updateToolbarFrame()

    }
}


// MARK: Save

extension PhotoController:SaveAssetsProtocol
{
    func showUserAlert(title: String, message: String) {
        userAlert(title: title, message: message)
    }
    
    func willStartSaveAssets() {

        if totalnumOfAssetsToSave > 0{
            DispatchQueue.main.async {  self.viewState = .savingPhotos   }
        }
    }
    
    func numOfAssetToSave(num: Int) {
        totalnumOfAssetsToSave = num
        numOfAssetsLeftToSave = num
    }
    
    func finishSaveAsset() {
        DispatchQueue.main.async {
            self.savingAlertController?.setMessegeBody(message: "Analyzing and Decrypting photo \(self.totalnumOfAssetsToSave + 1 - self.numOfAssetsLeftToSave)/\(self.totalnumOfAssetsToSave)")
            let progress:Float = (Float(self.totalnumOfAssetsToSave + 1) - Float(self.numOfAssetsLeftToSave )) / Float(self.totalnumOfAssetsToSave + 1)
            self.numOfAssetsLeftToSave -= 1
            self.savingAlertController?.setProgress(progress: progress )
            if self.numOfAssetsLeftToSave == 0 {
                self.savingAlertController?.setMessegeBody(message: "Indexing...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {[unowned self] _ in
                    self.viewState = .normal
                    self.viewState = .finishSavingPhotos
                }
            }
        }
    }
    
    func savePhotosToNewAlbum(indexs:[IndexPath])
    {
        modelController?.add(assets: indexs, from: "Moments", to: albumName)
        viewState = .normal
    }
    
    func savePhotosToDB(assets:[PHAsset])
    {
        userPickedAssets = assets
        saveHelper.saveAssetsDelegate = self
        saveHelper.save(assets: assets)
        fetchViewContrller = nil
    }
    
    func dismissSaveAlert()
    {
        guard userPickedAssets != nil  else {
            viewState = .normal
            return
        }
        savingAlertController?.dismiss(animated: true, completion: {[weak self] _ in
            self?.grid?.reloadData()
            self?.savingAlertController = nil
            PHPhotoLibrary.shared().performChanges({[weak self] _ in self?.askUserToDeletePhotos()},
                                                   completionHandler: {[weak self] success, error in self?.clearPickedPhotos()})})
    }
    
    func askUserToDeletePhotos()
    {
        PHAssetChangeRequest.deleteAssets(self.userPickedAssets! as NSFastEnumeration)
    }
    
    func clearPickedPhotos()
    {
        self.userPickedAssets?.removeAll()
        self.userPickedAssets = nil
        DispatchQueue.main.async {[unowned self] in
            self.viewState = .normal
        }
    }
    
    func showSaveAlert() {
        savingAlertController = SavingProgerAlertConroller(title: "Please Wait", message: "Prepare...", preferredStyle: .alert)
        present(savingAlertController!, animated: true, completion: nil)
    }
}

// MARK: NavigationBar

extension PhotoController: NavigatinoBarButtonsProtocol
{
    func navigationBarButtonDidPress(sender: NavigationBarButtonsType) {
        switch sender {
        case .select:           selectPhotosState()
        case .cancel:           cancelSelectPhotosState()
        case .newPhoto:         addSourceAlert()
        case .editAlbum:        viewState = .selectPhotos
        case .doneEditAlbum:    donePickingPhotos()
        case .search:           showSearchBar()
        default: print("un wnated button did press")
        }
    }
    
    func updateNavigaitonBar(at state:AppState, tabType:TabType)
    {
        let buttons = NavigationHelper.updateNavigaitonBar(at: state, tabType: tabType, albumType: albumType)
        self.navigationItem.updateLeftBarItems(buttonType: buttons.0, delegate: self)
        self.navigationItem.updateRightBarItems(buttonType: buttons.1, delegate: self)
    }

    func selectPhotosState(){viewState = .selectPhotos}
    func cancelSelectPhotosState(){viewState = Bool((self.modelController?.numberOfPhotosInAlbum)!) ?  AppState.normal :  AppState.empty}
    func donePickingPhotos(){
        guard let indexs = grid?.indexPathsForSelectedItems else {userAlert(title: "Pick Photos", message: "No photos were picked") ; return}
        addPhotoToAlbum(indexs)
        self.dismiss(animated: true, completion: nil)
    }
    
    func showSearchBar()
    {
        search = SearchViewController()
        searchNavController = UINavigationController(rootViewController: search!)
        searchNavController?.view.backgroundColor = .white
        self.present(searchNavController!, animated: false, completion: nil)
    }
}

extension PhotoController: SourceAlertProtocol
{
    func addSourceAlert()
    {
        self.sourcePickerAlert = SourcePickerViewController(titleAlert: "Choose Source")
        self.sourcePickerAlert?.delegate = self
        self.present(self.sourcePickerAlert!, animated: true, completion: nil)
    }
    
    func showEventsAcessDeniedAlert() {
        let permissionAlert = PhotoPermissionAlertController(title: "", message: "", preferredStyle: .alert)
        present(permissionAlert, animated: true, completion: nil)
    }
    
    func showLibrary()
    {
        modelController?.checkPhotoLibraryPermission(complition: {[unowned self] (permission) in
            if permission {
                self.popupLiberayGrid()
                self.sourcePickerAlert = nil
            }else{
                self.showEventsAcessDeniedAlert()
                self.sourcePickerAlert = nil
            }
        })

    }
    func dismissPicker() {  sourcePickerAlert = nil}
    
    func popupLiberayGrid()
    {
        fetchViewContrller = FetchAssetController()
        let nc = UINavigationController(rootViewController: fetchViewContrller!)
        fetchViewContrller?.saveAssetsToDB = savePhotosToDB
        present(nc, animated: true, completion: nil)
    }
}

// MARK: Toolbar

extension PhotoController: ToolbarButtonsProtocol
{
    func updateToolbarAfterSelect()
    {
        let isUserAlbum = modelController?.isUserAlbum
        guard let indexPaths = grid?.indexPathsForSelectedItems else {userAlert(title: "Pick Photos", message: "No photos were picked") ; return}
        toolBar?.updateToolBarButton(isUserAlbum: isUserAlbum!, selectedPhotos: indexPaths.count)
        updateTitle()
    }
    
    func toolBarBtnDidPress(sender: ToolbarButtonsType) {
        
        switch sender {
        case .add:          showGridController()
        case .addTo:        addTo()
        case .trash:        addTrashAlert()
        case .selectAll:    selectAll()
        case .deSelectAll:  deSelectAll()
        case .unknown:      userAlert(title: "Sorry", message: "Something went wrong, Please try again")

        }
    }
    
    ///// delegate methods

    func deSelectAll() {

        shouldSelectAll(should: false)
        grid?.deselectAll(animated: false)
        switch viewState! {
        case .addPhotosToAlbum: updatePromptTitle()
        case .selectPhotos: updateToolbarAfterSelect()
        default: break
        }
        grid?.reloadData()
    }
    
    
    func shouldSelectAll(should: Bool)
    {
        let sections = ((modelController?.numberOfSections)!)
        selectedSection.removeAll()
        for i in 0...sections
        {
            if should { selectedSection.append(i) }
            if let section = grid?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: i)) as? CollectionViewHeader {section.isSelected = should}
        }
    }
    
    func selectAll() {

        shouldSelectAll(should: true)
        grid?.selectAll(animated: false)
        switch viewState! {
            case .addPhotosToAlbum: updatePromptTitle()
            case .selectPhotos: updateToolbarAfterSelect()
        default: break
        }
    }

    func showGridController()
    {
        let vc = PhotoController(albumName: "Moments")
        let data = PushAlbumData(albumName: "Moments", tabType: nil, albumType: .day, gridState:.addPhotosToAlbum, promptName: albumName)
        vc.pushAlbumData = data
        let NC = UINavigationController(rootViewController: vc)
        NC.navigationBar.topItem?.prompt = "Add photos to \"\(albumName)\"."
        self.present(NC, animated: true, completion: nil)
        vc.addPhotoToAlbum = savePhotosToNewAlbum
    }
    
    func addTo(){

        guard let indexs = grid?.indexPathsForSelectedItems else {userAlert(title: "Pick Photos", message: "No photos were picked") ; return}
        
        let imageData = (modelController?.getCellData(at: (indexs.first)!))
        let image = loadImageHelper.getImageWith(ID: (imageData?.photoId)!, and: .thumbnail)
        
        userSelectedAssets = [IndexPath]()
        userSelectedAssets?.append(contentsOf: indexs)
        
        albumVC = AlbumVC()
        albumVC?.addPhotoToAlbum = savePhotos
        albumVC?.cancelAddPhotoToAlbum = cancelPickAlbum
        let data = AddPhotosData(albumState: .addPhotos)
        albumVC?.addPhotosData = data
        
        addToNavigationController = AddToUINavigationController(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        addToNavigationController?.setViewControllers([albumVC!], animated: false)
        let title = String.photoCountToString(count: indexs.count)
        addToNavigationController?.data = AddToUINavigationControllerData(image: image, photoCount: title)
        if let NC = addToNavigationController {
            present(NC, animated: true, completion: nil)
        }
    
    }
    
    func savePhotos(at indexPath:IndexPath)
    {
        print("save photos")
        if let name = modelController?.getAlbumName(at: indexPath) {
            modelController?.add(assets: userSelectedAssets!,from: albumName,  to: name)
        }
        userSelectedAssets = nil
        albumVC = nil
        addToNavigationController = nil
        viewState = .normal
    }
    func cancelPickAlbum()
    {
        albumVC = nil
        addToNavigationController = nil
    }
    
    internal func addDidSelect(){showGridController()}
    
    func configToolbar(hide:Bool)
    {
        switch hide {
        case false:
            let isUserAlbum = modelController?.isUserAlbum
            guard let indexPaths = grid?.indexPathsForSelectedItems else { return}
            toolBar = CollectionViewToolBar(frame: CGRect.zero)
            toolBar?.updateToolbarFrame()
            toolBar?.updateToolBarButton(isUserAlbum: isUserAlbum!, selectedPhotos: indexPaths.count)
            toolBar?.delegateToolBar = self
            self.view.addSubview(toolBar!)
        default:
            toolBar?.removeFromSuperview()
            toolBar = nil
        }
    }
    
}

// MARK: Trash Alert


extension PhotoController: TrashAlertProtocol
{
    func addTrashAlert()
    {
        guard let numberOfPhotosToDelete = grid?.indexPathsForSelectedItems?.count else { return  }
        let isUserAlbum = modelController?.isUserAlbum
        trashAlert = TrashAlertController.init(numOfPhotoToDelete: numberOfPhotosToDelete, isUserAlbum:isUserAlbum!)
        trashAlert?.delegate = self
        self.present(trashAlert!, animated: true, completion: nil)
    }
    
    func removeFromAlbum()
    {
        guard let indexPaths = grid?.indexPathsForSelectedItems else { return}
        AlbumMenagerHelper.deletePhotoFromAlbum(indexes: indexPaths, albumName: albumName, ascending: true, complition: {[unowned self] success in
            if success {
                self.grid?.deleteItems(at: indexPaths)
                self.updateStateAfterDelete()
            }
        })
    }
    
    func deletePhotos() {
        deletePhotos(at: grid?.indexPathsForSelectedItems)
    }
    
    func deletePhotos(at indexsPaths:[IndexPath]?)
    {
        guard let indexPaths = indexsPaths else { return}

        AlbumMenagerHelper.deletePhotosFromCameraRoll(indexes: indexPaths, albumName:albumName, ascending: true, complition:{[unowned self] (section,sectionToDelete, success) in
            if success
            {
                self.grid?.deleteItems(at: indexPaths)
                print(section.description)
                print(sectionToDelete)
                
//                AlbumMenagerHelper.deleteEmptySections(sections: sectionToDelete, compltion: {[unowned self] (success) in
//
//                    /////// check if it is multiple sections kind album
//                    // if true delete sections from collection view
//                    if (modelController?.isMultypleSection)! { self.grid?.deleteSections(section as IndexSet) }
//                    grid?.reloadData()
//                    let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
//                    DispatchQueue.main.asyncAfter(deadline: when) {
//                        // Your code with delay
//                        self.updateStateAfterDelete()
//                    }
//
//
//                })
            }else{
                print("cant delete photo")
            }
        })
    }
    
    func cancelTrashAlert()
    {
        trashAlert = nil
    }
    
    func updateStateAfterDelete()
    {
        viewState = Bool((self.modelController?.numberOfPhotosInAlbum)!) ?  AppState.normal :  AppState.empty
        trashAlert = nil
        updateFooterTitle()
    }
}

extension PhotoController
{

    
    func updateTitle()
    {
        var numOfPhotosSelected = 0
        if let selectIndexs = grid?.indexPathsForSelectedItems { numOfPhotosSelected = selectIndexs.count}
        let title = TitleHelper.getTitle(indexCount:numOfPhotosSelected, albumName:albumName, stateView: viewState!)
        self.navigationItem.title = title

    }
    
    func updateFooterTitle()
    {
        let numberOfsection = (self.grid?.numberOfSections)! > 0
        if numberOfsection {
            let lastSection = NSIndexSet(index: (self.grid?.numberOfSections)!-1) as IndexSet
            self.grid?.reloadSections(lastSection)
        }
    }
}

enum UserSystemAlbumType
{
    case userAlbum
    case systemAlbum
}

enum AppState
{
    case reloading
    case selectPhotos
    case savingPhotos
    case finishSavingPhotos
    case normal
    case empty
    case addPhotosToAlbum
}

enum TabType
{
    case photoGrid
    case albumGrid
}

