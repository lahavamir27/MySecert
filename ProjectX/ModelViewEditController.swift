//
//  ModelViewEditController.swift
//  ProjectX
//
//  Created by amir lahav on 18.11.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

struct ModelViewEditController {
    
    var imageID:String
    var saveHelper = SaveAssets()
    let loadImageHelper = LoadImageHelper()
    let imageProcessorHelper = ImageProcessHelper()
    
    var originialImage:UIImage{
        guard let image = loadImageHelper.getImageWith(ID: imageID, and: .fullSize) else {
            print("cant get original image")
            return UIImage()
        }
        return image
    }
    
    var fillteredImage:UIImage?
    var originalOrientation:UIImageOrientation?
    var originalScale:CGFloat?
    
    var photo:Asset?
    {
        guard let realm = try? Realm() else {
            print("cant get realm")
            return nil
        }
        return realm.objects(Asset.self).filter("assetID == '\(imageID)'").first
    }
    
    
    init(imageID:String) {
        self.imageID = imageID
    }
    
    func saveFillterImage()
    {
        guard let image = fillteredImage, let photo = photo else {
            print("cant save image")
            return }
        saveHelper.saveFilltered(image: image, photo: photo)
    }
    
    
    func getFilteredImages() -> [FilterImageCellData]?
    {
        var filterdImages = [FilterImageCellData]()
        for filter in FilterName.enumerate(){
            guard let image = loadImageHelper.getImageWith(ID: imageID, and: .thumbnail) else {return nil}
            let filterName = FilterName.getCoreImageFilterBy(name: filter)
            var filteredImage = imageProcessorHelper.createFilteredImage(filterName: filterName, image: image, scale: 1.0 , orientation: image.imageOrientation)
            filteredImage = filter != .Normal ? filteredImage : image
            let cellData = FilterImageCellData(filterName: filter.description, filterImage: filteredImage, filterImageType: filter, fxFilterType: .Normal)
            filterdImages.append(cellData)
        }
        return filterdImages
    }
    
    func getFXFilteredImages() -> [FilterImageCellData]?
    {
        var filterdImages = [FilterImageCellData]()
        for filter in FXFilter.enumerate(){
            guard let image = loadImageHelper.getImageWith(ID: imageID, and: .thumbnail) else {return nil}
            let filterName = FXFilter.getCoreImageFilterBy(name: filter)
            var filteredImage = imageProcessorHelper.createFilteredImage(filterName: filterName, image: image, scale: 1.0 , orientation: image.imageOrientation)
            filteredImage = filter != .Normal ? filteredImage : image
            let cellData = FilterImageCellData(filterName: filter.description, filterImage: filteredImage, filterImageType: .Normal, fxFilterType: filter)
            filterdImages.append(cellData)
        }
        return filterdImages
    }
    
    func getFilteredImage(forFiltered:FilterName) -> UIImage?{
        
        guard let image = loadImageHelper.getImageWith(ID: imageID, and: .fullSize) else { return nil }
        switch forFiltered {
        case .Normal:   return image
        default:        return imageProcessorHelper.createFilteredImage(filterName: FilterName.getCoreImageFilterBy(name: forFiltered), image: image, scale: 0.0 , orientation: image.imageOrientation)
        }
    }
    
    func getFXFilteredImage(forFiltered:FXFilter) -> UIImage?{
        
        guard let image = loadImageHelper.getImageWith(ID: imageID, and: .fullSize) else { return nil }
        switch forFiltered {
        case .Normal:   return image
        default:
            
            let parameters = FXFilter.getCoreImageFilterParametersBy(name: forFiltered)
            return imageProcessorHelper.createFXFilteredImage(filterName: parameters.0, image: image, scale: 0.0 , orientation: image.imageOrientation, parametres: parameters.1)
        }
    }
}


enum FilterName:Int, EnumerableEnum, CustomStringConvertible {
    
    case Normal
    case Mono
    case Tonal
    case Noir
    case Fade
    case Chrome
    case Process
    case Transfer
    case Instant
    case Tone
    case Linear
    
