//
//  ImageSaveHelper.swift
//  PhotoViewer
//
//  Created by amir lahav on 14.2.2017.
//  Copyright © 2017 Nathan Blamires. All rights reserved.
//

import Foundation
import UIKit
import RNCryptor
import KeychainSwift




struct LoadImageHelper
{
    
    let keychain = KeychainSwift()
   
    
    func getVideoPath(id:String) -> String?
    {
        let documentsURL = getDocumentsDirectory()
        let path = "\(id)_video.MOV"
        let filePath = documentsURL.appendingPathComponent("\(path)").path
        guard FileManager.default.fileExists(atPath: filePath) == true else { return nil }
        return filePath
    }
    
    func getVideoURL(id:String) -> URL?
    {
        let documentsURL = getDocumentsDirectory()
        let path = "\(id)_video.MOV"
        let filePath = documentsURL.appendingPathComponent("\(path)").path
        guard FileManager.default.fileExists(atPath: filePath) == true else { return nil }
        return documentsURL.appendingPathComponent("\(path)")
    }
    
    func clearTempFolder() {
        let fileManager = FileManager.default
        let tempFolderPath = NSTemporaryDirectory()
        
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: tempFolderPath + filePath)
            }
        } catch let error as NSError {
            print("Could not clear temp folder: \(error.debugDescription)")
        }
    }
    
    func getImageDataToAnalize(id:String, and imageSize:ImageSizeExtention) -> Data?
    {
        let documentsURL = getDocumentsDirectory()
        let extention:String = imageSize.rawValue
        let path = id + extention
        let filePath = documentsURL.appendingPathComponent("\(path)").path
        let fileURL = documentsURL.appendingPathComponent("\(path)")
        
        guard let password = keychain.get("password") else {return nil}
        
        
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                let photoData = try Data(contentsOf: fileURL)
                let originalData = try RNCryptor.decrypt(data: photoData, withPassword: password)
                return originalData
            } catch let error as NSError {
                print("cant load image from device")
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func getImageWith(ID:String,and imageSize:ImageSizeExtention) -> UIImage?
    {
        let documentsURL = getDocumentsDirectory()
        let extention:String = imageSize.rawValue
        let path = ID + extention
        let filePath = documentsURL.appendingPathComponent("\(path)").path
        let fileURL = documentsURL.appendingPathComponent("\(path)")
        
        guard let password = keychain.get("password") else {return nil}

        
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                let photoData = try Data(contentsOf: fileURL)
                let originalData = try RNCryptor.decrypt(data: photoData, withPassword: password)
                return UIImage(data: originalData)!
            } catch let error as NSError {
                print("cant load image from device")
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func loadMapBackgroundImage() -> UIImage?
    {
        let documentsURL = getDocumentsDirectory()
        let filePath = documentsURL.appendingPathComponent("backgrounMap.png").path
        let fileURL = documentsURL.appendingPathComponent("backgrounMap.png")
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                let photoData = try Data(contentsOf: fileURL)
                return UIImage(data: photoData)!
            } catch let error as NSError {
                print("cant load image from device")
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func deleteImageFromDevice(ID:String, size:ImageSizeExtention )
    {
        
        let extention:String = size.rawValue
        let path = ID + extention
        let filename = getDocumentsDirectory().appendingPathComponent("\(path)")
        
        do{
            try FileManager.default.removeItem(at: filename)

        }catch let error as NSError {
            print(error.localizedDescription)
            print("cant delete photo")
        }
    }

    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

}


extension LoadImageHelper{
    

    

    
}

enum FileExension:String {
    case JPG = ".jpg"
    case PNG = ".png"
    case MOV = "_video.MOV"
}

enum ImageSizeExtention: String {
    case thumbnail = "_thumbnail.png"
    case animationTransition = "_animation.png"
    case fullSize = "_main.png"
}
