//
//  SettingsVC.swift
//  PasswordManager
//
//  Created by Maor Shams on 14/07/2017.
//  Copyright © 2017 Maor Shams. All rights reserved.
//

import Cocoa

class SettingsVC: NSViewController {
    
    @IBOutlet weak var logoutTimerPicker: NSPopUpButton!
    @IBOutlet weak var passwordEncryption: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        fetchData()
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismissViewController(self)
    }
    
    @IBAction func passwordEncryptionAction(_ sender: NSButton) {
        let isSelected = sender.state == NSOnState ? true : false
        UserDefaults.standard.set(isSelected , forKey: Constants.PASSWORD_ENCRYPTION)
        DBManager.manager.appsEncryptionEnabled(isSelected)
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
    
    
}
