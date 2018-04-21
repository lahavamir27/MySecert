//
//  AlbumVC.swift
//  ProjectX
//
//  Created by amir lahav on 17.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit
import RealmSwift
import Cartography
import MapKit
import CoreLocation

protocol AlbumVCProtocol:class {

}


class AlbumVC: UIViewController, UserAlertProtocol {

    fileprivate let numberOfSections:Int = 2
    fileprivate var modelController:AlbumModelController? = nil
    fileprivate var inputTextField: UITextField?
    fileprivate var albumGrid:UICollectionView? = nil
    fileprivate var addAlbumAlert : AddAlbumAlert? = nil
    fileprivate var allowEdit:Bool = false
    fileprivate var selectedCell: IndexPath? = nil
    fileprivate var deleteSelectedCell: IndexPath? = nil
    fileprivate var photoViewModel: PhotoModelController!
    fileprivate var newAlbum:String? = nil
    fileprivate var deleteAlbumAlert:DeleteAlbumAlert?
    
    open var didSelectPhoto:(SegueData)->()  = { _ in }
    open var didSelectAlbum:(PushAlbumData)->()  = { _ in }
    open var addPhotosData:AddPhotosData? = nil
    open var addPhotoToAlbum:(IndexPath)->() = {_ in }
    open var cancelAddPhotoToAlbum:()->() = {_ in }
    fileprivate var albumState:AlbumState? = nil {

        didSet{
            switch albumState! {
            case .normal:
                self.navigationItem.updateLeftBarItems(buttonType: [.newAlbum], delegate: self)
                self.navigationItem.updateRightBarItems(buttonType: [.editAlbum, .search], delegate: self)
                allowEdit = false
                albumGrid?.collectionViewLayout.invalidateLayout()
                albumGrid?.reloadData()
                self.navigationController?.navigationBar.topItem?.title = "Albums"
                scroll(to: .top)
                break
            case .createUserAlbum:
                break
            case .editUserAlbum:
                self.navigationItem.updateRightBarItems(buttonType: [.doneEditAlbum], delegate: self)
                allowEdit = true
                albumGrid?.reloadData()
                scroll(to: .userAlbum)
                break
            case .finishAddingAlbum:
                break
            case .addPhotos:
                self.navigationItem.updateRightBarItems(buttonType: [.cancel], delegate: self)
                self.navigationController?.navigationBar.topItem?.title = "Add to Album"
                break
            case .animation:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumState = .normal
        configeCollectionView()
        // Do any additional setup after loading the view.
        modelController = AlbumModelController()
        photoViewModel = PhotoModelController(albumName: "Moment")
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let data = addPhotosData {albumState = data.state; }
        modelController?.removeEmptySections()
        modelController?.removeEmptyAlbums(complitionHandler: {[unowned self](sucsess) in
            if sucsess {self.albumGrid?.reloadData()}
        })
        switch albumState! {
        case .addPhotos:    navigationController?.navigationBar.prefersLargeTitles = false
                            self.navigationController?.navigationBar.sizeToFit()
                            self.additionalSafeAreaInsets.top = 70
                            scroll(to: .userAlbum)
            
        default:            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        albumGrid?.reloadData()
       

        
    }
    
    func registerObserver()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("album grid deinit")
    }

}


extension AlbumVC: UICollectionViewDataSource, UICollectionViewDelegate, AlbumCellProtocol
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let numberOfItemsInSection = modelController?.numberOfItemsIn(section) else { return 0}
        return numberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let albumType = modelController?.getAlbumType(at: indexPath)
        if  albumType == .places
        {
        let cell:MapCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            DispatchQueue.global().async {_ in
                LocationManagerHelper.requestSnapshotData(complition:{(image) in
                    DispatchQueue.main.async {
                        cell.image.image = image}})
                
            }
            cell.numberOfPhotos.text = modelController?.getNumberOfPhotosInAlbum(at: indexPath)
            cell.photoImage.image = modelController?.getAlbumCover(at: indexPath)

            return cell
        }
        
        if albumType == .people
        {
            let cell:FacesCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.upperLeft.image = nil
            cell.upperRight.image = nil
            cell.buttomLeft.image = nil
            cell.buttomRight.image = nil
            DispatchQueue.global().async {
                let photos = self.modelController?.getPhotoForPeopleAlbum(at: indexPath)
                DispatchQueue.main.async {
                    cell.upperLeft.image = photos?.upperLeft
                    cell.upperRight.image = photos?.upperRight
                    cell.buttomLeft.image = photos?.buttomLeft
                    cell.buttomRight.image = photos?.buttomRight
                }
            }
            cell.numberOfPhotos.text = modelController?.getNumberOfPhotosInAlbum(at: indexPath)
            return cell
        }
        
        let cell:MainCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.delegate = self

        cell.albumNameLbl.text = modelController?.getAlbumName(at: indexPath)
        cell.numberOfPhotosLbl.text = modelController?.getNumberOfPhotosInAlbum(at: indexPath)
        cell.albumImage.image = nil
        DispatchQueue.global().async {
            let photo = self.modelController?.getAlbumCover(at: indexPath)
            DispatchQueue.main.async {
                cell.albumImage.image = photo
            }
        }
        cell.deleteBtn.isHidden = canDeleteAlbum(at: indexPath)
        cell.minusIcon.isHidden = canDeleteAlbum(at: indexPath)

        return cell
    }
    
