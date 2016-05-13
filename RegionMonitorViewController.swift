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
  
  @IBOutlet weak var proximityLabel: NSLayoutConstraint!
  @IBOutlet weak var majorTextField: UITextField!
  
  @IBOutlet weak var distanceLabel: UILabel!
  
  @IBOutlet weak var rssiLabel: UILabel!
  @IBOutlet weak var minorTextField: UITextField!
  @IBOutlet weak var monitorButton: UIButton!
  
  let kUUIDKey = "monitor-proximityUUID"
  let kMajorIdKey = "monitor-transmit-majorId"
  let kMinorIdKey = "monitor-transmit-minorId"
  
  let uuidDefault = "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"

  override func viewDidLoad() {
     super.viewDidLoad()
    uuidTextField.delegate = self
    majorTextField.delegate = self
    minorTextField.delegate = self
    doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "dismissKeyboard")
    initFromDefaultValues()
    
  }
  
  
  @IBAction func monitorButtonPressed(sender: AnyObject) {
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
  
}