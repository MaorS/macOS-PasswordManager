//
//  SettingsVC.swift
//  PasswordManager
//
//  Created by Maor Shams on 14/07/2017.
//  Copyright © 2017 Maor Shams. All rights reserved.
//

import Cocoa
import CSV

class SettingsVC: NSViewController {
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var logoutTimerPicker: NSPopUpButton!
    @IBOutlet weak var passwordEncryption: NSButton!
    @IBOutlet weak var deleteAllPasswordsTop: NSLayoutConstraint!
    
    @IBOutlet weak var importColumnLabel1: NSTextField!
    @IBOutlet weak var importColumnLabel2: NSTextField!
    @IBOutlet weak var importColumnLabel3: NSTextField!
    
    @IBOutlet weak var importColumnPopUp1: NSPopUpButton!
    @IBOutlet weak var importColumnPopUp2: NSPopUpButton!
    @IBOutlet weak var importColumnPopUp3: NSPopUpButton!
    
    @IBOutlet weak var importSelectCellsView: NSView!
    
    var csv: CSVReader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        fetchData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // view.window!.styleMask.remove(NSWindowStyleMask.resizable)
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismissViewController(self)
    }
    
    @IBAction func passwordEncryptionAction(_ sender: NSButton) {
        let isSelected = sender.state == NSOnState ? true : false
        UserDefaults.standard.set(isSelected , forKey: Constants.PASSWORD_ENCRYPTION)
        DBManager.manager.appsEncryptionEnabled(isSelected)
    }
    
    @IBAction func importCSVFileAction(_ sender: NSButton) {
        guard let path = showSelectCSVFileDialog(),
            let stream = InputStream(fileAtPath: path),
            let csv = try? CSVReader(stream: stream, hasHeaderRow: true),
            let headers = csv.headerRow, headers.count >= 3 else{
                return
        }
        
        importColumnLabel1.stringValue = headers[0]
        importColumnLabel2.stringValue = headers[1]
        importColumnLabel3.stringValue = headers[2]
        
        resizeScreen()
        deleteAllPasswordsTop.constant = 160
        importSelectCellsView.isHidden = false
        sender.isEnabled = false
        
        self.csv = csv
    }
    
    @IBAction func saveImportAction(_ sender: NSButton) {
        
        guard let csv = csv,
            !importColumnLabel1.stringValue.isEmpty,
            !importColumnLabel2.stringValue.isEmpty,
            !importColumnLabel3.stringValue.isEmpty else{
                return
        }
        
        guard let appNameIndex =  getIndex(of: "App Name"),
              let userNameIndex = getIndex(of: "User Name"),
              let passwordIndex = getIndex(of: "Password") else{
                return
        }
        
        progressIndicator.startAnimation(nil)
        
        while let row = csv.next(){
            let appName =  row[appNameIndex]
            let userName = row[userNameIndex]
            let password = row[passwordIndex]
            
            DBManager.manager.addNewApp(appName: appName, userName: userName, password: password)
        }
        
        progressIndicator.stopAnimation(nil)
        
    }
    
    
    @IBAction func autoLogoutAction(_ sender: NSPopUpButton) {
        guard let title = sender.selectedItem?.title.lowercased() else{
            return
        }
        var minutes = 0
        
        switch title {
        case "1 minutes": minutes = 1
        case "5 minutes":  minutes = 5
        case "10 minutes":  minutes = 10
        case "20 minutes":  minutes = 20
        case "30 minutes":  minutes = 30
        default:break
        }
        
        TimerManager.manager.configNewTimer(timeInMinutes: minutes)
    }
    
    @IBAction func deleteAllPasswordsAction(_ sender: NSButton) {
        Utils.showAlert(message: "Warning", infoText: "Are you sure you want to delete all passwords?") { (answer) in
            if answer == true{// delete
                DBManager.manager.deleteAllData()
            }
        }
        
    }
    
    func fetchData(){
        
        let logoutTimer = UserDefaults.standard.integer(forKey: Constants.LOGOUT_TIMER)
        
        switch logoutTimer {
        case 0:  logoutTimerPicker.selectItem(at: 0)
        case 1:  logoutTimerPicker.selectItem(at: 1)
        case 5:  logoutTimerPicker.selectItem(at: 2)
        case 10: logoutTimerPicker.selectItem(at: 3)
        case 20: logoutTimerPicker.selectItem(at: 4)
        case 30: logoutTimerPicker.selectItem(at: 5)
        default:break
        }
        
        self.passwordEncryption.state = DBManager.manager.isEncryptionEnabled ? NSOnState : NSOffState
    }
    
    /// Show select CSV file dialog
    func showSelectCSVFileDialog() -> String?{
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a .CSV file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["csv"];
        
        if (dialog.runModal() == NSModalResponseOK) {
            if let result = dialog.url{
                return result.path
            }
            return nil
        } else {// User clicked on "Cancel"
            return nil
        }
        
    }
    
    /// Get the index of import menu option
    func getIndex(of menuOption : String) -> Int?{
        
        let buttons : [NSPopUpButton] = [importColumnPopUp1,importColumnPopUp2,importColumnPopUp3]
        
        for i in 0..<buttons.count{
            if buttons[i].selectedItem?.title == menuOption{
                return i
            }
        }
        return nil
    }
    
    /// Resize the the screen when import is done
    func resizeScreen(){
        let window = self.view.window!
        let height = window.frame.height + (window.frame.height * 0.6)
        let width = window.frame.width + ( window.frame.width * 0.2)
        window.setFrame(NSRect(x: 0, y: 0, width:width , height: height), display: true, animate: true)
    }
    
}
