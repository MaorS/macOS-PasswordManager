//
//  ViewController.swift
//  PasswordManager
//
//  Created by Maor Shams on 07/07/2017.
//  Copyright © 2017 Maor Shams. All rights reserved.
//

import Cocoa

class MainVC: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var deletePasswordButton: NSButton!
    @IBOutlet weak var editPasswordButton: NSButton!
    @IBOutlet weak var newPasswordButton: NSButton!
    @IBOutlet weak var searchField:NSSearchField!
    
    var data = [App]()
    var filteredData = [App]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.target = self
        tableView.action = #selector(tableViewDidClick)
        
        DBManager.manager.delegate = self
        TimerManager.manager.delegate = self
        fetchData()
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        guard let nextVC = segue.destinationController as? PasswordEditorVC,
            let app = sender as? App else {
                return
        }
        
        nextVC.editableApp = app
    }
    
    /// User did search
    @IBAction func didSearchAction(_ sender: NSSearchField) {
        let filter = sender.stringValue
        DBManager.manager.fetchData(with: filter) { (apps) in
            self.filteredData = apps
            self.tableView.reloadData()
        }
    }
    
    /// User did click delete button
    @IBAction func deletePasswordAction(_ sender: NSButton) {
        
        let row = tableView.selectedRow
        let column = tableView.column(withIdentifier: Constants.PASSWORD)
        
        guard row != -1 ,
            let cell = tableView.view(atColumn: column, row: row, makeIfNecessary: false) as? PasswordCell else{
                return
        }
        
        // show alert for user
        Utils.showAlert(message: "Delete Password", infoText: "Are you sure ?") { (answer) in
            
            if answer == true{ // if clicked ok
                
                // get the app
                let app = self.filteredData.isEmpty ? self.data[row] : self.filteredData[row]
                
                if cell.isPasswordVisible{
                    cell.isPasswordVisible = false
                }
                
                // if user press delete while search is on
                if !self.filteredData.isEmpty{
                    for i in 0..<self.data.count{
                        if self.data[i] == app{
                            self.data.remove(at: i)
                            self.filteredData.remove(at: row)
                            break
                        }
                    }
                }else{
                    self.data.remove(at: row)
                }
                
                DBManager.manager.deleteApp(app)
                self.searchField.stringValue = ""
                self.tableView.reloadData()
            }
        }
    }
    
    /// User did click edit button
    @IBAction func editPasswordAction(_ sender: NSButton) {
        let selectedRow = tableView.selectedRow
        
        if selectedRow != -1 {
            let app = self.filteredData.isEmpty ? self.data[selectedRow] : self.filteredData[selectedRow]
            self.performSegue(withIdentifier: Constants.PASSWORD_EDITOR_SEGUE, sender: app)
        }
    }
    
    /// Enable / Disable interaction with delete/edit button when cell is not selected
    var editableCellsUserInteraction : Bool = false{
        didSet{
            deletePasswordButton.isEnabled = editableCellsUserInteraction
            editPasswordButton.isEnabled = editableCellsUserInteraction
        }
    }
    
    /// Fetch apps list from Core Data
    func fetchData(){
        DBManager.manager.fetchData { (apps) in
            self.data = []
            self.data = apps
            self.tableView.reloadData()
        }
    }
    
    /// TableView did click
    func tableViewDidClick(){
        
        let row = tableView.clickedRow
        let column = tableView.clickedColumn
        let unselected = -1
        
        // Check what was clicked
        if row == unselected && column == unselected{
            // nothing was selected
            editableCellsUserInteraction = false
            return
        }else if row != unselected && column != unselected{
            // row did select
            tableViewDidSelectRow(row: row, column: column)
            return
        }else if column != unselected && row == unselected{
            // header did select
            tableviewDidSelectHeader(column: column)
        }
    }
    
    /// Table View did select row
    private func tableViewDidSelectRow(row : Int,column : Int){
        
        editableCellsUserInteraction = true
        
        // If cell is selected and user has pressed while password is visible, copy the password
        if let cell = tableView.view(atColumn: column, row: row, makeIfNecessary: false) as? PasswordCell,
            cell.isPasswordVisible {
            cell.copyPasswordAction()
        }
    }
    
    /// Table View did select header
    private func tableviewDidSelectHeader(column : Int){
        editableCellsUserInteraction = false
    }
}

extension MainVC : NSTableViewDelegate, NSTableViewDataSource{
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredData.isEmpty ? data.count : filteredData.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let tableColumn = tableColumn ,
            let cell = tableView.make(withIdentifier: (tableColumn.identifier), owner: self) as? NSTableCellView else{
                return nil
        }
        
        let app = filteredData.isEmpty ? data[row] : filteredData[row]
        
        // Setup each table column
        
        switch tableColumn.identifier {
        case Constants.PASSWORD:
            if let cell = cell as? PasswordCell{
                cell.configCell(app: app, row: row, listener: self)
            }
            
        case Constants.USERNAME:
            if DBManager.manager.isEncryptionEnabled{
                cell.textField?.stringValue = DBManager.manager.aesDecrypt(text: app.userName)
            }else{
                cell.textField?.stringValue = app.userName
            }
        case Constants.APP_NAME:
            if DBManager.manager.isEncryptionEnabled{
                cell.textField?.stringValue = DBManager.manager.aesDecrypt(text: app.appName )
            }else{
                cell.textField?.stringValue = app.appName
            }
        default: return nil
        }
        return cell
    }
}

extension MainVC : DBManagerDelegate{
    
    // New app has been add
    func newAppDidAdded(app: App) {
        data.append(app)
        tableView.reloadData()
    }
    
    // App has been edit
    func appDidEdit(oldApp: App, newApp: App) {
        for i in 0..<data.count{
            if data[i] == oldApp{
                data.remove(at: i)
                data.append(newApp)
                self.tableView.reloadData()
            }
        }
    }
    
    // Apps Encryption has changed
    func appsEncryptionDidChange(apps: [App]) {
        filteredData = []
        data = apps
        tableView.reloadData()
    }
    
    // All apps has been removed
    func appsDidRemove() {
        data = []
        filteredData = []
        tableView.reloadData()
    }
}

extension MainVC : PasswordCellDelegate{
    
    // User did press show password
    func cellDidPressToShowPassword(row: Int, show: Bool) {
        let app = filteredData.isEmpty ? data[row] : filteredData[row]
        DBManager.manager.showPassFor(app: app, show: show)
    }
}

extension MainVC : TimerManagerDelegate{
    
    // Timer has been finish
    func timerDidFinish() {
        self.performSegue(withIdentifier: Constants.BACK_SEGUE, sender: nil)
    }
}

