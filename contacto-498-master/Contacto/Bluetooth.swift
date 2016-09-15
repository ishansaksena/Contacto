//
//  Bluetooth.swift
//  Contacto
//
//  Created by Annie Lace on 5/29/16.
//  Copyright © 2016 Trevor Allen. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth

class Broadcaster : NSObject, CBPeripheralManagerDelegate
{
    static var broadcaster = Broadcaster()
    
    let uuid = NSUUID(UUIDString: "B97F2750-C2C1-45FC-8085-F1BD8567B2DB")
    var beaconRegion : CLBeaconRegion!
    var bluetoothPeripheralManager: CBPeripheralManager!
    var isBroadcasting = false
    var dataDictionary = NSDictionary()
    
    override init()
    {
        super.init()
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    //Bluetooth state Change
    @objc func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager)
    {
        var statusMessage = ""
        switch peripheral.state
        {
        case CBPeripheralManagerState.PoweredOn: statusMessage = "Bluetooth Status: Turned On"
        case CBPeripheralManagerState.PoweredOff:
            if(isBroadcasting)
            {
                switchBroadcastingState()
            }
            statusMessage = "Bluetooth Status: Turned Off"
        case CBPeripheralManagerState.Resetting: statusMessage = "Bluetooth Status: Resetting"
        case CBPeripheralManagerState.Unauthorized : statusMessage = "Bluetooth Status: Not Authorized"
        case CBPeripheralManagerState.Unsupported : statusMessage = "Bluetooth Status: Not Supported"
        default: statusMessage = "Bluetooth Status: Unknown"
        }
    }
    
    //Start or Stop Broadcasting
    func switchBroadcastingState() {
        //start broadcasting
        if(!isBroadcasting)
        {
            //ensure there is bluetooth
            if(bluetoothPeripheralManager.state == CBPeripheralManagerState.PoweredOn)
            {
                //set up the region
                //TODO: Get major and minor values
                //major and minor values are room keys
                let major: CLBeaconMajorValue = 1
                let minor: CLBeaconMinorValue = 1
                
                //identifier needs to be a unique string
                beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: major, minor: minor, identifier: "room beacon")
                //advertise the region
                //dictionary must be initialized with signal strength (RSSI) value of device
                //passing in nil uses the default RSSI value of the device
                
                //SocketIOManager.sharedInstance.connectToServerCreateRoom()
                
                dataDictionary = beaconRegion.peripheralDataWithMeasuredPower(nil)
                
                bluetoothPeripheralManager.startAdvertising(dataDictionary as? [String : AnyObject])
                
                
                //update broadcasting flag
                isBroadcasting = true
            }
        }
            //stop broadcasting
        else
        {
            //stop advertising
            bluetoothPeripheralManager.stopAdvertising()
            
            //update broadcasting flag
            isBroadcasting = false
        }
    }
    
    
}

class Listener : NSObject, CLLocationManagerDelegate, CBPeripheralManagerDelegate
{
    static var listener = Listener()
    
    var beaconRegion: CLBeaconRegion!
    var locationManager: CLLocationManager!
    var isSearchingForBeacons = false
    var lastFoundBeacon: CLBeacon! = CLBeacon()
    var lastProximity: CLProximity! = CLProximity.Unknown
    var bluetoothPeripheralManager: CBPeripheralManager!
    
    override init()
    {
        super.init();
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        //same uuid as for broadcasting
        let uuid = NSUUID(UUIDString: "B97F2750-C2C1-45FC-8085-F1BD8567B2DB")
        beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "room beacon")
        //ensure app knows when it enters or leaves a beacon region
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    @objc func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager)
    {
        var statusMessage = ""
        switch peripheral.state
        {
        case CBPeripheralManagerState.PoweredOn: statusMessage = "Bluetooth Status: Turned On"
        case CBPeripheralManagerState.PoweredOff:
            if(isSearchingForBeacons)
            {
                switchSpotting();
            }
            statusMessage = "Bluetooth Status: Turned Off"
        case CBPeripheralManagerState.Resetting: statusMessage = "Bluetooth Status: Resetting"
        case CBPeripheralManagerState.Unauthorized : statusMessage = "Bluetooth Status: Not Authorized"
        case CBPeripheralManagerState.Unsupported : statusMessage = "Bluetooth Status: Not Supported"
        default: statusMessage = "Bluetooth Status: Unknown"
        }
    }
    
    @objc func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion)
    {
        locationManager.requestStateForRegion(region)
    }
    
    //called every time device enters or leaves a region
    @objc func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion: CLRegion)
    {
        if(state == CLRegionState.Inside)
        {
            locationManager.startRangingBeaconsInRegion(beaconRegion)
        }
        else
        {
            locationManager.stopRangingBeaconsInRegion(beaconRegion)
        }
    }
    
    @objc func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion)
    {
        //Entered a region
    }
    
    @objc func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion)
    {
        //Exited a region
    }
    
    //find the closest beacon, save it as lastFoundBeacon
    @objc func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        if (beacons.count > 0)
        {
            let closestBeacon = beacons[0]
            if(closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity)
            {
                lastFoundBeacon = closestBeacon
                lastProximity = closestBeacon.proximity
                
                var proximityMessage: String!
                switch lastFoundBeacon.proximity
                {
                case CLProximity.Immediate:
                    proximityMessage = "Very close"
                    
                case CLProximity.Near:
                    proximityMessage = "Near"
                    
                case CLProximity.Far:
                    proximityMessage = "Far"
                    
                default:
                    proximityMessage = "Where's the beacon?"
                }
            }
        }
        
    }
    
    @objc func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError)
    {
        print(error)
    }
    
    @objc func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError)
    {
        print(error)
    }
    
    //Start or stop looking for beacons
    func switchSpotting()
    {
        if(!isSearchingForBeacons)
        {
            //used in combination with key in Info.plist file
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoringForRegion(beaconRegion)
            locationManager.startUpdatingLocation()
        }
        else
        {
            locationManager.stopMonitoringForRegion(beaconRegion)
            locationManager.stopRangingBeaconsInRegion(beaconRegion)
            locationManager.stopUpdatingLocation()
        }
        isSearchingForBeacons = !isSearchingForBeacons
    }
    
}