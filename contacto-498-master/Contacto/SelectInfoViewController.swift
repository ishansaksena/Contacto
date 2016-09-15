//
//  SelectInfoViewController.swift
//  Contacto
//
//  Created by Trevor Allen on 5/29/16.
//  Copyright © 2016 Trevor Allen. All rights reserved.
//

import UIKit
import Contacts

class SelectInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var presetsBtn: UIButton!
    @IBOutlet var addEditBtn: UIButton!
    @IBOutlet var infoTable: UITableView!
    
    let AppColor: CGColor = UIColor(red: 2 / 255, green: 67 / 255, blue: 132 / 255, alpha: 1).CGColor;
    
    var contactFields : NSArray?
    var contactDict : NSDictionary?
    var selectedFields: [Int]?
    
    override func viewDidLoad() {
        presetsBtn.layer.cornerRadius = 3
        addEditBtn.layer.cornerRadius = 3
        addEditBtn.layer.borderWidth = 1
        addEditBtn.layer.borderColor = AppColor
        infoTable.delegate = self
        infoTable.dataSource = self
        infoTable.allowsMultipleSelection = true
        self.contactFields = localContact.getContactKeys()
        self.contactDict = localContact.getNSDictionary()
        self.selectedFields = [Int](count: self.contactFields!.count, repeatedValue: 1)
        let rightButton = UIBarButtonItem(title: "Share", style: .Plain, target: self, action: #selector(SelectInfoViewController.joinRoom))
        self.navigationItem.rightBarButtonItem = rightButton
        super.viewDidLoad()
    }
    
    func joinRoom() {
        let dict : NSMutableDictionary = NSMutableDictionary()
        var index : Int = 0
        for key in contactFields! {
            if selectedFields![index] == 1 {
                dict.setObject(contactDict!.objectForKey(key)!, forKey: key as! String)
            }
            index = index + 1
        }
        SocketIOManager.sharedInstance.socket.emit("join-room", dict, roomIdGlobal)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactFields!.count;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedFields![indexPath.row] = 1
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedFields![indexPath.row] = 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : SelectLableTableViewCell = infoTable.dequeueReusableCellWithIdentifier("default", forIndexPath: indexPath) as! SelectLableTableViewCell
        cell.label.text = contactDict?.objectForKey(contactFields![indexPath.row]) as? String
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
}
