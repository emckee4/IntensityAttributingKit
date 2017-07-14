//
//  AccelerationHistory.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/14/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation
import CoreMotion

/**The AccelHistory class and its singleton are used to manage the accelerometer/accelleration data used by the DurationImpactTouchInterpreter.
*/
class AccelHistory {
    
    static let singleton = AccelHistory(samplesPerSecond: 100)
    
    fileprivate(set) var motionManager:CMMotionManager
    fileprivate(set) var motionQueue:OperationQueue
    fileprivate(set) var motionSerialQueue:DispatchQueue
    
    let samplesPerSecond:Double
    
    fileprivate var _maxAbsZ:Double = 0.0
    ///Thread safe getter
    var maxAbsZ:Double {
        motionQueue.waitUntilAllOperationsAreFinished()
        return _maxAbsZ
    }
    
    
    init(samplesPerSecond:Double){
        motionManager = CMMotionManager()
        self.samplesPerSecond = samplesPerSecond
        motionManager.deviceMotionUpdateInterval = 1.0 / samplesPerSecond
        motionSerialQueue = DispatchQueue(label: "motionQueue_t", attributes: [])
        motionQueue = OperationQueue()
        motionQueue.name = "motionQueue"
        motionQueue.underlyingQueue = motionSerialQueue
        //startListeningToNotifications()
    }
    
    func resetMaxAbsZ(){
        if let latestZ = motionManager.deviceMotion?.userAcceleration.z {
            motionQueue.addOperation({ () -> Void in
                self._maxAbsZ = abs(latestZ)
            })
        } else {
            motionQueue.addOperation({ () -> Void in
                self._maxAbsZ = 0.0
            })
        }        
    }
    
    func startCollecting(){
        guard motionManager.isDeviceMotionActive == false else {return}
        motionManager.startDeviceMotionUpdates(to: motionQueue) { (motion, error) -> Void in
            guard let zAccel = motion?.userAcceleration.z else {return}
            self._maxAbsZ = max(self._maxAbsZ, abs(zAccel))
        }
    }
    
    func stopCollecting(){
        motionManager.stopDeviceMotionUpdates()
    }
    
}
