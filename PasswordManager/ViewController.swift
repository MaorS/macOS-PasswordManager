//
//  ViewController.swift
//  PasswordManager
//
//  Created by Maor Shams on 07/07/2017.
//  Copyright © 2017 Maor Shams. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
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
        fetchData()
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        guard let nextVC = segue.destinationController as? PasswordEditorVC,
            let app = sender as? App else {
                return
        }
        
        nextVC.editableApp = app
    }
    
    func fetchData(){
        DBManager.manager.fetchData { (apps) in
            self.data = []
            self.data = apps
            self.tableView.reloadData()
        }
    }
    
    @IBAction func didSearchAction(_ sender: NSSearchField) {
        let filter = sender.stringValue
        DBManager.manager.fetchData(with: filter) { (apps) in
            self.filteredData = apps
            self.tableView.reloadData()
        }
    }
    
    func tableViewDidClick(){
        let row = tableView.clickedRow
        let column = tableView.clickedColumn
        let unselected = -1
        
        if row == unselected && column == unselected{
            tableViewDidDeselectRow()
            return
        }else if row != unselected && column != unselected{
            tableViewDidSelectRow(row: row, column: column)
            return
        }else if column != unselected && row == unselected{
            tableviewDidSelectHeader(column: column)
        }
    }
    
    var editableCellsUserInteraction : Bool = false{
        didSet{
            deletePasswordButton.isEnabled = editableCellsUserInteraction
            editPasswordButton.isEnabled = editableCellsUserInteraction
        }
    }
    
    private func tableViewDidDeselectRow() {
        editableCellsUserInteraction = false
    }
    
    private func tableViewDidSelectRow(row : Int,column : Int){
        editableCellsUserInteraction = true
        if let cell = tableView.view(atColumn: column, row: row, makeIfNecessary: false) as? PasswordCell{
            if cell.isPasswordVisible{
                cell.didTapVisiblePasswordAction()
            }
        }
    }
    
    private func tableviewDidSelectHeader(column : Int){
        editableCellsUserInteraction = false
    }
    
    @IBAction func deletePasswordAction(_ sender: NSButton) {
        let row = tableView.selectedRow
        let column = tableView.column(withIdentifier: "password")
        
        guard row != -1 ,
            let cell = tableView.view(atColumn: column, row: row, makeIfNecessary: false) as? PasswordCell else{
                return
        }
        
        Utils.showAlert(message: "Delete Password", infoText: "Are you sure ?") { (answer) in
            if answer == true{
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
                self.tableView.reloadData()
            }
        }
        
    }
    
    @IBAction func editPasswordAction(_ sender: NSButton) {
        let selectedRow = tableView.selectedRow
        if selectedRow != -1 {
            let app = self.filteredData.isEmpty ? self.data[selectedRow] : self.filteredData[selectedRow]
            self.performSegue(withIdentifier: "passwordEditorSegue", sender: app)
        }
    }
    
}
extension ViewController : NSTableViewDelegate, NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredData.isEmpty ? data.count : filteredData.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let tableColumn = tableColumn ,
            let cell = tableView.make(withIdentifier: (tableColumn.identifier), owner: self) as? NSTableCellView else{
                return nil
        }
        
        let app = filteredData.isEmpty ? data[row] : filteredData[row]
        
        switch tableColumn.identifier {
        case Constants.PASSWORD:
            
            // config password column
            if let cell = cell as? PasswordCell{
                cell.passwordTextField.stringValue = app.password!
                cell.delegate = self
                cell.row = row
                cell.isPasswordVisible = app.isPasswordVisible
            }
            
        case Constants.USERNAME:
            cell.textField?.stringValue = app.userName ?? ""
        case Constants.APP_NAME:
            cell.textField?.stringValue = app.appName ?? ""
        default:return nil
        }
        
        return cell
    }
}
extension ViewController : DBManagerDelegate{
    
    func newAppDidAdded(app: App) {
        data.append(app)
        tableView.reloadData()
    }
    
    func appDidEdit(oldApp: App, newApp: App) {
        for i in 0..<data.count{
            if data[i] == oldApp{
                data.remove(at: i)
                data.append(newApp)
                self.tableView.reloadData()
            }
        }
    }
    
}
extension ViewController : PasswordCellDelegate{
    
    func cellDidPressToShowPassword(row: Int, show: Bool) {
        let app = filteredData.isEmpty ? data[row] : filteredData[row]
        DBManager.manager.showPassFor(app: app, show: show)
    }
}

