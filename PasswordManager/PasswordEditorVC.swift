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
    
    @IBAction func closeWindowAction(_ sender: NSButton) {
        Utils.showAlert(message: "Warning!", infoText: "Nothing will be saved!") { (answer) in
            if answer == true{
                self.dismissViewController(self)
            }
        }
    }
    
    @IBAction func saveAction(_ sender: NSButton) {
        
        let appName = appTextField.stringValue
        let userName = userNameTextField.stringValue
        let password = passwordTextField.stringValue
        
        guard !appName.isEmpty, !userName.isEmpty , !password.isEmpty else{
            return
        }
        if editableApp == nil {
            DBManager.manager.addNewApp(appName: appName, userName: userName, password: password)
        }else if let app = self.editableApp{
            DBManager.manager.updateExistApp(app: app,appName: appName, userName: userName, password: password)
        }
        
        self.dismissViewController(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if let editableApp = editableApp{
            configVC(with: editableApp)
        }
    }
    
    func configVC(with app : App){
        guard let appName = app.appName,
            let userName = app.userName,
            let password = app.password else {
                return
        }
        
        titleLabel.stringValue = "Edit Password"
        
        appTextField.stringValue = appName
        userNameTextField.stringValue = userName
        passwordTextField.stringValue = password
    }
}
