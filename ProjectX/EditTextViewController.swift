//
//  EditTextViewController.swift
//  ProjectX
//
//  Created by amir lahav on 20.1.2018.
//  Copyright © 2018 LA Computers. All rights reserved.
//

import UIKit
import Cartography
class EditTextViewController: UIViewController, UITextViewDelegate {
    

    
    func buttonPress(sender: UIBarButtonItem){
        let text = textView.text!
        saveText(text)
        self.dismiss(animated: false, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" { textView.text = "#"}
    }
    open var saveText:(String) -> () = { _ in }

    
    fileprivate var textView:UITextView!
    fileprivate var inputText:String!
    fileprivate var blurView:UIVisualEffectView!
    fileprivate var navigationBarItem:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        layoutViews()
        navigationBarItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(buttonPress))
        self.navigationItem.rightBarButtonItem = navigationBarItem
        // Do any additional setup after loading the view.
    }

    
    
    func initNavigationBar()
    {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func layoutViews()
    {
        
        let blurEffect = UIBlurEffect(style: .dark)
        blurView = UIVisualEffectView()
        blurView.effect = blurEffect
        blurView.isUserInteractionEnabled = false
        self.view.addSubview(blurView)
        constrain(blurView, self.view) { blur, view in
            blur.edges == view.edges
        }
        
        textView = UITextView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        self.view.addSubview(textView)
        textView.textColor = .white
        textView.textAlignment = .center
        textView.backgroundColor = .clear
        textView.delegate = self
        textView.font = UIFont.boldSystemFont(ofSize: 44)
        constrain(textView,self.view) {text, view in
            text.width == view.width
            text.height == view.height / 2
            text.left == view.left
            text.top == view.top + 50
            text.right == view.right
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.text = inputText
        textView.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public init(text:String?)
    {
        super.init(nibName: nil, bundle: nil)
        if let userText = text{
            inputText = userText
        }else {
            inputText = ""
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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




extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
}
