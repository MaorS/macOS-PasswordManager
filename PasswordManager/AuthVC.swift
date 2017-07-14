//
//  AuthVC.swift
//  Test
//
//  Created by Maor Shams on 07/07/2017.
//  Copyright © 2017 Maor Shams. All rights reserved.
//

import Cocoa
import LocalAuthentication

class AuthVC: NSViewController {
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var tryAgainButton: NSButton!
    
    let context = LAContext()
    let reasonString = "Password Manager login"
    var authError: NSError? = nil
    
    override func viewDidAppear() {
        super.viewDidAppear()
        goToNextVC()
        //getAuth()
    }
    
    @IBAction func tryAgainAction(_ sender: NSButton) {
        getAuth()
    }
    
    func getAuth(){
        animatedIndicator = true
        if #available(OSX 10.12.2, *) {
            canAuthWithBio ? getAuthWithBio() : getAuthWithPassword()
        } else {
            // Fallback on earlier versions
            getAuthWithPassword()
        }
    }
    
    @available(OSX 10.12.2, *)
    func getAuthWithBio(){
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { (success, error) in
            self.animatedIndicator = false
            if (success) { // User authenticated successfully
                self.goToNextVC()
                return
            } else if let error = error {
                self.handleError(error)
            }
        }
    }

    func getAuthWithPassword(){
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reasonString) { (success, error) in
            self.animatedIndicator = false
            if (success) { // User authenticated successfully
                self.goToNextVC()
                return
            } else if let error = error {
                self.handleError(error)
            }
        }
    }
    
    @available(OSX 10.12.2, *)
    var canAuthWithBio : Bool{
        return context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError)
    }
    
    // User did not authenticate successfully, look at error and take appropriate action
    func handleError(_ error : Error){
        switch error{
        case LAError.appCancel : showTryAgainButton()
        case LAError.userCancel : showTryAgainButton()
        case LAError.authenticationFailed : self.showWrongPassAlert()
        case LAError.userFallback : self.getAuthWithPassword()
        default :  break
        }
    }
    
    var animatedIndicator : Bool = false{
        didSet{
            DispatchQueue.main.async {
                self.animatedIndicator ? self.progressIndicator.startAnimation(nil): self.progressIndicator.stopAnimation(nil)
            }
        }
    }
    
    func showTryAgainButton(){
        tryAgainButton.isTransparent = false
    }
    
    func showWrongPassAlert(){
        Utils.showAlert(message: "Error!", infoText: "Wrong identification", cancelButton: false)
    }
    
    func goToNextVC(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.performSegue(withIdentifier: "mainMenuSegue", sender: nil)
        }
    }
    
}
