//
//  Utils.swift
//  PasswordManager
//
//  Created by Maor Shams on 08/07/2017.
//  Copyright © 2017 Maor Shams. All rights reserved.
//

import Cocoa

class Utils{
    
    /// Show alert 
    /// - Parameters:
    ///     - message: The Message to show
    ///     - infoText: The bottom text of alert
    ///     - cancelButton: To show cancel button, true by default
    ///     - completion: *Bool* if the user did press ok
    class func showAlert(message : String, infoText : String,
                         cancelButton : Bool = true ,completion : ((Bool)->Void)? =  nil) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = infoText
        alert.alertStyle = NSAlertStyle.warning
        alert.addButton(withTitle: "OK")
        if cancelButton{
            alert.addButton(withTitle: "Cancel")
        }
        completion?(alert.runModal() == NSAlertFirstButtonReturn)
    }
}
