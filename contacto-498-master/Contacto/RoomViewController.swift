//
//  RoomViewController.swift
//  Contacto
//
//  Created by Trevor Allen on 6/2/16.
//  Copyright © 2016 Trevor Allen. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    
    @IBOutlet var peopleTable: UITableView!
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        self.peopleTable.delegate = self
        self.peopleTable.dataSource = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoomViewController.loadList(_:)), name: "load", object: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = contacts[indexPath.row].contact.givenName
        return cell
    }
    
    func loadList(notification: NSNotification){
        //load data here
        dispatch_async(dispatch_get_main_queue(),{
            self.peopleTable.reloadData()
        });
    }
}
