//
//  PasswordCell.swift
//  PasswordManager
//
//  Created by Maor Shams on 07/07/2017.
//  Copyright © 2017 Maor Shams. All rights reserved.
//

import Cocoa

class PasswordCell: NSTableCellView {
    
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var visiblePasswordTextField: NSTextField!
    @IBOutlet weak var showPassButton: NSButton!
    
    var delegate : PasswordCellDelegate?
    var row: Int?
    
    @IBAction func showPasswordAction(_ sender: NSButton) {
        isPasswordVisible = sender.state == 1 ? true : false
    }
    
    func copyPasswordAction() {
        let text = visiblePasswordTextField.stringValue
        let pasteboard = NSPasteboard.general()
        pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
        pasteboard.setString(text, forType: NSPasteboardTypeString)
    }
    
    func configCell(app : App, row : Int, listener vc: MainVC){
        
        if DBManager.manager.isEncryptionEnabled && app.isEncrypted{
            self.passwordTextField.stringValue = DBManager.manager.aesDecrypt(text: app.password)
        }else{
            self.passwordTextField.stringValue = app.password
        }
        self.row = row
        self.delegate = vc
        self.isPasswordVisible = app.isPasswordVisible
    }
    
    
    var isPasswordVisible : Bool = false{
        didSet{
            if isPasswordVisible{
                visiblePasswordTextField.stringValue = passwordTextField.stringValue
                visiblePasswordTextField.isHidden = false
                passwordTextField.isHidden = true
                showPassButton.state = NSOnState
            }else{
                visiblePasswordTextField.stringValue = ""
                visiblePasswordTextField.isHidden = true
                passwordTextField.isHidden = false
                showPassButton.state = NSOffState
            }
            
            if let row = row{
                self.delegate?.cellDidPressToShowPassword(row: row, show: isPasswordVisible)
            }
        }
    }
}

protocol PasswordCellDelegate {
    func cellDidPressToShowPassword(row: Int,show : Bool)
}
