//
//  ViewController.swift
//  iBeacon App
//
//  Created by Randy McLain on 5/12/16.
//  Copyright © 2016 Randy McLain. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var stateLabel: UILabel!
  @IBOutlet weak var regoinMonitorButton: UIButton!
  @IBOutlet weak var iBeaconButton: UIButton!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func regoinMonitorPressed(sender: AnyObject) {
  }

  @IBAction func iBeaconPressed(sender: AnyObject) {
  }
  

}

