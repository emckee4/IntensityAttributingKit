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
    
    private(set) var motionManager:CMMotionManager
    private(set) var motionQueue:NSOperationQueue
    private(set) var motionSerialQueue:dispatch_queue_t
    
    let samplesPerSecond:Double
    
    private var _maxAbsZ:Double = 0.0
    ///Thread safe getter
    var maxAbsZ:Double {
        motionQueue.waitUntilAllOperationsAreFinished()
        return _maxAbsZ
    }
    
    
    init(samplesPerSecond:Double){
        motionManager = CMMotionManager()
        self.samplesPerSecond = samplesPerSecond
        motionManager.deviceMotionUpdateInterval = 1.0 / samplesPerSecond
        motionSerialQueue = dispatch_queue_create("motionQueue_t", DISPATCH_QUEUE_SERIAL)
        motionQueue = NSOperationQueue()
        motionQueue.name = "motionQueue"
        motionQueue.underlyingQueue = motionSerialQueue
        //startListeningToNotifications()
    }
    
    func resetMaxAbsZ(){
        if let latestZ = motionManager.deviceMotion?.userAcceleration.z {
            motionQueue.addOperationWithBlock({ () -> Void in
                self._maxAbsZ = abs(latestZ)
            })
        } else {
            motionQueue.addOperationWithBlock({ () -> Void in
                self._maxAbsZ = 0.0
            })
        }        
    }
    
    func startCollecting(){
        guard motionManager.deviceMotionActive == false else {return}
        motionManager.startDeviceMotionUpdatesToQueue(motionQueue) { (motion, error) -> Void in
            guard let zAccel = motion?.userAcceleration.z else {return}
            self._maxAbsZ = max(self._maxAbsZ, abs(zAccel))
        }
    }
    
    func stopCollecting(){
        motionManager.stopDeviceMotionUpdates()
    }
    
}
