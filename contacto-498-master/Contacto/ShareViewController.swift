//
//  ShareViewController.swift
//  Contacto
//
//  Created by ishansaksena on 5/16/16.
//  Copyright © 2016 Trevor Allen. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import SCLAlertView
import ContactsUI

var roomIdGlobal: Int = 0
let AppColor: CGColor = UIColor(red: 2 / 255, green: 67 / 255, blue: 132 / 255, alpha: 1).CGColor;

class ShareViewController: UIViewController, CBPeripheralManagerDelegate, CLLocationManagerDelegate, CNContactPickerDelegate, CNContactViewControllerDelegate  {
    
    private var selectInfoVC : SelectInfoViewController?
    private var roomVC : RoomViewController?
    @IBOutlet var createBtn: UIButton!
    @IBOutlet var joinBtn: UIButton!
    
    //listener variables
    var listeningRegion: CLBeaconRegion!
    var locationManager: CLLocationManager!
    var isSearchingForBeacons = false
    var lastFoundBeacon: CLBeacon! = CLBeacon()
    var lastProximity: CLProximity! = CLProximity.Unknown
    
    //broadcaster variables
    //uuid string generated from mac terminal command "uuidgen"
    let uuid = NSUUID(UUIDString: "B97F2750-C2C1-45FC-8085-F1BD8567B2DB")
    var broadcastRegion : CLBeaconRegion!
    var bluetoothPeripheralManager: CBPeripheralManager!
    var isBroadcasting = false
    //data to transmit
    var dataDictionary = NSDictionary()

    
    // MARK: View controller functions
    override func viewDidLoad() {
        if defaults.objectForKey("MyContact") == nil {
            createNewContact()
        } else {
            localContact = Contact()
            localContact.dictionaryToContact(defaults.objectForKey("MyContact") as! NSDictionary)
            print(localContact)
        }
        self.selectInfoVC = storyboard?.instantiateViewControllerWithIdentifier("SelectInfo") as? SelectInfoViewController
        self.roomVC = storyboard?.instantiateViewControllerWithIdentifier("Room") as? RoomViewController
        createBtn.layer.cornerRadius = 3
        createBtn.layer.borderWidth = 1
        createBtn.layer.borderColor = AppColor
        joinBtn.layer.cornerRadius = 3
        
        self.joinBtn.enabled = false;
        self.createBtn.enabled = false;
        
        initializeBluetooth()
        addListeners()
        SocketIOManager.sharedInstance.socket.connect()
        super.viewDidLoad()
    }
    /*
    override func viewDidDisappear(animated: Bool) {
        let c : NSDictionary = localContact.getNSDictionary()
        if c.count > 0 {
            defaults.setObject(c, forKey: "MyContact")
        }
    }*/
    
    @IBAction func joinRoom(sender: UIButton) {
        //SocketIOManager.sharedInstance.joinRoom("767210205")
        switchSpotting();
    }
    
    @IBAction func createRoom(sender: UIButton) {
        SocketIOManager.sharedInstance.socket.emit("create-room", localContact.getNSDictionary())
    }
    
    func switchToVC(from: UIViewController?, to: UIViewController?) {
        if from != nil {
            from!.willMoveToParentViewController(nil)
            from!.view.removeFromSuperview()
            from!.removeFromParentViewController()
        }
        
        if to != nil {
            self.addChildViewController(to!)
            self.view.insertSubview(to!.view, atIndex: 0)
            to!.didMoveToParentViewController(self)
        }
    }
    
