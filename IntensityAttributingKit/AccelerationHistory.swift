//
//  AccelerationHistory.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/14/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation
import CoreMotion


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


/*
class MotionHistory {
    
    //static let singleton = ZMotionHistory()
    
    private(set) var motionManager:CMMotionManager
    private(set) var motionQueue:NSOperationQueue
    private(set) var motionSerialQueue:dispatch_queue_t
    let maxSamples:Int
    let samplesPerSecond:Double
    
    typealias TimestampedAcceleration = (CMAcceleration,NSTimeInterval)
    
    private var accelHistory:[TimestampedAcceleration]
    private var shift:Int
    private var valuesRecorded:Int = 0
    
    
    
    init(maxSamples:Int, samplesPerSecond:Double){
        motionManager = CMMotionManager()
        self.samplesPerSecond = samplesPerSecond
        motionManager.deviceMotionUpdateInterval = 1.0 / samplesPerSecond
        motionSerialQueue = dispatch_queue_create("motionQueue_t", DISPATCH_QUEUE_SERIAL)
        motionQueue = NSOperationQueue()
        motionQueue.name = "motionQueue"
        motionQueue.underlyingQueue = motionSerialQueue
        self.maxSamples = maxSamples
        accelHistory = Array<TimestampedAcceleration>(count:maxSamples,repeatedValue:(CMAcceleration(x: 0.0, y: 0.0, z: 0.0),0.0))
        shift = maxSamples - 1
    }
    
    func startCollecting(){
        motionManager.startDeviceMotionUpdatesToQueue(motionQueue) { (motion, error) -> Void in
            guard let userAccel = motion?.userAcceleration else {return}
            if (self.shift == 0) { self.shift = self.maxSamples - 1} else { self.shift-- }
            self.accelHistory[self.shift] = (userAccel,motion!.timestamp)
        }
    }
    
    func stopCollectingWithoutResults(){
        motionManager.stopDeviceMotionUpdates()
        motionQueue.addOperationWithBlock { () -> Void in
            self.valuesRecorded = 0
        }
    }
    
    func stopCollectingWithResults()->[CMDeviceMotion]{
        motionManager.stopDeviceMotionUpdates()
        
    }
    
    
    func getRawAccelHistory()->[TimestampedAcceleration]{
        motionQueue.waitUntilAllOperationsAreFinished()
        guard self.valuesRecorded > 0 else {return []}
        var arr = [TimestampedAcceleration]()
        arr.reserveCapacity(self.valuesRecorded)
        if self.valuesRecorded + self.shift > self.accelHistory.count {
            arr.appendContentsOf(self.accelHistory[self.shift..<self.accelHistory.count])
            let lastSegEnd = min(self.shift, self.accelHistory.count - self.shift)
            arr.appendContentsOf(self.accelHistory[0..<self.shift])
        } else if self.valuesRecorded + self.shift == self.accelHistory.count {
            arr.appendContentsOf(self.accelHistory[self.shift..<self.accelHistory.count])
        } else {
            arr.appendContentsOf(self.accelHistory[self.shift..<(self.shift + self.valuesRecorded)])
        }
        
        
        
        return arr
    }
    
    
    
}
*/
