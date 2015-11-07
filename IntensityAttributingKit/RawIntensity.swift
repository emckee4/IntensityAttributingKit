//
//  RawIntensity.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/1/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation


struct RawIntensity {
    ///raw force value
    var forceHistory:[Float]
    ///As far as I can tell this is constant on a device and may well be 6.667 across all devices.
    var maximumPossibleForce:Float
    
    ///returns the intensity value for this RawIntensity object as determined using the global static var forceIntensityMapping(RawIntensity)
    var intensity:Float {
        return RawIntensity.forceIntensityMapping(raw: self)
    }
    
    
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
    }
    
    init(withFloatValue float:Float = 0.0, maximumPossibleForce:Float = Float(RawIntensity.maximumPossibleForceForDevice)){
        forceHistory = [float]
        self.maximumPossibleForce = maximumPossibleForce
    }
    
    ///As far as I can tell maximumPossibleForce is constant across the device
    static var maximumPossibleForceForDevice:CGFloat = 6.667
    
    
    ///Global mapping function between Force and intensity value
    static var forceIntensityMapping:(raw:RawIntensity)->Float = ForceIntensityMappingFunctions.Linear.smoothedAverageLastTen
    

    

    
    
    
}


struct ForceIntensityMappingFunctions {
    
    struct Linear {
        ///returns max(forceHistory) /
        static func maxForce(raw:RawIntensity)->Float{
            return (raw.forceHistory.maxElement() ?? 0.0) / raw.maximumPossibleForce
        }
        
        ///average not including first value
        static func averageForce(raw:RawIntensity)->Float{
            let count = raw.forceHistory.count
            return (raw.forceHistory[1..<count].reduce(0.0, combine: +) / Float(count - 1)) / raw.maximumPossibleForce
        }
        
        ///Average discarding first value. If the history is of length greater than ten then this only uses the ten most recent values. The interval over which 10 sequential touch events (within the same touch) occur seems to typically work out to a little less than 0.15 seconds in testing.
        static func averageLastTen(raw:RawIntensity)->Float{
            let count = raw.forceHistory.count
            guard count > 1 else {return 0.0}
            if count < 10 {
                return (raw.forceHistory[1..<count].reduce(0.0, combine: +) / Float(count - 1)) / raw.maximumPossibleForce
            } else {
                return (raw.forceHistory[(count - 10)..<count].reduce(0.0, combine: +) / Float(10)) / raw.maximumPossibleForce
            }
        }
        
        ///Similar to averageLastTen except it removes the high and low values in the last 10
        static func smoothedAverageLastTen(raw:RawIntensity)->Float{
            let count = raw.forceHistory.count
            guard count > 2 else {return raw.forceHistory.maxElement() ?? 0.0}
            var truncated:[Float]!
            if count < 10 {
                truncated = Array<Float>(raw.forceHistory[1..<count])
            } else {
                truncated = Array<Float>(raw.forceHistory[(count - 10)..<count])
            }
            
            truncated.sortInPlace()
            truncated.removeLast()
            truncated.removeFirst()
            
            return (truncated.reduce(0.0, combine: +) / Float(truncated.count)) / raw.maximumPossibleForce
        }

        
        
    }
    struct Duration {
        static func eventCount(raw:RawIntensity)->Float{
            return min(Float(raw.forceHistory.count) / 100.0, 1.0)
        }
        static func eventCountFast2(raw:RawIntensity)->Float{
            return min(Float(raw.forceHistory.count) / 50.0, 1.0)
        }


    }
}



