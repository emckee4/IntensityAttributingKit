//
//  IALocationManagerDelegateShim.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/30/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation
import CoreLocation

/** Shim class used to get call backs from the shared location manager without disrupting the original delegate's functionality. This will always forward calls to the corresponding method of the previousDelegate and will also do the same for a few methods of the currentDelegate.
 */
class IALocationManagerDelegateShim:NSObject, CLLocationManagerDelegate {
    
    var previousDelegate:CLLocationManagerDelegate?
    weak var currentDelegate:CLLocationManagerDelegate?
    
    //Responding to Location Events
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        previousDelegate?.locationManager?(manager, didUpdateLocations: locations)
        currentDelegate?.locationManager?(manager, didUpdateLocations: locations)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        previousDelegate?.locationManager?(manager, didFailWithError: error)
        currentDelegate?.locationManager?(manager, didFailWithError: error)
    }
    
    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        previousDelegate?.locationManager?(manager, didFinishDeferredUpdatesWithError: error)
    }
    
    //Pausing Location Updates
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
        previousDelegate?.locationManagerDidPauseLocationUpdates?(manager)
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager) {
        previousDelegate?.locationManagerDidResumeLocationUpdates?(manager)
    }
    //Responding to Heading Events
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        previousDelegate?.locationManager?(manager, didUpdateHeading: newHeading)
    }
    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
        return previousDelegate?.locationManagerShouldDisplayHeadingCalibration?(manager) ?? false
    }
    //Responding to Region Events
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        previousDelegate?.locationManager?(manager, didEnterRegion: region)
    }
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        previousDelegate?.locationManager?(manager, didExitRegion: region)
    }
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        previousDelegate?.locationManager?(manager, didDetermineState: state, forRegion: region)
    }
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        previousDelegate?.locationManager?(manager, monitoringDidFailForRegion: region, withError: error)
    }
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        previousDelegate?.locationManager?(manager, didStartMonitoringForRegion: region)
    }
    //Responding to Ranging Events
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        previousDelegate?.locationManager?(manager, didRangeBeacons: beacons, inRegion: region)
    }
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        previousDelegate?.locationManager?(manager, rangingBeaconsDidFailForRegion: region, withError: error)
    }
    //Responding to Visit Events
    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
        previousDelegate?.locationManager?(manager, didVisit: visit)
    }
    //Responding to Authorization Changes
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        previousDelegate?.locationManager?(manager, didChangeAuthorizationStatus: status)
        currentDelegate?.locationManager?(manager, didChangeAuthorizationStatus: status)
    }
    
    
}
