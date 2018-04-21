//
//  ViewController.swift
//  text_on_image
//
//  Created by amir lahav on 27.1.2018.
//  Copyright © 2018 LA Computers. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let textOnImageVC = HRTextOnImageVC()
        textOnImageVC.image = UIImage(named: "flower")
        present(textOnImageVC, animated: false, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

