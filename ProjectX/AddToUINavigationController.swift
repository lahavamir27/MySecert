//
//  AddToUINavigationController.swift
//  ProjectX
//
//  Created by amir lahav on 10.10.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit

fileprivate let navigationBarHeight:CGFloat = 112.0
fileprivate let imageViewX:CGFloat = 10.0
fileprivate let imageViewY:CGFloat = 76.0
fileprivate let imageViewWidth:CGFloat = 48.0
fileprivate let imageViewHeight:CGFloat = 42.0



class AddToUINavigationController: UINavigationController {

    public var imageView:UIImageView?
    public var seconedImageView:UIImageView?
    public var photoCounter:UILabel?

    public var data:AddToUINavigationControllerData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavBar()
    {
        setupImageView()
        setupPhotoCounter()
    }
    
    
    deinit {
        print("add to controller deinit")
    }
    
    private func setupPhotoCounter()
    {
        self.photoCounter = UILabel(frame: CGRect(x: 79, y: 86, width: 100, height: 24))
        photoCounter?.font = UIFont.preferredFont(forTextStyle: .headline)
        self.navigationBar.addSubview(photoCounter!)
        photoCounter?.text = data?.photoCount
    }
    
    private func setupImageView()
    {
        self.navigationBar.height = navigationBarHeight
        imageView = UIImageView(frame: CGRect(x: imageViewX, y: imageViewY, width: imageViewWidth  , height: imageViewHeight))
        imageView?.backgroundColor = .black
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        
        seconedImageView = UIImageView(frame: CGRect(x: imageViewX + 2, y: imageViewY - 2, width: imageViewWidth - 4  , height: imageViewHeight))
        seconedImageView?.backgroundColor = .black
        seconedImageView?.contentMode = .scaleAspectFill
        seconedImageView?.clipsToBounds = true

        seconedImageView?.image = data?.image
        self.navigationBar.addSubview(seconedImageView!)
        
        imageView?.image = data?.image
        self.navigationBar.addSubview(imageView!)
    }
    
    func removeSecondImage()
    {
        seconedImageView?.removeFromSuperview()
    }
        
    func setImage(_ image:UIImage?)
    {
        imageView?.image = image
    }
    
    func setPhotoTitle(_ text:String?)
    {
        photoCounter?.text = text
    }
}

struct AddToUINavigationControllerData {
    
    let image:UIImage?
    let photoCount:String?
    
}
