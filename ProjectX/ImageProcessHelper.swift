//
//  ImageProcessHelper.swift
//  ProjectX
//
//  Created by amir lahav on 7.1.2018.
//  Copyright © 2018 LA Computers. All rights reserved.
//

import Foundation
import QuartzCore
import CoreImage
import UIKit

struct ImageProcessHelper {
    
    
    
    let openGLContext = EAGLContext(api: .openGLES3)
    var context = CIContext()
    
    init() {
        context = CIContext(eaglContext: openGLContext!)
    }
    
    func createFilteredImage(filterName: String, image: UIImage, scale:CGFloat ,orientation:UIImageOrientation ) -> UIImage {
        // 1 - create source image
        let sourceImage = CIImage(image: image)
        let filter = CIFilter(name: filterName)
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            guard let cgimgresult = context.createCGImage(output, from: output.extent) else {return UIImage()}
            return UIImage(cgImage: cgimgresult, scale: scale, orientation: orientation)
        }
        return UIImage()
    }
    
    func createFXFilteredImage(filterName: String, image: UIImage, scale:CGFloat ,orientation:UIImageOrientation, parametres:[String:Any]? ) -> UIImage {
        // 1 - create source image
        
        let sourceImage = CIImage(image: image)
        
        guard let finalImage = sourceImage?.applyingFilter(filterName, withInputParameters: parametres) else { return UIImage()}
        let cgOutput = context.createCGImage(finalImage, from: (sourceImage?.extent)!)
        let image = UIImage(cgImage: cgOutput!, scale: 0.0, orientation: image.imageOrientation)
        return image
    }
    
    
}
