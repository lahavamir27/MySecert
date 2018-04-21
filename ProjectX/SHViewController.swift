//
//  SHViewController.swift
//  Pods
//
//
//

import UIKit
import RealmSwift
import RNCryptor

public protocol SHViewControllerDelegate:class {
    func shViewControllerImageDidFilter(image: UIImage)
    func shViewControllerDidCancel()
    func dismissController()
}

public class SHViewController: UIViewController, ViewUpdater {
    func view(center: CGPoint) {
        print(center)
    }
    
    public weak var delegate: SHViewControllerDelegate?
    
    @IBOutlet weak var doneBtn: UIButton!

    @IBAction func addTextView(_ sender: UIButton) {
        let textView = UserTextView(frame: CGRect(x: 8, y: 100, width: 375-16, height: 80))
        self.view.addSubview(textView)
        textView.delegate = self
        textView.initialLocation = self.view.center
        textView.center = self.view.center
        view.bringSubview(toFront: textView)
        textView.isScrollEnabled = false
        textView.viewDelegate = self
    }
    
    
    fileprivate let filterNameList = [
        "No Filter",
        "CIPhotoEffectMono",
        "CIPhotoEffectTonal",
        "CIPhotoEffectNoir",
        "CIPhotoEffectFade",
        "CIPhotoEffectChrome",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTransfer",
        "CIPhotoEffectInstant",
        "CILinearToSRGBToneCurve",
        "CISRGBToneCurveToLinear"

    ]

    fileprivate let filterDisplayNameList = [
        "Normal",
        "Mono",
        "Tonal",
        "Noir",
        "Fade",
        "Chrome",
        "Process",
        "Transfer",
        "Instant",
        "Tone",
        "Linear"
    ]

    fileprivate var filterIndex = 0
    fileprivate let context = CIContext(options: nil)
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var collectionView: UICollectionView?
    fileprivate var image: UIImage?
    fileprivate var smallImage: UIImage?
    fileprivate var imageCache = NSCache<AnyObject, UIImage>()
    fileprivate var choosenFilter = ""
    fileprivate var imageID:String?
    typealias CompletionHandler = (_ success:Bool) -> Void
    fileprivate var originalPhoto = UIImage()
    fileprivate var originalImage: UIImage?
    fileprivate var activityIndicator: ActivityIndicatorView? = nil
    fileprivate var viewModel:ModelViewEditController?
    override public var prefersStatusBarHidden: Bool {
        switch shouldHideStatusBar {
        case true:
            return true
        default:
            return false
        }
    }
    
    fileprivate var shouldHideStatusBar:Bool = false
    