    func addListeners() {
        SocketIOManager.sharedInstance.socket.on("person-joined") { ( dataArray, ack) -> Void in
            print("person joined")
            let temp = dataArray[0] as! NSDictionary
            let receivedContact = Contact()
            receivedContact.dictionaryToContact(temp)
            contacts.append(receivedContact)
            NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
        }
        
        SocketIOManager.sharedInstance.socket.on("joined-room") { ( dataArray, ack) -> Void in
            print("joined room")
            print(dataArray)
            
            let temp = dataArray[0] as! NSDictionary
            for c in temp.objectForKey("people") as! NSArray {
                let contact = Contact()
                contact.dictionaryToContact(c as! NSDictionary)
                contacts.append(contact)
            }
            //self.roomVC!.peopleTable.reloadData()
            self.navigationController?.pushViewController(self.roomVC!, animated: true)
        }
        
        SocketIOManager.sharedInstance.socket.on("created-room") { ( dataArray, ack) -> Void in
            let temp = dataArray[0] as! NSDictionary
            if let roomID = temp.valueForKey("roomId") as? String {
                roomIdGlobal = Int(roomID)!
            }
            self.startBroadcasting(roomIdGlobal)
            self.navigationController?.pushViewController(self.selectInfoVC!, animated: true)
            print("created room")
        }
        
        SocketIOManager.sharedInstance.socket.on("connected") { (dataArray, ack) -> Void in
            print("connected")
            self.joinBtn.enabled = true;
            self.createBtn.enabled = true;
        }
        
        SocketIOManager.sharedInstance.socket.on("room-closed") { (dataArray, ack) -> Void in
            print("room-closed")
            self.navigationController?.popToRootViewControllerAnimated(true)
            if (self.isBroadcasting) {
                self.stopBroadcasting()
            }
            writeToStore()
            SocketIOManager.sharedInstance.socket.disconnect()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // Bluetooth and location
    func initializeBluetooth() {
        print("bluetooth init")
        //set up listener state
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        //same uuid as for broadcasting
        listeningRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "Contacto-Room")
        
        //ensure app knows when it enters or leaves a beacon region
        listeningRegion.notifyOnEntry = true
        listeningRegion.notifyOnExit = true
        
        //set up broadcasting state
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    //listener location manager functions
    @objc func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion)
    {
        locationManager.requestStateForRegion(region)
    }
    
    @objc func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion: CLRegion)
    {
        if(state == CLRegionState.Inside)
        {
            locationManager.startRangingBeaconsInRegion(listeningRegion)
        }
        else
        {
            locationManager.stopRangingBeaconsInRegion(listeningRegion)
        }
    }
    
