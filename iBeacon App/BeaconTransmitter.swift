//
//  BeaconTransmitter.swift
//  iBeacon App
//
//  Created by Randy McLain on 5/18/16.
//  Copyright © 2016 Randy McLain. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation

protocol BeaconTransmitterDelegate: NSObjectProtocol {
    func didPowerOn()
    func didPowerOff()
    func onError(error: NSError)
}



class BeaconTransmitter: NSObject, CBPeripheralManagerDelegate {
    
    var peripheralManager: CBPeripheralManager!
    
    weak var delegate: BeaconTransmitterDelegate?
    
    
    init(delegate: BeaconTransmitterDelegate?) {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        self.delegate = delegate
    }
    
    func startAdvertising(beaconRegion: CLBeaconRegion?, power:NSNumber?) {
        let data = NSDictionary(dictionary: (beaconRegion?.peripheralDataWithMeasuredPower(power))!) as! [String: AnyObject]
        peripheralManager.startAdvertising(data)
    }
    
    func stopAdvertising() {
        
        peripheralManager.stopAdvertising()
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
    
        
    }
    

 
    
    
}