    public init(image: UIImage, imageID: String) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.imageID = imageID
        imageCache.name = "cache"
        imageCache.countLimit = 100
        collectionView?.allowsMultipleSelection = false
        viewModel = ModelViewEditController(imageID: imageID)
        self.originalImage = viewModel?.originialImage
        self.image = viewModel?.originialImage
    }

    
    deinit {
        print("edit cntroller deinit")
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        if let view = UINib(nibName: "SHViewController", bundle: Bundle(for: self.classForCoder)).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
            if let image = self.image {
                imageView?.image = image
                viewModel?.originalOrientation = imageView?.image?.imageOrientation
                viewModel?.originalScale = imageView?.image?.scale
                self.smallImage = resizeImage(image: (viewModel?.originialImage)!)
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "SHCollectionViewCell", bundle: Bundle(for: self.classForCoder))
        collectionView?.register(nib, forCellWithReuseIdentifier: "cell")
        SaveImageToRealm.delegate = self
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let cell = collectionView?.cellForItem(at: [0,0]) as! SHCollectionViewCell
        cell.isSelected = true
        doneBtn.isEnabled = false
        doneBtn.setTitleColor(.gray, for: .normal)
        shouldHideStatusBar = true
        setNeedsStatusBarAppearanceUpdate()

    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait

    }
    
    func applyFilter() {
        let filterName = filterNameList[filterIndex]
        if let image = self.image {
            let filteredImage = createFilteredImage(filterName: filterName, image: image, shouldRotate: true)
            imageView?.image = filteredImage
        }
    }

    func createFilteredImage(filterName: String, image: UIImage, shouldRotate:Bool) -> UIImage {
        // 1 - create source image
        let sourceImage = CIImage(image: image)
        let openGLContext = EAGLContext(api: .openGLES3)
        let context = CIContext(eaglContext: openGLContext!)
        let filter = CIFilter(name: filterName)
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let cgimgresult = context.createCGImage(output, from: output.extent)
            if shouldRotate {
            return UIImage(cgImage: cgimgresult!, scale: (viewModel?.originalScale!)!, orientation: (viewModel?.originalOrientation)!)
            }else {
                return UIImage(cgImage: cgimgresult!)
            }
        }
        return UIImage()
    }

    func resizeImage(image: UIImage) -> UIImage {
        
        let thumbnailScaleFactor = UIImage.getIamgeScaleSize(image: image, size: 3.0)
        
        // resize images
        var thumbnailPhotoResized = UIImage.scaleImage(sourceImage: image, factor: thumbnailScaleFactor)
        thumbnailPhotoResized = UIImage(cgImage: thumbnailPhotoResized.cgImage!, scale: 1, orientation: (viewModel?.originalOrientation)!)
        return thumbnailPhotoResized
    }

    @IBAction func closeButtonTapped() {
        if let delegate = self.delegate {
            delegate.shViewControllerDidCancel()
        }
        dismiss(animated: true, completion: nil)
    }

    
    func turnOnActivityIndicatorView()
    {
        activityIndicator = ActivityIndicatorView(title: "Creating Copy", center: self.view.center)
        activityIndicator?.startAnimating()
        self.view.addSubview((activityIndicator?.getViewActivityIndicator())!)
    }
    
    
    func doneButtontapped() {
        viewModel?.fillteredImage = createFilteredImage(filterName: choosenFilter, image: originalImage!, shouldRotate: false)
        viewModel?.saveFillterImage()
        dismiss(animated: true, completion: nil)
    }
}

extension  SHViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SHCollectionViewCell
        var filteredImage = originalImage
        let filterName = filterNameList[indexPath.row]

        if indexPath.row != 0 {
            
        if let image = imageCache.object(forKey: filterName as AnyObject)  {
            cell.iamgeView.image = image
            print("\(filterName)")
        }else
        {
            filteredImage = createFilteredImage(filterName: filterName, image: smallImage!, shouldRotate: false)
            DispatchQueue.global(qos: .background).async {
                    self.imageCache.setObject(filteredImage! , forKey: filterName as AnyObject)
                }
           cell.iamgeView.image = filteredImage
        }
        }else
        {
            cell.iamgeView.image = filteredImage
        }
        cell.filterNameLabel.text = filterDisplayNameList[indexPath.row]
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNameList.count
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SHCollectionViewCell
        {
            cell.isSelected = false
        }
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filterIndex = indexPath.row
        let cell = collectionView.cellForItem(at: indexPath) as! SHCollectionViewCell
        cell.isSelected = true
        if let cellZero = collectionView.cellForItem(at: [0,0]) as? SHCollectionViewCell{cellZero.isSelected = false}
        if filterIndex != 0 {
            choosenFilter = filterNameList[indexPath.row]
            applyFilter()
            doneBtn.isEnabled = true
            doneBtn.setTitleColor(.secretYellow(), for: UIControlState.normal)
            
        } else {
            imageView?.image = image
            doneBtn.isEnabled = false
            doneBtn.setTitleColor(.gray, for: UIControlState.normal)
        }
        scrollCollectionViewToIndex(itemIndex: indexPath.item)
    }

    func scrollCollectionViewToIndex(itemIndex: Int) {
        let indexPath = IndexPath(item: itemIndex, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    
}


extension SHViewController: SaveImageProtocol
{
    func startSaveEditImages() {
        print("start")
        turnOnActivityIndicatorView()
        activityIndicator?.startAnimating()
    }
    
    func finishSaveEditImages() {
        activityIndicator = nil
        delegate?.dismissController()
        self.dismiss(animated: true, completion: nil)
    }
 
}

extension SHViewController: UITextViewDelegate
{
    public func textViewDidChange(_ textView: UITextView) {
        let newSize = textView.sizeThatFits(CGSize(width: self.view.frame.width - 16, height: CGFloat.greatestFiniteMagnitude))
        textView.frame = CGRect(origin: textView.frame.origin, size: newSize)
        textView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
    
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        textView.endEditing(true)
    }
}



