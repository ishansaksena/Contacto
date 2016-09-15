//
//  HistoryTableViewController.swift
//  Contacto
//
//  Created by studentuser on 5/29/16.
//  Copyright © 2016 Trevor Allen. All rights reserved.
//

import UIKit
import Contacts

class HistoryTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Setting up sample data
        /*let newContact = Contact()
        newContact.contact.givenName = "Ishans an idiot"
        newContact.contact.familyName = "for sure"
        let email = CNLabeledValue(label: CNLabelWork, value: "whostheclown@gmail.com")
        let phonen = CNPhoneNumber(stringValue: "1234567890")
        let phone = CNLabeledValue(label: CNLabelPhoneNumberMain, value: phonen)
        newContact.contact.emailAddresses.append(email)
        newContact.contact.phoneNumbers.append(phone)
        
        contacts.append(newContact)
        contacts.append(newContact)
        print(contacts.count)*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contacts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Contact", forIndexPath: indexPath)
        //cell .textLabel?.text = "Party animal"
        // Configure the cell...
        cell.textLabel?.text = contacts[indexPath.row].contact.givenName
        cell.detailTextLabel?.text = contacts[0].contact.familyName
        
        let dict = contacts[indexPath.row].getNSDictionary()
        let keys = contacts[indexPath.row].getNSDictionary()
        
        
        cell.textLabel?.text = dict["name"] as? String
        cell.detailTextLabel?.text = dict["email"] as? String
        
        if (dict["name"] != nil) {
            cell.textLabel?.text = dict["name"] as? String
        }
        if  dict["phoneNumber"] != nil {
            //self.phoneNumbers[0] = dict["phoneNumber"] as! String
            //let phone = CNLabeledValue(label: CNLabelHome, value: self.phoneNumbers[0])
            //contact.phoneNumbers.append(phone)
        }
        if  dict["email"] != nil {
             cell.detailTextLabel?.text = dict["email"] as! String
        }

        
        cell.textLabel

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
