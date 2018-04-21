//
//  FaceDetector.swift
//  PhotoViewer
//
//  Created by amir lahav on 21.11.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import Foundation
import UIKit
import Vision

struct FaceDetector {
    
    
     func hasFace(image: UIImage) -> Bool{
        
        guard let faceImage = CIImage(image: image) else {
            return false
        }
        
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        guard let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy) else {return false}
        let faces = faceDetector.features(in: faceImage)
        
        for _ in faces as! [CIFaceFeature] {
            
            return true
            
        }
        
        return false
    }
    
    func hasFace(data: Data?) -> Bool{
        
        guard let data = data else { return false}
        guard let image = UIImage(data: data) else { return false}
        let hasFace = self.hasFace(image: image)
        return hasFace
        
    }
    
}

struct FaceDetectorVision {
    
    static func hasFace(image:UIImage, complition:@escaping (Bool)->())
    {
        let request = VNDetectFaceRectanglesRequest { (req, err) in
            if let error = err{
                
                print("cant get face for u: ", error)
                complition(false)
            }else{
                req.results?.forEach({ (res) in
                    guard res is VNFaceObservation else {complition(false)
                        return}
                    complition(true)
                })
            }
        }
        guard let cgImage = image.cgImage else {
            return
        }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do{
            try handler.perform([request])
        }catch let error
        {
            print("faild to perform request:", error)
            complition(false)
        }
        
    }
        
    static func getObject(using model: MLModel, data:Data,threshold: Float, complition:@escaping ([String])->())
    {

//        guard let cgImage = image.cgImage else {return}
        guard let resnet50 = try? VNCoreMLModel(for: model) else {return}
        
        let resnet50Request = VNCoreMLRequest(model: resnet50) { (req, err) in
            
            if let error = err {}else{
                guard let result = req.results as? [VNClassificationObservation] else {return}
                
                var tags = [[String]]()
                for i in 0...4{
                    let object = result[i]
                    if object.confidence > threshold{
                        let splitTags =  object.identifier.components(separatedBy:", ")
                        tags.append(splitTags)
                    }
                }

                let finalSet = Set(tags.flatMap({$0}))
                var returnTags = finalSet.map({ (string) -> String in
                    let firstTrim = string.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)
                    let seconedTrim = firstTrim.replacingOccurrences(of: "/", with:" ")
                    let str = seconedTrim.replacingOccurrences(of: "-", with:" ")
                    print(str)
                    return  str

                })

                complition(returnTags)
            }
        }
        let handler = VNImageRequestHandler(data: data, options: [:])
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do{
            try handler.perform([resnet50Request])
        }catch let error
        {
            print("faild to perform request:", error)
        }
    }
    
    static func getObjects(from image:UIImage, complition:@escaping (Bool)->())
    {
        guard let cgImage = image.cgImage else {return}
        guard let resnet50 = try? VNCoreMLModel(for: Nudity().model) else {return}
        
        let resnet50Request = VNCoreMLRequest(model: resnet50) { (req, err) in
            
            if let error = err {}else{
                guard let result = req.results as? [VNClassificationObservation] else {return}
                guard let safe = result.first?.identifier else { return }
                if safe == "NSFW" {complition(true)}else { complition(false)}
                
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do{
            try handler.perform([resnet50Request])
        }catch let error
        {
            print("faild to perform request:", error)
        }

    }
    
    

    
}
