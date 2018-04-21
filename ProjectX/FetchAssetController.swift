//
//  FetchAssetController.swift
//  ProjectX
//
//  Created by amir lahav on 4.11.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit
import Photos
import Cartography

class FetchAssetController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NavigatinoBarButtonsProtocol {

    

    fileprivate var assets:PHFetchResult<PHAsset>? = nil
    fileprivate var grid:UICollectionView? = nil

    
    open var saveAssetsToDB:([PHAsset])->() = {_ in }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configeCollectionView()
        checkPhotoLibraryPermission()
        
        
        self.view.backgroundColor = .white
        setupNavigation()
        // Do any additional setup after loading the view.
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: fetchAssets()
        case .denied, .restricted : break
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() {[unowned self] status in
                switch status {
                case .authorized: DispatchQueue.main.async {
                    self.fetchAssets()
                }
                // as above
                case .denied, .restricted: break
                // as above
                case .notDetermined: break
                    // won't happen but still
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePromptTitle()
        self.navigationController?.navigationBar.topItem?.title = "Select Photos"
    }

    deinit {
        print("deinit fetchController")
    }
    
    func fetchAssets()
    {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                         ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d",
                                             PHAssetMediaType.image.rawValue,
                                             PHAssetMediaType.video.rawValue)
        
        assets = PHAsset.fetchAssets(with: fetchOptions)
        grid?.reloadData()
        
        
    }
    
    func setupNavigation()
    {
        self.navigationItem.updateLeftBarItems(buttonType: [.cancel], delegate: self)
        self.navigationItem.updateRightBarItems(buttonType: [.doneEditAlbum], delegate: self)
    }
    
    func navigationBarButtonDidPress(sender: NavigationBarButtonsType) {
        switch sender {

        case .cancel:             cancelButtonDidPress()
        case .doneEditAlbum:      doneButtonDidPress()

        default: print("unknow button press")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func configeCollectionView()
    {
        let layout = CustomImageFlowLayout(withHeader: false)
        grid = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.view.addSubview(grid!)
        constrain(grid!,self.view) {table, vc in table.edges == vc.edges}
        grid?.backgroundColor = .white
        grid?.delegate = self
        grid?.dataSource = self
        grid?.register(PhotoCell.self)
        grid?.register(SloMoCell.self)
        grid?.allowsMultipleSelection = true
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard  let numberOfPhotos = assets?.count else {
            return 0
        }
        return numberOfPhotos
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        options.deliveryMode = .opportunistic
        let asset = assets?.object(at: indexPath.row)
        var image:UIImage? = nil
        PHImageManager.default().requestImage(for: asset!, targetSize: CGSize(width: 256, height:256), contentMode: .aspectFill, options: options) { (fetchImage, dic) in
            image = fetchImage
        }
        switch asset!.mediaType {
        case .image:
            let imageCell:PhotoCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            imageCell.imageView.image = image
            imageCell.like((asset?.isFavorite)!)
            return imageCell
        default:
            let videoCell:SloMoCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            videoCell.imageView.image = image
            videoCell.setupTimeLabel(String.stringFromTimeInterval(interval: (asset?.duration)!))
            videoCell.like((asset?.isFavorite)!)
            return videoCell
        }
        
    }
    
    func updatePromptTitle()
    {
        guard let assets = grid?.indexPathsForSelectedItems else { return  }
        self.navigationController?.navigationBar.topItem?.prompt = TitleHelper.getPrompTitle(with: assets.count, and: "Xproject")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updatePromptTitle()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected = false
        updatePromptTitle()
    }

    func doneButtonDidPress() {
        if grid?.indexPathsForSelectedItems?.count == 0 {
            dismissSelf()
        }
        var assets = [PHAsset]()
        for index in (grid?.indexPathsForSelectedItems)! {
            let asset = self.assets![index.row]
            assets.append(asset)
        }
        saveAssetsToDB(assets)
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress() {  dismissSelf() }
    
    func dismissSelf()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
