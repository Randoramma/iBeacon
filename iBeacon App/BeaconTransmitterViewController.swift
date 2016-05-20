//
//  BeaconTransmitterViewController.swift
//  iBeacon App
//
//  Created by Randy McLain on 5/18/16.
//  Copyright © 2016 Randy McLain. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class BeaconTransmitterViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, BeaconTransmitterDelegate {
    
    let kUUIDKey = "transmit-proximityUUID"
    let kMajorIdKey = "transmit-majorId"
    let kMinorIdKey = "transmit-minorId"
    let kPowerKey = "transmit-measuredPower"
    
    @IBOutlet weak var advertiseSwitch: UISwitch!
    @IBOutlet weak var generateUUIDButton: UIButton!
    @IBOutlet weak var uuidTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var minorTextField: UITextField!
    @IBOutlet weak var powerTextField: UITextField!
    @IBOutlet weak var helpTextView: UITextView!
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    
    var doneButton: UIBarButtonItem!
    var beaconTransmitter: BeaconTransmitter!
    var isBluetoothPowerOn: Bool = true
    var defaults = NSUserDefaults.standardUserDefaults()
    
    
    var advertise : Bool {
        get {
        let status = defaults.boolForKey("kAdvertiseStatus")
            return status
        }
        set (value){
            self.advertise = value
        }
    }
    
    let numberFormatter = NSNumberFormatter()
    
    
    override func viewDidLoad() {
        uuidTextField.delegate = self
        majorTextField.delegate = self
        minorTextField.delegate = self
        helpTextView.delegate = self
        powerTextField.delegate = self 
        beaconTransmitter = BeaconTransmitter(delegate: self)
        
        initFromDefaultValues()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BeaconTransmitterViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        defaults.synchronize()
    }
    @IBAction func generateUUID() {
        uuidTextField.text = NSUUID().UUIDString
        defaults.setObject(uuidTextField.text, forKey: kUUIDKey)
    }
    
    @IBAction func toggleAdvertising() {
        if advertiseSwitch.on {
            dismissKeyboard()
            if !canBeginAdvertise() {
                advertiseSwitch.setOn(false, animated: true)
                defaults.setBool(false, forKey: "kAdvertiseStatus")
                return
            }
            let uuid = NSUUID(UUIDString: uuidTextField.text!)
            let identifier = "my.beacon"
            var beaconRegion: CLBeaconRegion?
            
            if let major = Int(majorTextField.text!) {
                if let minor = Int(minorTextField.text!) {
                    beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor), identifier: identifier)
                } else {
                    beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: CLBeaconMajorValue(major), identifier: identifier)
                }
            } else {
                beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: identifier)
            }
            
            beaconRegion!.notifyEntryStateOnDisplay = true
            beaconRegion!.notifyOnEntry = true
            beaconRegion!.notifyOnExit = true
            
            let power = numberFormatter.numberFromString(powerTextField.text!)
            
            beaconTransmitter.startAdvertising(beaconRegion, power: power)
            defaults.setBool(true, forKey: "kAdvertiseStatus")
        } else {
            defaults.setBool(false, forKey: "kAdvertiseStatus")
            beaconTransmitter.stopAdvertising()
            dismissKeyboard()
        }
    }
    
    private func canBeginAdvertise() -> Bool {
        if !isBluetoothPowerOn {
            showAlert("You must have Bluetooth powered on to advertise!")
            return false
        }
        if uuidTextField.text!.isEmpty || majorTextField.text!.isEmpty
            || minorTextField.text!.isEmpty || powerTextField.text!.isEmpty {
            showAlert("You must complete all fields")
            return false
        }
        return true
    }
    
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // MARK: UITextFieldDelegate methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == uuidTextField {
            helpTextView.text = NSLocalizedString("transmit.help.proximityUUID", comment:"foo")
        }
        else if textField == majorTextField {
            helpTextView.text = NSLocalizedString("transmit.help.major", comment:"foo")
        }
        else if textField == minorTextField {
            helpTextView.text = NSLocalizedString("transmit.help.minor", comment:"foo")
        }
        else if textField == powerTextField {
            helpTextView.text = NSLocalizedString("transmit.help.measuredPower", comment:"foo")
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        helpTextView.text = ""

        if textField == uuidTextField && !textField.text!.isEmpty {
            print (textField.text!)
            defaults.setObject(textField.text!, forKey: kUUIDKey)
        }
        else if textField == majorTextField && !textField.text!.isEmpty {
            if isMajorOrMinorEntryValid(textField.text!) {
            defaults.setObject(textField.text, forKey: kMajorIdKey)
            }
        }
        else if textField == minorTextField && !textField.text!.isEmpty {
            if isMajorOrMinorEntryValid(textField.text!) {
                defaults.setObject(textField.text, forKey: kMinorIdKey)
            }
        }
        else if textField == powerTextField && !textField.text!.isEmpty {
            // power values are typically negative
            let value = numberFormatter.numberFromString(powerTextField.text!)
            if (value?.intValue > 0) {
                powerTextField.text = numberFormatter.stringFromNumber(0 - value!.intValue)
            }
            defaults.setObject(textField.text, forKey: kPowerKey)
        }
    }
    
    //MARK:
    //MARK: KeyboardDelegate
    
    func dismissKeyboard() {
        uuidTextField.resignFirstResponder()
        majorTextField.resignFirstResponder()
        minorTextField.resignFirstResponder()
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    private func initFromDefaultValues() {

        if let uuid = defaults.stringForKey(kUUIDKey) {
            uuidTextField.text = uuid
        }
        if let major = defaults.stringForKey(kMajorIdKey) {
            majorTextField.text = major
        }
        if let minor = defaults.stringForKey(kMinorIdKey) {
            minorTextField.text = minor
        }
        
        advertiseSwitch.on = advertise
    }
    
    
    
    //MARK:
    //MARK: BeaconTransmitterDelegate
    
    func didPowerOn() {
        isBluetoothPowerOn = true
    }
    
    func didPowerOff() {
        isBluetoothPowerOn = false
    }
    
    func isMajorOrMinorEntryValid(theValue: String) -> Bool {
        let theIntValue : Int? = Int(theValue)
        var result : Bool = false
        if let value = theIntValue {
           if (value >= 0 && value <= 65535) {
                result =  true
            } else {
                result = false
            showAlert("Value not saved.  Please enter value between 0 and 65535")
            }
        }
        return result
    }

func onError(error: NSError) {
    
}

func showAlert(message: String) {
    let alertController = UIAlertController(title:"iBeaconApp", message: message, preferredStyle: .Alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
    self.presentViewController(alertController, animated: true, completion: nil)
}


}