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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    var defaults = UserDefaults.standard
    
    
    var advertise : Bool {
        get {
        let status = defaults.bool(forKey: "kAdvertiseStatus")
            return status
        }
        set (value){
            self.advertise = value
        }
    }
    
    let numberFormatter = NumberFormatter()
    
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        defaults.synchronize()
    }
    @IBAction func generateUUID() {
        uuidTextField.text = UUID().uuidString
        defaults.set(uuidTextField.text, forKey: kUUIDKey)
    }
    
    @IBAction func toggleAdvertising() {
        if advertiseSwitch.isOn {
            dismissKeyboard()
            if !canBeginAdvertise() {
                advertiseSwitch.setOn(false, animated: true)
                defaults.set(false, forKey: "kAdvertiseStatus")
                return
            }
            let uuid = UUID(uuidString: uuidTextField.text!)
            let identifier = UIDevice.current.name
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
            
            let power = numberFormatter.number(from: powerTextField.text!)
            
            beaconTransmitter.startAdvertising(beaconRegion, power: power)
            defaults.set(true, forKey: "kAdvertiseStatus")
        } else {
            defaults.set(false, forKey: "kAdvertiseStatus")
            beaconTransmitter.stopAdvertising()
            dismissKeyboard()
        }
    }
    
    fileprivate func canBeginAdvertise() -> Bool {
        if !isBluetoothPowerOn {
            showAlert("You must have Bluetooth powered on to advertise!")
            return false
        }
        if uuidTextField.text!.isEmpty || majorTextField.text!.isEmpty
            || minorTextField.text!.isEmpty
          //  || powerTextField.text!.isEmpty
        {
            showAlert("You must complete all fields")
            return false
        }
        return true
    }
    
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: UITextFieldDelegate methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        helpTextView.text = ""

        if textField == uuidTextField && !textField.text!.isEmpty {
            print (textField.text!)
            defaults.set(textField.text!, forKey: kUUIDKey)
        }
        else if textField == majorTextField && !textField.text!.isEmpty {
            if isMajorOrMinorEntryValid(textField.text!) {
            defaults.set(textField.text, forKey: kMajorIdKey)
            }
        }
        else if textField == minorTextField && !textField.text!.isEmpty {
            if isMajorOrMinorEntryValid(textField.text!) {
                defaults.set(textField.text, forKey: kMinorIdKey)
            }
        }
        else if textField == powerTextField && !textField.text!.isEmpty {
            // power values are typically negative
            let value = numberFormatter.number(from: powerTextField.text!)
            if (value?.int32Value > 0) {
                let base: NSDecimalNumber = 0.0;
                if let theValue: NSDecimalNumber = value as? NSDecimalNumber {
                    let powerStrengthValue: NSDecimalNumber = base.subtracting(theValue);
                    let calibratedString: String = powerStrengthValue.stringValue
                    powerTextField.text = calibratedString;
                }
            }
            defaults.set(textField.text, forKey: kPowerKey)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    fileprivate func initFromDefaultValues() {

        if let uuid = defaults.string(forKey: kUUIDKey) {
            uuidTextField.text = uuid
        }
        if let major = defaults.string(forKey: kMajorIdKey) {
            majorTextField.text = major
        }
        if let minor = defaults.string(forKey: kMinorIdKey) {
            minorTextField.text = minor
        }
        
        advertiseSwitch.isOn = advertise
    }
    
    
    
    //MARK:
    //MARK: BeaconTransmitterDelegate
    
    func didPowerOn() {
        isBluetoothPowerOn = true
    }
    
    func didPowerOff() {
        isBluetoothPowerOn = false
    }
    
    func isMajorOrMinorEntryValid(_ theValue: String) -> Bool {
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

func onError(_ error: NSError) {
    
}

func showAlert(_ message: String) {
    let alertController = UIAlertController(title:"iBeaconApp", message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alertController, animated: true, completion: nil)
}


}
