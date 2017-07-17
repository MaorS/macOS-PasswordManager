//
//  AddNewPasswordVC.swift
//  PasswordManager
//
//  Created by Maor Shams on 08/07/2017.
//  Copyright © 2017 Maor Shams. All rights reserved.
//

import Cocoa


class PasswordEditorVC: NSViewController {
    
    @IBOutlet weak var appTextField: NSTextField!
    @IBOutlet weak var userNameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSTextField!
    @IBOutlet weak var titleLabel: NSTextField!
    
    var editableApp : App?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if let editableApp = editableApp{
            configVC(with: editableApp)
        }
    }
    
    /// Close VC
    @IBAction func closeAction(_ sender: NSButton) {
        // show warning to user
        Utils.showAlert(message: "Warning!", infoText: "Nothing will be saved!") { (answer) in
            if answer == true{ // if "ok" was pressed
                self.dismissViewController(self)
            }
        }
    }
    
    /// Save & close VC
    @IBAction func saveAction(_ sender: NSButton) {
        
        let appName = appTextField.stringValue
        let userName = userNameTextField.stringValue
        let password = passwordTextField.stringValue
        
        guard !appName.isEmpty, !userName.isEmpty , !password.isEmpty else{
            return
        }
        
        // check if it's new app / exist
        if editableApp == nil {
            DBManager.manager.addNewApp(appName: appName, userName: userName, password: password)
        }else if let app = self.editableApp{
            DBManager.manager.updateExistApp(app: app,appName: appName, userName: userName, password: password)
        }
        
        self.dismissViewController(self)
    }
    
    /// Config the VC
    func configVC(with app : App){
        titleLabel.stringValue = "Edit Password"
        if app.isEncrypted{
            appTextField.stringValue = DBManager.manager.aesDecrypt(text: app.appName)
            userNameTextField.stringValue = DBManager.manager.aesDecrypt(text: app.userName)
            passwordTextField.stringValue = DBManager.manager.aesDecrypt(text: app.password)
        }else{
            appTextField.stringValue = app.appName
            userNameTextField.stringValue = app.userName
            passwordTextField.stringValue = app.password
        }
    }
}
