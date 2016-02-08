//
//  RawIntensity.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/1/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation


public struct RawIntensity {
    ///raw force value
    var forceHistory:[Float]
    ///As far as I can tell this is constant on a device and may well be 6.667 across all devices.
    var maximumPossibleForce:Float
    
    ///returns the intensity value for this RawIntensity object as determined using the global static var forceIntensityMapping(RawIntensity)
    var intensity:Int {
        return Int(RawIntensity.forceIntensityMapping(raw: self) * 100)
    }
    var startTime:NSDate!
    
    var avgPressure:Float {
        let count = forceHistory.count
        guard count > 1 else {return 0.0}
        if count < 10 {
            return (forceHistory[1..<count].reduce(0.0, combine: +) / Float(count - 1)) / self.maximumPossibleForce
        } else {
            return (forceHistory[(count - 10)..<count].reduce(0.0, combine: +) / Float(10)) / self.maximumPossibleForce
        }
        
    }
    
    var peakPressure:Float {
        return (forceHistory.maxElement() ?? 0.0) / self.maximumPossibleForce
    }
    
    mutating func reset(withValue:CGFloat = 0.0){
        forceHistory = [Float(withValue)]
        startTime = NSDate()
    }
    
    mutating func append(value:CGFloat){
        forceHistory.append(Float(value))
    }
    mutating func append(value:Float){
        forceHistory.append(value)
    }
    
    init(withValue:CGFloat, maximumPossibleForce:CGFloat = RawIntensity.maximumPossibleForceForDevice){
        forceHistory = [Float(withValue)]
        self.maximumPossibleForce = Float(maximumPossibleForce)
        startTime = NSDate()
    }
    
    init(withFloatValue float:Float = 0.0, maximumPossibleForce:Float = Float(RawIntensity.maximumPossibleForceForDevice)){
        forceHistory = [float]
        self.maximumPossibleForce = maximumPossibleForce
        startTime = NSDate()
    }
    
    ///As far as I can tell maximumPossibleForce is constant across the device
    static var maximumPossibleForceForDevice:CGFloat = 6.667
    
    
    ///Global mapping function between Force and intensity value
    public static var forceIntensityMapping:(raw:RawIntensity)->Float = ForceIntensityMappingFunctions.Linear.smoothedAverageLastTen
    

}






