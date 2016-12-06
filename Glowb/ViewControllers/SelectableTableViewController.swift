//
//  SelectableTableViewController.swift
//  Glowb
//
//  Created by Michael Kavouras on 12/5/16.
//  Copyright © 2016 Michael Kavouras. All rights reserved.
//

import UIKit

enum SelectionStyle {
    case single
    case multiple
}

protocol SelectableTableViewControllerDelegate: class {
    func selectableTableViewController(viewController: UITableViewController, didSelectSelection selection: Selectable)
    func selectableTableViewController(viewController: UITableViewController, didSaveSelections selections: [Selectable])
}

class SelectableTableViewController<Item: Selectable, Cell: ReusableView>: BaseTableViewController {
    
    var selectionStyle: SelectionStyle = .single
    weak var delegate: SelectableTableViewControllerDelegate?
    
    private var items: [Item]
    private var configure: (Cell, Item) -> ()
    
    
    // MARK: - Life cycle
    
    init(items: [Item], configure: @escaping (Cell, Item) -> ()) {
        self.items = items
        self.configure = configure
        
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(cellType: Cell.self)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusable(cellType: Cell.self, forIndexPath: indexPath) as! UITableViewCell
        let item = items[indexPath.row]
        cell.selectionStyle = .none
        
        configure(cell as! Cell, item)
        
        return cell 
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectionStyle == .single {
            for var item in items {
                item.selected = false
            }
        }
        
        var selectedItem = items[indexPath.row]
        selectedItem.selected = !selectedItem.selected
        
        delegate?.selectableTableViewController(viewController: self, didSelectSelection: selectedItem)
        
        items[indexPath.row] = selectedItem
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    
    // MARK: - Utility
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
