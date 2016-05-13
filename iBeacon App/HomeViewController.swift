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
  
  //MARK:
  //MARK: Core BlueTooth Delegate
  
  func centralManagerDidUpdateState(central: CBCentralManager) {
    
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}

