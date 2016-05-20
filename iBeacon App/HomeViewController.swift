//
//  HomeViewController.swift
//  iBeacon App
//
//  Created by Randy McLain on 5/12/16.
//  Copyright © 2016 Randy McLain. All rights reserved.
//

import UIKit
import CoreBluetooth

class HomeViewController : UIViewController, CBCentralManagerDelegate {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var stateLabel: UILabel!
  @IBOutlet weak var regoinMonitorButton: UIButton!
  @IBOutlet weak var iBeaconButton: UIButton!
  
  var centralManager: CBCentralManager!
    var isBluetoothPoweredOn : Bool {
        var state: Bool
        switch (centralManager.state) {
        case .PoweredOn:
            state = true
            break
        case .PoweredOff:
            state = false
            break
        default:
            state = false
            break
        }
        return state 
    }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /*
     The central manager is initialized with self as the delegate so the view controller will receive any central role events. By specifying the queue as nil, the central manager dispatches central role events using the main queue. The central manager starts up after this call is made and begins dispatching events.
    */
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }


  @IBAction func regoinMonitorPressed(sender: AnyObject) {
    
    
  }

  @IBAction func iBeaconPressed(sender: AnyObject) {
    
    
  }
  
  private func showAlertForSettings() {
    let alertController = UIAlertController(title: "iBeacon App", message: "Turn On Bluetooth!", preferredStyle: .Alert)
    
    let cancelAction = UIAlertAction(title: "Settings", style: .Cancel) { (action) in
      if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
        UIApplication.sharedApplication().openURL(url)
      }
    }
    alertController.addAction(cancelAction)
    
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alertController.addAction(okAction)
    
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  //MARK:
  //MARK: Core BlueTooth Delegate
  
  /*
   the PoweredOn state indicates that the central device supports Bluetooth LE and the Bluetooth is on and available for use. The PoweredOff state indicates that Bluetooth is either turned off or the device doesn’t support Bluetooth LE.
  */
  func centralManagerDidUpdateState(central: CBCentralManager) {
    switch (isBluetoothPoweredOn) {
    case true:
      stateLabel.text = "Bluetooth ON"
      stateLabel.textColor = UIColor.greenColor()
    case false:
      stateLabel.text = "Bluetooth OFF"
      stateLabel.textColor = UIColor.redColor()
    default:
      break
    }
    
  }
  
  
  /*
   When a segue is initiated, this method will be called with the string value that identifies the triggered segue and the object that initiated the segue. The return value for this method should be true if you want the segue to be executed; otherwise, return false.
   In this method you’re only interested in the identifier; the sender object is for informational purposes and can be ignored here. Compare the identifier value with the constants you defined earlier. If you find a match, then check the Bluetooth state. If Bluetooth is powered on, you can allow the segue to execute by returning a value of true.
   In the case in which Bluetooth is powered off, you want to display an alert and provide an option to go to the Settings app where the Bluetooth setting can be changed.
  */
  override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
    if identifier == "RegionMonitorSegue" || identifier == "iBeaconSegue" || identifier == "ConfigureSegue" {
      if !isBluetoothPoweredOn {
        showAlertForSettings()
        return false;
      }
    }
    return true
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}