    func canDeleteAlbum(at indexPath:IndexPath) -> Bool
    {
        switch (indexPath.section, allowEdit) {
        case (AlbumSectionType.userSection.hashValue, true): return false
        default: return true }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch albumState! {
        case .normal:
            guard let pushData = modelController?.getAlbumData(at: indexPath) else { return}
            didSelectAlbum(pushData)
        case .addPhotos:
            addPhotoToAlbum(indexPath)
            albumState = .animation
            startAnimationToCell(at: indexPath)
            selectedCell =  indexPath

        default: print("selcet")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        switch albumState! {
        case .addPhotos:
            if indexPath.section == AlbumSectionType.userSection.hashValue {return true} else {
                userAlert(title: "Sorry", message: "You can only add photos to your personal albums")
                return false}
        case .animation: return false
        default:
            return true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.albumState == .finishAddingAlbum{
            print("start animation")
            //                        startAnimationToCell(at: path)
        }
    }
    

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView: CollectionReusableViewAlbumHeader = collectionView.dequeueReusableSupplementaryView(kind: UICollectionElementKindSectionHeader, indexPath: indexPath)
        headerView.headerText.text = "My Albums"
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        guard let numberOfItems = modelController?.numberOfItemsIn(section) else { return CGSize(width: collectionView.frame.width, height: 0) }
        if section == 1 && numberOfItems > 0 { return CGSize(width: collectionView.frame.width, height: 36) } else { return CGSize(width: collectionView.frame.width, height: 0) }
    }
    
    func scroll(to: ScrollTo)
    {
        switch to {
            case .top: albumGrid?.scrollToItem(at: [0,0], at: .top, animated: true)
            case .userAlbum:  if (modelController?.numberOfItemsIn(1))! > 0 { albumGrid?.scrollToItem(at: [1,0], at: .centeredVertically, animated: true)}
        }
    }

    
}

extension AlbumVC
{
    func configeCollectionView()
    {
        let layout = AlbumVCFlowLayout()
        albumGrid = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.view.addSubview(albumGrid!)
        constrain(albumGrid!,self.view) {table, vc in table.edges == vc.edges}
        albumGrid?.backgroundColor = .white
        albumGrid?.delegate = self
        albumGrid?.dataSource = self
        albumGrid?.register(MainCollectionViewCell.self)
        albumGrid?.register(MapCollectionViewCell.self)
        albumGrid?.register(FacesCollectionViewCell.self)
        albumGrid?.register(CollectionReusableViewAlbumHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    func rotated() {
        albumGrid?.collectionViewLayout.invalidateLayout()
        
    }
}

extension AlbumVC
{
    func showSearchBar()
    {
        let search = SearchViewController()
        let nv = UINavigationController(rootViewController: search)
        nv.view.backgroundColor = .white
        self.present(nv, animated: false, completion: nil)
    }
}

extension AlbumVC: NavigatinoBarButtonsProtocol
{
    func navigationBarButtonDidPress(sender: NavigationBarButtonsType) {
        switch sender {
            case .cancel:           cancelAddPhotos()
            case .newAlbum:         createNewAlbum()
            case .editAlbum:        albumState = .editUserAlbum
            case .doneEditAlbum:    albumState = .normal
            default: print("unknown button pressed");      break
        }
    }    
    func createNewAlbum() {
        scroll(to: .userAlbum)
        addAlbum()
//        if albumState != .addPhotos {albumState = .normal}
    }

    func cancelAddPhotos()
    {
        cancelAddPhotoToAlbum()
        self.dismiss(animated: true, completion: nil)
    }

}

extension AlbumVC:AddAlbumProtocol
{
    func addAlbum()
    {
        addAlbumAlert = AddAlbumAlert(title: "New Album", message: "Enter name for this album.", preferredStyle: .alert)
        addAlbumAlert?.addButtonsToAlert()
        addAlbumAlert?.albumDelegate = self
        present(addAlbumAlert!, animated: true, completion: nil)

    }
    func cancelDidPress(){addAlbumAlert = nil}
    
    func searchButtonDidPress() {
        showSearchBar()
    }

    func saveNewAlbum(name: String) {
        saveNewAlbum(with: name)
        addAlbumAlert = nil
    }
    
    func saveNewAlbum(with albumName:String)
    {
        guard let isExist = modelController?.isAlbum(exist: albumName) else { return }
        if !isExist
        {
                    AlbumMenagerHelper.createUserAlbum(albumName: albumName)
                    let path = IndexPath(item: 0, section: 1)
                    albumGrid?.insertItems(at: [path])
                    newAlbum = albumName
                    switch albumState! {
                    case .addPhotos: addPhotosToNewAlbumWithAnimatino(at: path)
                    case .normal: popupGridController()
                    default: break
                    }
                    
        } else { addExistAlert() }
    }
    
    func addExistAlert()
    {
        let alert = UIAlertController(title: "Ohh no", message: "Album is already Exist. Please change Album Name", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
            //Do some stuff
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldDidChange(textField: UITextField) {
        let alert = self.presentedViewController as! UIAlertController
        if textField.text?.characters.count == 0 {
            alert.actions[1].isEnabled = false
        }else
        {
            alert.actions[1].isEnabled = true
        }
    }
    
    func popupGridController()
    {
        let vc = PhotoController(albumName: "Moments")
        let data = PushAlbumData(albumName: "Moments", tabType: nil, albumType: .day, gridState:.addPhotosToAlbum, promptName: newAlbum)
        vc.pushAlbumData = data
        vc.addPhotoToAlbum = savePhotosToNewAlbum
        let NC = UINavigationController(rootViewController: vc)
        NC.navigationBar.topItem?.prompt = "Add photos to \"\(newAlbum!)\"."
        self.present(NC, animated: true, completion: nil)
    }
    
    func savePhotosToNewAlbum(indexs:[IndexPath])
    {
        photoViewModel.add(assets: indexs, from: "Moments", to: newAlbum!)
    }
}

extension AlbumVC : DeleteAlbumProtocol
{
    func cancelDeleteAlbum() {
         deleteAlbumAlert = nil
    }
    
    func shouldDeleteAlbum() {
        guard let indexPath = deleteSelectedCell else {print("Cant find indexPath of deleted album"); return }
        AlbumMenagerHelper.removeAlbum(at: indexPath, complite: {[unowned self] (suuc) in
            self.albumGrid?.deleteItems(at: [indexPath])
            deleteAlbumAlert = nil
        })
    }
    
    func deleteAlbumBtnDidPress(cell: MainCollectionViewCell?)
    {
        guard let cell = cell else { return }
        guard let indexPath = albumGrid?.indexPath(for: cell) else {print("something went wrong, cant delete album)"); return}
        deleteSelectedCell = IndexPath(item: indexPath.item, section: indexPath.section)
        guard let albumName = modelController?.getAlbumName(at: indexPath) else {print("cant get album name, please help"); return}
        showDeleteAlert(albumName: albumName)
    }
    
    func showDeleteAlert(albumName:String)
    {
        deleteAlbumAlert = DeleteAlbumAlert(albumName: albumName)
        deleteAlbumAlert?.deleteAlbumAlertDelegate = self
        self.present(deleteAlbumAlert!, animated: true, completion: nil)
    }
}


extension AlbumVC: CAAnimationDelegate
{
    
    func addPhotosToNewAlbumWithAnimatino(at path:IndexPath)
    {
        let scrollDelay = DispatchTime.now() + 0.01
        let flyAnimtionDelay = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: scrollDelay) {[unowned self] _ in
            self.scroll(to: .userAlbum)
        }
        DispatchQueue.main.asyncAfter(deadline: flyAnimtionDelay) {[unowned self] _ in
            self.addPhotoToAlbum(path)
            self.albumState = .animation
            self.startAnimationToCell(at: path)
        }
    }
    
    func animate(view : UIView, fromPoint start : CGPoint, toPoint end: CGPoint)
    {
        // The animation
        let animation = CAKeyframeAnimation(keyPath: "position")
        let fadeAnimation = CAKeyframeAnimation(keyPath: "opacity")
        fadeAnimation.values                        = [1.0,1.0,1.0,0.0]
        let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotationAnimation.values                        = [0,0,0.2]
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values                        = [1.0,1.0,1.3,0.8]
        // Animation's path
        let path = UIBezierPath()
        
        // Move the "cursor" to the start
        path.move(to: start)
        
        // Calculate the control points
        let c1 = CGPoint(x: start.x + 64 , y: start.y - 64)
        let c2 = CGPoint(x: end.x + 64   , y: end.y   - 128)
        
        // Draw a curve towards the end, using control points
        path.addCurve(to: end, controlPoint1: c1, controlPoint2: c2)
        
        // Use this path as the animation's path (casted to CGPath)
        animation.path = path.cgPath;
        
        // Apply it
        
        let animationGroup: CAAnimationGroup = CAAnimationGroup()
        animationGroup.animations = [ animation, fadeAnimation, rotationAnimation,scaleAnimation]
        animationGroup.duration = 0.55
        animationGroup.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
        animationGroup.delegate = self
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = kCAFillModeForwards
        
        view.layer.add(animationGroup, forKey:"group")
    }
    
    func startAnimationToCell(at indexPath:IndexPath)
    {
        let cell = albumGrid?.cellForItem(at: indexPath)
        guard let cellCenter = cell?.center  else {  return }
        guard let nav = self.navigationController as? AddToUINavigationController else  {return}
        guard let imageCenter = nav.imageView?.center else { return }
        if var center = albumGrid?.convert(cellCenter, to: albumGrid?.superview) {
            center.y = center.y - 48.0
            nav.removeSecondImage()
            animate(view: nav.imageView!, fromPoint: imageCenter, toPoint: center)
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        self.dismiss(animated: true, completion: nil)
    
    }
    
}


enum AlbumState
{
    case editUserAlbum
    case createUserAlbum
    case finishAddingAlbum
    case normal
    case addPhotos
    case animation

}

enum AlbumSectionType
{
    case systemSection
    case userSection
}
enum ScrollTo
{
    case top
    case userAlbum
}

struct AddPhotosData {
    var assets:[IndexPath]?
    var state:AlbumState?
    init(with assets:[IndexPath]? = nil, albumState:AlbumState? = nil) {
        self.assets = assets
        self.state = albumState
    }
}

struct ImageData {
    var indexPath:IndexPath?
}



