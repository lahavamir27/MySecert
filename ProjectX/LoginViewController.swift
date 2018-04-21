//
//  LoginViewController.swift
//  ProjectX
//
//  Created by amir lahav on 16.1.2018.
//  Copyright © 2018 LA Computers. All rights reserved.
//

import UIKit
import Cartography
import LocalAuthentication


protocol LoginProtocol {
    func didDismiss()
}

class LoginViewController: UIViewController {

    fileprivate var blurView:UIVisualEffectView!
    fileprivate var touchID:UIImageView!
    fileprivate var textTitle:UILabel!
    fileprivate var bodyText:UILabel!
    fileprivate var useTouchIDbtn:UIButton!
    
    var delegate:LoginProtocol?
    
    fileprivate var loginState:LoginState = .pressnt {
        didSet{
            switch loginState {
            case .pressnt:
                self.view.isHidden = false
            case .hide:
                self.view.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initViews()
        authenticateUser()
    }
    
    
    func initViews()
    {
        setupBlurView()
        setupTouchIDImage()
        setupTitle()
        setupBodyText()
        setupTouchIDButton()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupBlurView()
    {
            let blurEffect = UIBlurEffect(style: .extraLight)
            blurView = UIVisualEffectView()
            blurView.effect = blurEffect
            blurView.isUserInteractionEnabled = false
            blurView.frame = CGRect(x: 0.0, y: 0, width: 1, height: 1)
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(blurView)
            view.backgroundColor = .clear
        constrain(self.view, blurView){ view, blur in
            blur.edges == view.edges
        }
    }
    
    func setupTouchIDImage()
    {
        touchID = UIImageView(image: #imageLiteral(resourceName: "1483719318_Touch_ID"))
        touchID.frame = CGRect(x: 0, y: 0, width: 1, height: 1  )
        self.view.addSubview(touchID)
        
        constrain(touchID, self.view) {touch, view in
            touch.height == 136.0
            touch.width == 136.0
            touch.top == view.top + 110
            touch.centerX == view.centerX
        }
    }
    
    func setupTitle()
    {
        textTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        textTitle.text = "Unlock MySecret with Touch ID"
        textTitle.font = UIFont.preferredFont(forTextStyle: .title3)
        textTitle.textAlignment = .center
        
        self.view.addSubview(textTitle)
        
        constrain(textTitle, touchID, self.view){title, touch, view in
            title.centerX == touch.centerX
            title.width == view.width
            title.height == 36
            title.top == touch.bottom + 36
        }
    }
    
    func setupBodyText()
    {
        bodyText = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        bodyText.text = "Use your fingerprint to unlock MySecret instead of typing you Master Password or PIN code"
        bodyText.font = UIFont.preferredFont(forTextStyle: .body)
        bodyText.textAlignment = .center
        bodyText.numberOfLines = 0
        
        self.view.addSubview(bodyText)
        
        constrain(bodyText, textTitle, self.view){body, title, view in
            body.centerX == title.centerX
            body.width == view.width - 32
            body.height == 65.0
            body.top == title.bottom + 8
        }
    }
    
    func setupTouchIDButton()
    {
        useTouchIDbtn = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        useTouchIDbtn.addTarget(self, action: #selector(self.authenticateUser), for: .touchUpInside)
        useTouchIDbtn.setTitle("Use Touch ID", for: .normal)
        useTouchIDbtn.layer.cornerRadius = 4.0
        useTouchIDbtn.layer.masksToBounds = false
        useTouchIDbtn.backgroundColor = UIColor(red: 1, green: 45/255, blue: 84/255, alpha: 1.0)
        self.view.addSubview(useTouchIDbtn)
        
        constrain(self.view, useTouchIDbtn){view, button in
            button.bottom == view.bottom - 20
            button.width == view.width - 36
            button.height == 40
            button.centerX == view.centerX
        }
    }
    
    func dismissView()
    {
        self.dismiss(animated: false, completion: nil)
    }
    
    deinit {
        print("deinit blur")
    }
    
    
    public func authenticateUser() {
        
        // 1. Create a authentication context
        let authenticationContext = LAContext()
        var error:NSError?
        
        // 2. Check if the device has a fingerprint sensor
        // If not, show the user an alert view and bail out!
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            
            if let massage =  error?.userInfo["NSLocalizedDescription"]{
                showAlertViewIfNoBiometricSensorHasBeenDetected(massage: massage as! String)
            }
            return
        }
        
        // 3. Check the fingerprint
        authenticationContext.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Please use Touch ID to sign in MySecret",
            reply: { [unowned self] (success, error) -> Void in
                
                if( success ) {
                    // Fingerprint recognized
                    print("success")
                    
                    self.dismissControllerSucceeded()
                    
                }else {
                    
                    // Check if there is an error
                    if let error = error {
                        
                        let err = error as! LAError
                        print(self.errorMessageForLAErrorCode(errorCode: err))
                        
                    }
                    
                }
                
        })
        
        
    }
    
    func dismissControllerSucceeded()
    {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.0, animations: {  [unowned self] _ in
                self.touchID.alpha = 0.0
                self.textTitle.alpha = 0.0
                self.bodyText.alpha = 0.0
                self.useTouchIDbtn.alpha = 0.0
                
            })
            UIView.animate(withDuration: 0.6, animations: { [unowned self] _ in
                self.blurView.effect = nil
                }, completion: { [unowned self] _ in
                    self.delegate?.didDismiss()
                    self.dismiss(animated: false, completion: {
                        //            self.loginDelegate?.finishAuth()
                    })
                    
                    
            })
        }
        

    }
    
    func dismissControllerFailure()
    {
        self.dismiss(animated: false, completion: {
//            self.loginDelegate?.finishWithoutAuth()
        })
    }
    
    
    func isSuccses() -> Bool {
        return true
    }
    
    func showAlertViewIfNoBiometricSensorHasBeenDetected(massage: String){
        
        showAlertWithTitle(title: "Oh No", message: massage + " For maximum protection You have to had Fingerprint enrolled before start using MySecret")
        
    }
    
    func showAlertViewAfterEvaluatingPolicyWithMessage( message:String ){
        
        showAlertWithTitle(title: "Oh No", message: message)
        
    }
    
    func showAlertWithTitle( title:String, message:String ) {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(ok) in
            
        })
        alertVC.addAction(okAction)
        DispatchQueue.main.async{
            self.present(alertVC, animated: true, completion: nil)
        }
        
    }
    
    func errorMessageForLAErrorCode( errorCode:LAError ) -> String{
        
        var message = ""
        
        switch errorCode {
            
        case LAError.appCancel:
            message = "Authentication was cancelled by application"
            
        case LAError.authenticationFailed:
            message = "The user failed to provide valid credentials"
            
        case LAError.invalidContext:
            message = "The context is invalid"
            
        case LAError.passcodeNotSet:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel:
            message = "Authentication was cancelled by the system"
            
        case LAError.biometryLockout:
            message = "Too many failed attempts."
            
        case LAError.biometryNotAvailable:
            message = "TouchID is not available on the device"
            
        case LAError.userCancel:
            message = "The user did cancel"
            
        case LAError.userFallback:
            message = "The user chose to use the fallback"
            showAlertWithTitle(title: "Oh No", message: "You must have Touch ID to sign in")
            
        default:
            message = "Did not find error code on LAError object"
            
        }
        
        return message
        
    }


}
enum LoginState {
    case pressnt
    case hide
}
