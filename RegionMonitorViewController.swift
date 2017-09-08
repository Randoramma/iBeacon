//
//  RegionMonitorViewController.swift
//  iBeacon App
//
//  Created by Randy McLain on 5/12/16.
//  Copyright © 2016 Randy McLain. All rights reserved.
//

import UIKit
import CoreLocation


class RegionMonitorViewController : UIViewController, UITextFieldDelegate, RegionMonitorDelegate {
    
    @IBOutlet weak var regionIDLabel: UILabel!
    @IBOutlet weak var uuidTextField: UITextField!
    
    
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var proximityLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var minorTextField: UITextField!
    @IBOutlet weak var monitorButton: UIButton!
    @IBOutlet weak var backBarButon: UIBarButtonItem!
    
    let kUUIDKey = "monitor-proximityUUID"
    let kMajorIdKey = "monitor-transmit-majorId"
    let kMinorIdKey = "monitor-transmit-minorId"
    let kMonitoringStatus = "kMonitoringStatus"
    var isMonitoring: Bool = false
    var regionMonitor: RegionMonitor!
    var doneButton: UIBarButtonItem!
    var defaults = UserDefaults.standard
    /*
     Unsure how this value was derived vvv
     */
    let uuidDefault = "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"
    let distanceFormatter = LengthFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uuidTextField.delegate = self
        majorTextField.delegate = self
        minorTextField.delegate = self
        regionMonitor = RegionMonitor(delegate: self)
        isMonitoring = defaults.bool(forKey: kMonitoringStatus)
        
        
        doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(RegionMonitorViewController.dismissKeyboard))
        initFromDefaultValues()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegionMonitorViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        UserDefaults.standard.synchronize()
    }
    
    
    /*
     The onBackgroundLocationAccessDisabled delegate method is called after RegionMonitor invokes CLLocationManager.authorizationStatus and receives a return value of Restricted, Denied, or AuthorizedWhenInUse. The delegate should respond to this notification by prompting the user to change his location access settings.
     
     
     
     */
    func onBackgroundLocationAccessDisabled() {
        let alertController = UIAlertController(title: NSLocalizedString("regmon.alert.title.location-access-disabled", comment: "foo"),
                                                message: NSLocalizedString("regmon.alert.message.location-access-disabled", comment: "foo"),
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel",
            style: .cancel,
            handler: nil))
        alertController.addAction(UIAlertAction(title: "Settings",
            style: .cancel,
            handler: { (action) in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url)
                }
        })
        )
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleMonitoring() {
        if (isMonitoring) {
            regionMonitor.stopMonitoring()
        } else {
            if uuidTextField.text!.isEmpty {
                showAlert("Please enter a valid UUID")
                return
            }
            
            regionIDLabel.text = ""
            proximityLabel.text = ""
            distanceLabel.text = ""
            rssiLabel.text = ""
            
            if let uuid = UUID(uuidString: uuidTextField.text!) {
                let identifier = "my.beacon"
                
                var beaconRegion: CLBeaconRegion?
                
                if let major = Int(majorTextField.text!) {
                    if let minor = Int(minorTextField.text!) {
                        beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor), identifier: identifier)
                    } else {
                        beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: CLBeaconMajorValue(major), identifier: identifier)
                    }
                } else {
                    beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: identifier)
                }
                
                // later, these values can be set from the UI
                beaconRegion!.notifyEntryStateOnDisplay = true
                beaconRegion!.notifyOnEntry = true
                beaconRegion!.notifyOnExit = true
                
                regionMonitor.startMonitoring(beaconRegion)
            } else {
                showAlert("Please enter a valid UUID")
            }
        }
    }
    
    
    //MARK:
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if (textField == uuidTextField && !textField.text!.isEmpty) {
            defaults.set(textField.text, forKey: kUUIDKey)
        }
        else if (textField == majorTextField && !textField.text!.isEmpty) {
            if isMajorOrMinorEntryValid(textField.text!) {
                defaults.set(textField.text, forKey: kMajorIdKey)
            }
        }
        else if (textField == minorTextField && !textField.text!.isEmpty) {
            if isMajorOrMinorEntryValid(textField.text!) {
                defaults.set(textField.text, forKey: kMinorIdKey)
            }
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
    
    
    
    //MARK:
    //MARK: RegionMonitorDelegate
    
    /*
     The didStartMonitoring delegate method is called when RegionMonitor receives the notification didStartMonitoringForRegion from CLLocationManager. The delegate can respond to this notification by updating its state and displaying a progress indicator.
     */
    func didStartMonitoring() {
        isMonitoring = true
        defaults.set(isMonitoring, forKey: kMonitoringStatus)
        monitorButton.rotate(0.0, toValue: CGFloat(M_PI * 2), completionDelegate: self)
        
    }
    
    /*
     The didStopMonitoring delegate method is called when the RegionMonitor.stopMonitoring method is called. The delegate can respond to this notification by updating its state.
     */
    func didStopMonitoring() {
        isMonitoring = false
        defaults.set(isMonitoring, forKey: kMonitoringStatus)
    }
    
    /*
     The didEnterRegion delegate method is called when RegionMonitor receives the notification didEnterRegion from CLLocationManager. The CLRegion object is passed as a parameter and is provided to the delegate. The delegate can respond to this notification by providing feedback to the user.
     */
    
    func didEnterRegion(_ region: CLRegion!) {
        print ("entered region")
    }
    
    /*
     The didExitRegion delegate method is called when RegionMonitor receives the notification didExitRegion from CLLocationManager. The CLRegion object is passed as a parameter and is provided to the delegate. The delegate can respond to this notification by providing feedback to the user.
     */
    
    func didExitRegion(_ region: CLRegion!) {
        print ("exited region")
    }
    
    /*
     The didRangeBeacon delegate method is called when RegionMonitor receives the notification didRangeBeacons from CLLocationManager. The RegionMonitor is passed an array of CLBeacon objects and determines which one is the closest. That CLBeacon object is provided to the delegate. The delegate can respond to this0 notification by providing feedback to the user.
     */
    
    func didRangeBeacon(_ beacon: CLBeacon!, region: CLRegion!) {
        
        regionIDLabel.text = region.identifier
        uuidTextField.text = beacon.proximityUUID.uuidString
        majorTextField.text = "\(beacon.major)"
        minorTextField.text = "\(beacon.minor)"
        
        switch (beacon.proximity) {
        case CLProximity.far:
            proximityLabel.text = "Far"
        case CLProximity.near:
            proximityLabel.text = "Near"
        case CLProximity.immediate:
            proximityLabel.text = "Immediate"
        case CLProximity.unknown:
            proximityLabel.text = "unknown"
        }
        
        distanceLabel.text = distanceFormatter.string(fromMeters: beacon.accuracy)
        print(beacon.proximity.rawValue)
        rssiLabel.text = "\(beacon.rssi)"
        
    }
    
    /*
     The onError delegate method is called when RegionMonitor encounters an error. An NSError object is provided to the delegate. The delegate can respond to this notification by handling the error and/or providing feedback to the user. This notification is currently ignored by this example app.
     */
    func onError(_ error: NSError) {
        
    }
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title:"iBeaconApp", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if isMonitoring == true {
            // if still scanning, restart the animation
            monitorButton.rotate(0.0, toValue: CGFloat(M_PI * 2), completionDelegate: self)
        }
    }
    
    
}

extension UIView {
    
    func rotate(_ fromValue: CGFloat, toValue: CGFloat, duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = fromValue
        rotateAnimation.toValue = toValue
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate as! CAAnimationDelegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

