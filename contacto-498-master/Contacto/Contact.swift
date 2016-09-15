//
//  Contact.swift
//  Contacto
//
//  Created by ishansaksena on 5/13/16.
//  Copyright © 2016 Trevor Allen. All rights reserved.
//

import Foundation
import Contacts

// Wrapper around default ios Contact
// Has additional attributes like github accounts
class Contact: NSObject, NSCoding {
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let LocalArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("localContact")
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("contacts")

    
    // MARK: Properties
    var contact = CNMutableContact()
    var phoneNumbers = [String]()
    //var phoneNumberLabels = [String]()
    var emails = [String]()
    //var emailLabels = [String]()
    var facebookURL = ""
    var twitterURL = ""
    
    // Mark: Initializers
    // From another contact
    init(contact: CNMutableContact) {
        self.contact = contact
    }
    
    // From NSUserDefaults i.e. from the landing page
    convenience override init() {
        let newContact = CNMutableContact()
        self.init(contact: newContact)
        phoneNumbers = [String](count: 1, repeatedValue: "")
        emails = [String](count: 1, repeatedValue: "")
    }
    
    // MARK: Functions
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.contact, forKey: "contact")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let newContact = aDecoder.decodeObjectForKey("contact") as! CNMutableContact
        
        // Must call designated initializer.
        self.init(contact: newContact)
    }
    
    func getNSDictionary() -> NSDictionary {
        let dict = NSMutableDictionary()
        if contact.givenName != "" {
            dict["name"] = "\(contact.givenName) \(contact.familyName)"
        }
        if  contact.phoneNumbers.count > 0 {
            dict["phoneNumber"] = (contact.phoneNumbers[0].value as! CNPhoneNumber).valueForKey("digits") as! String
        }
        if  contact.emailAddresses.count > 0 {
            dict["email"] = contact.emailAddresses[0].value as! String
        }
        return dict
    }

    func dictionaryToContact(dict: NSDictionary) -> CNMutableContact {
        if (dict["name"] != nil) {
            contact.givenName = dict["name"] as! String
        }
        if  dict["phoneNumber"] != nil {
            self.phoneNumbers[0] = dict["phoneNumber"] as! String
            let phoneNumber = CNPhoneNumber(stringValue: self.phoneNumbers[0])
            let phone = CNLabeledValue(label: CNLabelHome, value: phoneNumber)
            contact.phoneNumbers.append(phone)
        }
        if  dict["email"] != nil {
            self.emails[0] = dict["email"] as! String
            let email = CNLabeledValue(label: CNLabelHome, value: self.emails[0])
            contact.emailAddresses.append(email)
        }
        return contact
    }
    
    func getContactKeys() -> NSArray {
        let keys : NSMutableArray = NSMutableArray()
        if contact.givenName != "" {
            keys.addObject("name")
        }
        
        if contact.phoneNumbers.count > 0 {
            keys.addObject("phoneNumber")
        }
        
        if contact.emailAddresses.count > 0 {
            keys.addObject("email")
        }
        return keys
    }
}

// MARK: Global contacts

// This iPhone owners own contact
var localContact = Contact()

// Sets the local users details as localContact
func setLocalContact() {
//    localContact = Contact()
//    localContact.contact.givenName = "ISHY SAKSY"
//    localContact.contact.familyName = "TREVOR ALLEN"
//    let firstphone = CNPhoneNumber(stringValue: "234234234")
//    let firstPhoneNumber = CNLabeledValue(label: CNLabelPhoneNumberMain, value: firstphone)
//    localContact.contact.phoneNumbers.append(firstPhoneNumber)
//    let firstEmail = CNLabeledValue(label: CNLabelWork, value: "ishysaksy@gmail.com")
//    localContact.contact.emailAddresses.append(firstEmail)
//    localContact.facebookURL = "www.facebook.com/ishan.saksena"
}

//
var localContactIsSet = false
let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()

func saveUserSettings() {
    defaults.setObject(localContact.getNSDictionary(), forKey: "MyContact")
}

// Recieved contacts
var contacts = [Contact]()

// Store reference
let store = CNContactStore()

// Store in iPhone contacts
func writeToStore() {
    let saveRequest = CNSaveRequest()
    // Saving contacts
    for n in 0 ..< contacts.count {
        let newContact: CNMutableContact = contacts[n].contact
        saveRequest.addContact(newContact, toContainerWithIdentifier:nil)
    }
    
    try! store.executeSaveRequest(saveRequest)
}




