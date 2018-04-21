//
//  SavingProgerAlertConroller.swift
//  MySecret
//
//  Created by amir lahav on 31.8.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit

class SavingProgerAlertConroller: UIAlertController {

    
    
    fileprivate let progressSave : UIProgressView = UIProgressView(progressViewStyle: .default)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addProgressBar()
        // Do any additional setup after loading the view.
    }
    
    func addProgressBar()
    {
        progressSave.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
        self.view.addSubview(progressSave)
    }
    deinit {
        print("deinit progress bar")
    }
    
    func encryptStage()
    {
        title = "Please Wait"
        let message  = "Encrypting photos..."
        setMessegeBody(message: message)
        setProgress(progress: 0.3)
    }
    
    func gettingLocationStage()
    {
        title = "Please Wait"
        let message  = "Getting locations..."
        setMessegeBody(message: message)
    }
    
    func faceDetectingStage()
    {
        title = "Please Wait"
        let message  = "Face Detecting..."
        setMessegeBody(message: message)
        setProgress(progress: 0.6)
    }
    
    func setProgress(progress:Float)
    {
        progressSave.progress = progress
    }
    
    func setMessegeBody(message:String)
    {
        self.message = message
    }

}
