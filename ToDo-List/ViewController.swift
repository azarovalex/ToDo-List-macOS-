//
//  ViewController.swift
//  ToDo-List
//
//  Created by Alex Azarov on 5/14/18.
//  Copyright © 2018 Alex Azarov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var importantCheckbox: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var deleteButton: NSButton!
    
    var toDoItems = [ToDoItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getToDoItems()
    }
    
    func getToDoItems() {
        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                toDoItems = try context.fetch(ToDoItem.fetchRequest())
                print(toDoItems.count)
            } catch {}
        }
        tableView.reloadData()
    }
    
    @IBAction func addClicked(_ sender: Any) {
        guard textField.stringValue != "" else { return }
        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let toDoItem = ToDoItem(context: context)
            toDoItem.name = textField.stringValue
            toDoItem.important = (importantCheckbox.state.rawValue == 0) ? false : true
            (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
            
            importantCheckbox.state = .off
            textField.stringValue = ""
            getToDoItems()
        }
    }
    @IBAction func deleteClicked(_ sender: Any) {
        guard tableView.selectedRow >= 0 else { return }
        let toDoItem = toDoItems[tableView.selectedRow]
        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            context.delete(toDoItem)
            (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
            getToDoItems()
            deleteButton.isHidden = true
        }
    }
}

// MARK: - TableView Stuff

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return toDoItems.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let toDoItem = toDoItems[row]
        
        if tableColumn?.identifier.rawValue == "importantColumn" {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "importantCell"), owner: self) as? NSTableCellView {
                cell.textField?.stringValue = toDoItem.important ? "❗️" : ""
                return cell
            }
            return nil
        } else { // toDoColumn
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "toDoItems"), owner: self) as? NSTableCellView {
                
                
                cell.textField?.stringValue = toDoItem.name ?? ""
                return cell
            }
            return nil
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        deleteButton.isHidden = false
    }
}

