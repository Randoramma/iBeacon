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
  
  @IBOutlet weak var proximityLabel: UILabel!
  @IBOutlet weak var majorTextField: UITextField!
  
  @IBOutlet weak var distanceLabel: UILabel!
  
  @IBOutlet weak var rssiLabel: UILabel!
  @IBOutlet weak var minorTextField: UITextField!
  @IBOutlet weak var monitorButton: UIButton!
  
  let kUUIDKey = "monitor-proximityUUID"
  let kMajorIdKey = "monitor-transmit-majorId"
  let kMinorIdKey = "monitor-transmit-minorId"
  var isMonitoring: Bool
  var regionMonitor: RegionMonitor!
  var doneButton: UIBarButtonItem!
  /*
  Unsure how this value was derived vvv
  */
  let uuidDefault = "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"
  let distanceFormatter = NSLengthFormatter()
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    uuidTextField.delegate = self
    majorTextField.delegate = self
    minorTextField.delegate = self
    regionMonitor = RegionMonitor(delegate: self)
    doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(RegionMonitorViewController.dismissKeyboard))
    initFromDefaultValues()
    
  }
  
  
  @IBAction func monitorButtonPressed(sender: AnyObject) {
    
  }
  
  func onBackgroundLocationAccessDisabled() {
    let alertController = UIAlertController(title: NSLocalizedString("regmon.alert.title.location-access-disabled", comment: "foo"),
                                            message: NSLocalizedString("regmon.alert.message.location-access-disabled", comment: "foo"),
                                            preferredStyle: .Alert)
    
    alertController.addAction(UIAlertAction(title: "Cancel",
      style: .Cancel,
      handler: nil))
    alertController.addAction(UIAlertAction(title: "Settings",
      style: .Cancel,
      handler: { (action) in
        if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
          UIApplication.sharedApplication().openURL(url)
        }
    })
    )
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  @IBAction func toggleMonitoring() {
    if isMonitoring {
      regionMonitor.stopMonitoring()
    } else {
      if uuidTextField.text!.isEmpty {
        showAlert("Please provide a valid UUID")
        return
      }
      
      regionIDLabel.text = ""
      proximityLabel.text = ""
      distanceLabel.text = ""
      rssiLabel.text = ""
      
      if let uuid = NSUUID(UUIDString: uuidTextField.text!) {
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
        let alertController = UIAlertController(title:"iBeaconApp", message: "Please enter a valid UUID", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
      }
    }
  }

  
  //MARK:
  //MARK: UITextFieldDelegate
  
  func textFieldDidBeginEditing(textField: UITextField) {
    navigationItem.rightBarButtonItem = doneButton
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    if (textField == uuidTextField && !textField.text!.isEmpty) {
      defaults.setObject(textField.text, forKey: kUUIDKey)
    }
    else if (textField == majorTextField && !textField.text!.isEmpty) {
      defaults.setObject(textField.text, forKey: kMajorIdKey)
    }
    else if (textField == minorTextField && !textField.text!.isEmpty) {
      defaults.setObject(textField.text, forKey: kMinorIdKey)
    }
    
  }
  
  //MARK:
  //MARK: KeyboardDelegate
  
  func dismissKeyboard() {
    uuidTextField.resignFirstResponder()
    majorTextField.resignFirstResponder()
    minorTextField.resignFirstResponder()
    navigationItem.rightBarButtonItem = nil
    
  }
  
  private func initFromDefaultValues() {
    let defaults = NSUserDefaults.standardUserDefaults()
    if let uuid = defaults.stringForKey(kUUIDKey) {
      uuidTextField.text = uuid
    }
    if let major = defaults.stringForKey(kMajorIdKey) {
      majorTextField.text = major
    }
    if let minor = defaults.stringForKey(kMinorIdKey) {
      minorTextField.text = minor
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  //MARK:
  //MARK: RegionMonitorDelegate
  
  /*
   The didStartMonitoring delegate method is called when RegionMonitor receives the notification didStartMonitoringForRegion from CLLocationManager. The delegate can respond to this notification by updating its state and displaying a progress indicator.
   */
  func didStartMonitoring() {
    isMonitoring = true
    monitorButton.rotate(0.0, toValue: CGFloat(M_PI * 2), completionDelegate: self)
    
  }
  
  /*
   The didStopMonitoring delegate method is called when the RegionMonitor.stopMonitoring method is called. The delegate can respond to this notification by updating its state.
   */
  func didStopMonitoring() {
    isMonitoring = false
  }
  
  /*
   The didEnterRegion delegate method is called when RegionMonitor receives the notification didEnterRegion from CLLocationManager. The CLRegion object is passed as a parameter and is provided to the delegate. The delegate can respond to this notification by providing feedback to the user.
   */
  
  func didEnterRegion(region: CLRegion!) {
    
  }
  
  /*
   The didExitRegion delegate method is called when RegionMonitor receives the notification didExitRegion from CLLocationManager. The CLRegion object is passed as a parameter and is provided to the delegate. The delegate can respond to this notification by providing feedback to the user.
   */
  
  func didExitRegion(region: CLRegion!) {
    
  }
  
  /*
   The didRangeBeacon delegate method is called when RegionMonitor receives the notification didRangeBeacons from CLLocationManager. The RegionMonitor is passed an array of CLBeacon objects and determines which one is the closest. That CLBeacon object is provided to the delegate. The delegate can respond to this0 notification by providing feedback to the user.
   */
  
  func didRangeBeacon(beacon: CLBeacon!, region: CLRegion!) {
    
    regionIDLabel.text = region.identifier
    uuidTextField.text = beacon.proximityUUID.UUIDString
    majorTextField.text = "\(beacon.major)"
    minorTextField.text = "\(beacon.minor)"
    
    switch (beacon.proximity) {
    case CLProximity.Far:
      proximityLabel.text = "Far"
    case CLProximity.Near:
      proximityLabel.text = "Near"
    case CLProximity.Immediate:
      proximityLabel.text = "Immediate"
    case CLProximity.Unknown:
      proximityLabel.text = "unknown"
    }
    
    distanceLabel.text = distanceFormatter.stringFromMeters(beacon.accuracy)
    
    rssiLabel.text = "\(beacon.rssi)"
    
  }
  
  /*
   The onError delegate method is called when RegionMonitor encounters an error. An NSError object is provided to the delegate. The delegate can respond to this notification by handling the error and/or providing feedback to the user. This notification is currently ignored by this example app.
   */
  func onError(error: NSError) {
    
  }
  
  
}

extension UIView {
  
  func rotate(fromValue: CGFloat, toValue: CGFloat, duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
    
    let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
    rotateAnimation.fromValue = fromValue
    rotateAnimation.toValue = toValue
    rotateAnimation.duration = duration
    
    if let delegate: AnyObject = completionDelegate {
      rotateAnimation.delegate = delegate
    }
    self.layer.addAnimation(rotateAnimation, forKey: nil)
  }
}

