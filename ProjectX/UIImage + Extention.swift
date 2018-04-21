//
//  UIImage + Extention.swift
//  PhotoViewer
//
//  Created by amir lahav on 14.11.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import Foundation
import UIKit
import RNCryptor

extension UIImage
{
    
    convenience init?(encryptData: Data?) {
        let password = "password"

        do{
            let photoData =  try RNCryptor.decrypt(data: encryptData!, withPassword: password)
            self.init(data: photoData )!
        }catch{
            self.init(data: encryptData! )!
            print("cant get photo")
        }
    }
    
    static func getIamgeScaleSize(image:UIImage, size: CGFloat) -> CGFloat
    {
        let width = image.size.width
        let height = image.size.height
        
        let cell = UIScreen.main.bounds.width/size
        let maxSize = min(width, height)
        //        print("cell size \(cell), max size \(maxSize)")
        
        return cell/maxSize
    }
    
    static func scaleImage(sourceImage:UIImage, factor: CGFloat) -> UIImage {
        
        let newHeight = sourceImage.size.height * factor
        let newWidth = sourceImage.size.width * factor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}
