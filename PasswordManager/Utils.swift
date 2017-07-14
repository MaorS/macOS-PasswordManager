//
//  Utils.swift
//  PasswordManager
//
//  Created by Maor Shams on 08/07/2017.
//  Copyright © 2017 Maor Shams. All rights reserved.
//

import Cocoa
class Utils{
    
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
/*
 extension NSTableView {
 override open func mouseDown(with event: NSEvent) {
 super.mouseDown(with: event)
 
 let point    = convert(event.locationInWindow, from: nil)
 let rowIndex = row(at: point)
 
 if rowIndex < 0 { // We didn't click any row
 deselectAll(nil)
 
 }
 }
 }
 
 protocol NSTableViewClickableDelegate: NSTableViewDelegate {
 func tableViewDidDeselectRow()
 // func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn, didClickRow row: Int)
 }
 */