    @objc func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //Entered a region
    }
    
    @objc func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        //left a region
    }
    
    @objc func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        if (beacons.count > 0)
        {
            let closestBeacon = beacons[0]
            if(closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity)
            {
                switchSpotting()
                lastFoundBeacon = closestBeacon
                lastProximity = closestBeacon.proximity
                let major = lastFoundBeacon.major
                roomIdGlobal = Int(major)
                self.navigationController?.pushViewController(self.selectInfoVC!, animated: true)
            }
        }
    }
    
    @objc func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print(error)
    }
    
    @objc func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        print(error)
    }
    
    //check the current state of Bluetooth, stop broadcasting or listening if bluetooth is off
    //and attempting broadcasting or listening
    @objc func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        var statusMessage = ""
        switch peripheral.state {
        case CBPeripheralManagerState.PoweredOn: statusMessage = "Bluetooth Status: Turned On"
        case CBPeripheralManagerState.PoweredOff:
            if(isBroadcasting) {
                stopBroadcasting()
            }
            
            if(isSearchingForBeacons) {
                switchSpotting()
            }
            statusMessage = "Bluetooth Status: Turned Off"
        case CBPeripheralManagerState.Resetting:
            statusMessage = "Bluetooth Status: Resetting"
        case CBPeripheralManagerState.Unauthorized:
            statusMessage = "Bluetooth Status: Not Authorized"
        case CBPeripheralManagerState.Unsupported:
            statusMessage = "Bluetooth Status: Not Supported"
        default:
            statusMessage = "Bluetooth Status: Unknown"
        }
    }
    
    //turn listener on or off
    func switchSpotting() {
        if(!isSearchingForBeacons)
        {
            //used in combination with key in Info.plist file
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoringForRegion(listeningRegion)
            locationManager.startUpdatingLocation()
        }
        else
        {
            locationManager.stopMonitoringForRegion(listeningRegion)
            locationManager.stopRangingBeaconsInRegion(listeningRegion)
            locationManager.stopUpdatingLocation()
        }
        //update listening flag
        isSearchingForBeacons = !isSearchingForBeacons
    }
    
    //turn broadcaster on or off
    func stopBroadcasting() {
        //stop advertising
        bluetoothPeripheralManager.stopAdvertising()
        //update broadcasting flag
        isBroadcasting = false
    }
    
    func startBroadcasting(id: Int) {
        let room = CLBeaconMajorValue(id)
        if(!isBroadcasting) {
            //ensure there is bluetooth
            if(bluetoothPeripheralManager.state == CBPeripheralManagerState.PoweredOn) {
                let major: CLBeaconMajorValue = room
                let minor: CLBeaconMinorValue = 1
                broadcastRegion = CLBeaconRegion(proximityUUID: uuid!, major: major, minor: minor, identifier:"Contacto-Region")
                dataDictionary = broadcastRegion.peripheralDataWithMeasuredPower(nil)
                bluetoothPeripheralManager.startAdvertising(dataDictionary as? [String : AnyObject])
                isBroadcasting = true
                print("broadcasting id \(id)")
            }
        }
    }
    
    func createNewContact() {
        
        // Choose contact from already existing contacts
        let chooseExistingHandler = {(action: UIAlertAction) -> Void in
            let contactPicker = CNContactPickerViewController()
            contactPicker.delegate = self
            contactPicker.predicateForSelectionOfContact = nil
            
            self.presentViewController(contactPicker, animated: true, completion: nil)
        }
        
        // create a new contact
        let createNewActionHandler = {(action: UIAlertAction) -> Void in
            //let newContact = CNMutableContact()
            let contactPicker = CNContactViewController(forNewContact: localContact.contact)
            
            //let contactPicker = CNContactViewController(forContact: localContact.contact)
            
            contactPicker.delegate = self
            self.navigationController?.pushViewController(contactPicker, animated: true)
        }
        
        
        let alertController = UIAlertController(title: "YourContactInfo", message: "Choose a method for entering your contact info so we can save it in the app.", preferredStyle: .ActionSheet)
        let useMeAction = UIAlertAction(title: "Use the Me Contact", style: .Default, handler:nil)
        let chooseExistingAction = UIAlertAction(title: "Choose an existing Contact", style: .Default, handler: chooseExistingHandler)
        let createNewAction = UIAlertAction(title: "Create a new Contact", style: .Default, handler: createNewActionHandler)
        
        alertController.addAction(useMeAction)
        alertController.addAction(chooseExistingAction)
        alertController.addAction(createNewAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // Delegate method for CNContactPickerDelegate
    // User chose a contact
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        let newContact = contact
        print(newContact.givenName)
        
        localContact.contact = contact as! CNMutableContact
        localContactIsSet = true
        saveUserSettings()
    }
    
    // Delegate method for CNContactViewControllerDelegate
    // User created a new contact
    func contactViewController(viewController: CNContactViewController, didCompleteWithContact contact: CNContact?) {
        if contact != nil {
            let newContact = contact
            print(newContact!.givenName)
            localContact.contact = contact as! CNMutableContact
            localContactIsSet = true
            saveUserSettings()
        }
    }
    
    func contactPickerDidCancel(picker: CNContactPickerViewController) {
        localContactIsSet = false
        saveUserSettings()
    }
    
    // MARK: Saving and loading contacts
    func saveContacts() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(contacts, toFile: Contact.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save contacts")
        } else {
            print("Successfully saved contacts")
        }
    }
    
    func loadContacts() {
        contacts = NSKeyedUnarchiver.unarchiveObjectWithFile(Contact.ArchiveURL.path!) as! [Contact]
        print("Loaded contacts")
    }

}