    var description: String {
        switch self {

        case .Normal:       return "Original"
        case .Mono:         return "Mono"
        case .Tonal:        return "Tonal"
        case .Noir:         return "Noir"
        case .Fade:         return "Fade"
        case .Chrome:       return "Chrome"
        case .Process:      return "Process"
        case .Transfer:     return "Transfer"
        case .Instant:      return "Instant"
        case .Tone:         return "Tone"
        case .Linear:       return "Linear"

        }
    }
    
    
    static func getCoreImageFilterBy(name:FilterName) -> String
    {
        switch name {
        case .Normal:       return "No Filter"
        case .Mono:         return "CIPhotoEffectMono"
        case .Tonal:        return "CIPhotoEffectTonal"
        case .Noir:         return "CIPhotoEffectNoir"
        case .Fade:         return "CIPhotoEffectFade"
        case .Chrome:       return "CIPhotoEffectChrome"
        case .Process:      return "CIPhotoEffectProcess"
        case .Transfer:     return "CIPhotoEffectTransfer"
        case .Instant:      return "CIPhotoEffectInstant"
        case .Tone:         return "CILinearToSRGBToneCurve"
        case .Linear:       return "CISRGBToneCurveToLinear"
        }
    }
    
}

enum FXFilter:Int, EnumerableEnum, CustomStringConvertible {
    
    case Normal
    case Crystal
    case Edge
    case Comics
    case Points
    case Colors
    case HalfTone
    case Motion
    case test
    
    var description: String {
        switch self {
            
        case .Normal:       return "Original"
        case .Crystal:      return "Crystal"
        case .Edge:         return "Edge"
        case .Comics:       return "Comics"
        case .Points:       return "Points"
        case .Colors:       return "Colors"
        case .HalfTone:     return "Half Tone"
        case .test:         return "test"
        case .Motion: return "Motion"
            
        }
    }
    
    static func getCoreImageFilterBy(name:FXFilter) -> String
    {
        switch name {
        case .Normal:           return "No Filter"
        case .Crystal:          return "CICrystallize"
        case .Edge:             return "CIEdgeWork"
        case .Comics:           return "CIComicEffect"
        case .Points:           return "CIPointillize"
        case .Colors:           return "CISpotColor"
        case .HalfTone:         return "CICMYKHalftone"
        case .test:             return "CIEdges"
        case .Motion:           return "CIMotionBlur"
            
        }
    }
    
    static func getCoreImageFilterParametersBy(name:FXFilter) -> (String,[String:Any]?)
    {
        switch name {
        case .Normal:           return ("No Filter",nil)
        case .Crystal:          return ("CICrystallize",[kCIInputRadiusKey: 55])
        case .Edge:             return ("CIEdgeWork", [kCIInputRadiusKey: 6])
        case .Comics:           return ("CIComicEffect",nil)
        case .Points:           return ("CIPointillize",[kCIInputRadiusKey: 20])
        case .Colors:           return ("CISpotColor",nil)
        case .HalfTone:         return ("CICMYKHalftone",nil)
        case .Motion:           return ("CIGaussianBlur",[kCIInputRadiusKey: 10])
        case .test:             return ("CIEdges",[kCIInputIntensityKey: 30])
        }
    }

}

struct FilterImageCellData {
    var filterName:String
    var filterImage:UIImage
    var filterImageType:FilterName
    var fxFilterType:FXFilter
}

protocol EnumerableEnum {
    init?(rawValue: Int)
    static func firstRawValue() -> Int
}

extension EnumerableEnum {
    static func enumerate() -> AnyIterator<Self> {
        var nextIndex = firstRawValue()
        
        let iterator: AnyIterator<Self> = AnyIterator {
            defer { nextIndex = nextIndex + 1 }
            return Self(rawValue: nextIndex)
        }
        
        return iterator
    }
    
    static func firstRawValue() -> Int {
        return 0
    }
}
