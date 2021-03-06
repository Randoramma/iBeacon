//
//  RegionMonitor.swift
//  iBeacon App
//
//  Created by Randy McLain on 5/13/16.
//  Copyright © 2016 Randy McLain. All rights reserved.
//

import Foundation
import CoreLocation


protocol RegionMonitorDelegate: NSObjectProtocol {
  func onBackgroundLocationAccessDisabled()
  func didStartMonitoring()
  func didStopMonitoring()
  func didEnterRegion(_ region: CLRegion!)
  func didExitRegion(_ region: CLRegion!)
  func didRangeBeacon(_ beacon: CLBeacon!, region: CLRegion!)
  func onError(_ error: NSError)
  
}


class RegionMonitor: NSObject, CLLocationManagerDelegate {
  
  /*
   You’ll want to store a strong reference to the CLLocationManager, but you must make sure that you declare the delegate property for RegionMonitorDelegate as weak to avoid a strong reference cycle. A strong reference cycle will prevent RegionMonitorDelegate from being deallocated, which will cause a memory leak in your application. Also, a weak reference is allowed to have “no value,” so it must be declared an optional type.
   */
  weak var delegate: RegionMonitorDelegate?
  var locationManager: CLLocationManager!
  var beaconRegion: CLBeaconRegion?
  var rangedRegion: CLBeacon! = CLBeacon()
  var pendingMonitorRequest: Bool = false
  
  var count : Int = 0
  
  
  init(delegate: RegionMonitorDelegate) {
    super.init()
    self.delegate = delegate
    self.locationManager = CLLocationManager()
    self.locationManager!.delegate = self
    
  }
  
  /*
   Upon entering, the property pendingMonitorRequest is set, signaling that a start monitoring request has been made. In the event that the request to start monitoring is deferred, this value will be used in a notification to determine whether startMonitoringForRegion should be called. Also, a strong reference to the beaconRegion is held so that it can be used by the delegate methods.
   */
  
  func startMonitoring(_ beaconRegion: CLBeaconRegion?) {
    print("Start monitoring")
    pendingMonitorRequest = true
    self.beaconRegion = beaconRegion
    
    switch CLLocationManager.authorizationStatus() {
    case .notDetermined:
      locationManager.requestAlwaysAuthorization()
    case .restricted, .denied, .authorizedWhenInUse:
      delegate?.onBackgroundLocationAccessDisabled()
    case .authorizedAlways:
      locationManager!.startMonitoring(for: beaconRegion!)
      pendingMonitorRequest = false
    }
  }
  
  
  /*
   In this method, location manager is told to stop ranging and monitoring beacons and to stop updating location. The delegate is also notified that monitoring has now stopped.
   */
  func stopMonitoring() {
    print("Stop monitoring")
    pendingMonitorRequest = false
    if let theBeacon = beaconRegion {
        locationManager.stopRangingBeacons(in: theBeacon)
        locationManager.stopMonitoring(for: theBeacon)
    }
    locationManager.stopUpdatingLocation()
    beaconRegion = nil
    delegate?.didStopMonitoring()
  }
  
  //MARK:
  //MARK: CLLocationManager Delegate
  
  /*
   The location manager calls this delegate method when the authorization status for the application has changed. Consider the use case where a user taps a button to start monitoring but has not yet granted the application permission to access location services.
   */
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    print("didChangeAuthorizationStatus \(status)")
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      if pendingMonitorRequest {
        locationManager!.startMonitoring(for: beaconRegion!)
        pendingMonitorRequest = false
      }
      locationManager!.startUpdatingLocation()
    }
  }
  
  /*
   The location manager calls this delegate method after startMonitoringForRegion has been called, and when a new region is being monitored. The Region Monitor notifies its delegate by calling didStartMonitoring so a progress indicator can be presented to the user at the right time. At this point, the Region Monitor can ask the location manager about the new region’s state by calling requestStateForRegion with the new region object passed as a parameter.
   */
  func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    print("didStartMonitoringForRegion \(region.identifier)")
    delegate?.didStartMonitoring()
    locationManager.requestState(for: region)
  }
  
  /*
   The location manager calls this delegate method in response to a call to its requestStateForRegion method. The region along with its state is passed in as a parameter. The state contains a value of the CLRegionState type. The values reflect the relationship between the device and the region boundaries. The Region Monitor uses these values to determine which location manager method to call. If the device is inside the given region, then startRangingBeaconsInRegion is called; otherwise stopRangingBeaconsInRegion is called. The property beaconRegion that was set in the call to startMonitoring is passed in as a parameter.
   */
  func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
    print("didDetermineState")
    if state == CLRegionState.inside {
      print(" - entered region \(region.identifier)")
      locationManager.startRangingBeacons(in: beaconRegion!)
    } else {
      print(" - exited region \(region.identifier)")
      locationManager.stopRangingBeacons(in: beaconRegion!)
    }
  }
  
  /*
   The location manager calls this delegate method when the user enters the specified region. The Region Monitor notifies its delegate by calling didEnterRegion and passes the region object containing information about the region that was entered.
   */
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    print("didEnterRegion - \(region.identifier)")
    delegate?.didEnterRegion(region)
  }
  
  /*
 The location manager calls this delegate method when the user exits the specified region. The Region Monitor notifies its delegate by calling didExitRegion and passes the region object containing information about the region that was exited.
 
 */
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    print("didExitRegion - \(region.identifier)")
    delegate?.didExitRegion(region)
  }
  
  /*
 The location manager calls this delegate method when one or more beacons become available in the specified region, or when a beacon goes out of range. This method is also called when the range of a beacon changes (i.e., getting closer or farther). The implementation here only notifies the Region Monitor’s delegate with the closest beacon.
 
 */
  func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    count += 1
    print("didRangeBeacons - \(region.identifier) with count = \(count)")
    
    if beacons.count > 0 {
      let rangedBeacon = beacons[0]
      delegate?.didRangeBeacon(rangedBeacon, region: region)
    }
  }
  
  
  /*
 The location manager calls this delegate method when region monitoring has failed. It passes in the region for which the error occurred and an NSError describing the error. Implementation of this method is optional but recommended.
 */
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("monitoringDidFailForRegion - \(error)")
  }
  
  /*
 The location manager calls this delegate method when registering a beacon region failed. If you receive this message, check to make sure the region object itself is valid and contains valid data.
 */
  func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
    print("rangingBeaconsDidFailForRegion \(error)")
  }
  
  /*
  If the user denies your application’s use of the location service, this method reports a Denied error. If you receive this error, you should stop the location service. Implementation of this method is optional but recommended.
  */
  func locationManager(_ manager: CLLocationManager, didFailWithError error: CLError) {
    print("didFailWithError \(error)")
//    if (error == CLError.Code.denied.rawValue) {
//      stopMonitoring()
//    }
    if (error.errorCode == CLError.denied.rawValue) {
        stopMonitoring()
    }
  }
  
  
}
