//
//  BaseTableViewController.swift
//  Glowb
//
//  Created by Michael Kavouras on 12/3/16.
//  Copyright © 2016 Michael Kavouras. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    
    override func loadView() {
        super.loadView()
        
        view = BaseTableView(frame: CGRect.zero, style: .plain)
    }
}
