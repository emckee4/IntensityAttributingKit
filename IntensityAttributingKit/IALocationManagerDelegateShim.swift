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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        previousDelegate?.locationManager?(manager, didUpdateLocations: locations)
        currentDelegate?.locationManager?(manager, didUpdateLocations: locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        previousDelegate?.locationManager?(manager, didFailWithError: error)
        currentDelegate?.locationManager?(manager, didFailWithError: error)
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        previousDelegate?.locationManager?(manager, didFinishDeferredUpdatesWithError: error)
    }
    
    //Pausing Location Updates
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        previousDelegate?.locationManagerDidPauseLocationUpdates?(manager)
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        previousDelegate?.locationManagerDidResumeLocationUpdates?(manager)
    }
    //Responding to Heading Events
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        previousDelegate?.locationManager?(manager, didUpdateHeading: newHeading)
    }
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return previousDelegate?.locationManagerShouldDisplayHeadingCalibration?(manager) ?? false
    }
    //Responding to Region Events
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        previousDelegate?.locationManager?(manager, didEnterRegion: region)
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        previousDelegate?.locationManager?(manager, didExitRegion: region)
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        previousDelegate?.locationManager?(manager, didDetermineState: state, for: region)
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        previousDelegate?.locationManager?(manager, monitoringDidFailFor: region, withError: error)
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        previousDelegate?.locationManager?(manager, didStartMonitoringFor: region)
    }
    //Responding to Ranging Events
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        previousDelegate?.locationManager?(manager, didRangeBeacons: beacons, in: region)
    }
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        previousDelegate?.locationManager?(manager, rangingBeaconsDidFailFor: region, withError: error)
    }
    //Responding to Visit Events
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        previousDelegate?.locationManager?(manager, didVisit: visit)
    }
    //Responding to Authorization Changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        previousDelegate?.locationManager?(manager, didChangeAuthorization: status)
        currentDelegate?.locationManager?(manager, didChangeAuthorization: status)
    }
    
    
}
