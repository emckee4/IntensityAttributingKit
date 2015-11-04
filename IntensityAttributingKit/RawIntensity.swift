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
    var forceHistory:[CGFloat]
    ///As far as I can tell this is constant on a device and may well be 6.667 across all devices.
    var maximumPossibleForce:CGFloat
    
    ///returns the intensity value for this RawIntensity object as determined using the global static var forceIntensityMapping(RawIntensity)
    var intensity:Float {
        return RawIntensity.forceIntensityMapping(raw: self)
    }
    
    
    var avgPressure:Float {
        let count = forceHistory.count
        guard count > 1 else {return 0.0}
        if count < 10 {
            return Float((forceHistory[1..<count].reduce(0.0, combine: +) / CGFloat(count - 1)) / self.maximumPossibleForce)
        } else {
            return Float((forceHistory[(count - 10)..<count].reduce(0.0, combine: +) / CGFloat(10)) / self.maximumPossibleForce)
        }
        
    }
    
    var peakPressure:Float {
        return Float((forceHistory.maxElement() ?? 0.0) / self.maximumPossibleForce)
    }
    
    mutating func reset(withValue:CGFloat = 0.0){
        forceHistory = [withValue]
    }
    
    mutating func append(value:CGFloat){
        forceHistory.append(value)
    }
    
    
    init(withValue:CGFloat = 0.0, maximumPossibleForce:CGFloat = RawIntensity.maximumPossibleForceForDevice){
        forceHistory = [withValue]
        self.maximumPossibleForce = maximumPossibleForce
    }
    
    ///As far as I can tell maximumPossibleForce is constant across the device
    static var maximumPossibleForceForDevice:CGFloat = 6.667
    
    
    ///Global mapping function between Force and intensity value
    static var forceIntensityMapping:(raw:RawIntensity)->Float = ForceIntensityMappingFunctions.Linear.averageLastTen
    

    

    
    
    
}


struct ForceIntensityMappingFunctions {
    
    struct Linear {
        ///returns max(forceHistory) /
        static func maxForce(raw:RawIntensity)->Float{
            return Float((raw.forceHistory.maxElement() ?? 0.0) / raw.maximumPossibleForce)
        }
        
        ///average not including first value
        static func averageForce(raw:RawIntensity)->Float{
            let count = raw.forceHistory.count
            return Float((raw.forceHistory[1..<count].reduce(0.0, combine: +) / CGFloat(count - 1)) / raw.maximumPossibleForce)
        }
        
        ///average discarding first value. If the history is of length greater than ten then this only uses the ten most recent values.
        static func averageLastTen(raw:RawIntensity)->Float{
            let count = raw.forceHistory.count
            guard count > 1 else {return 0.0}
            if count < 10 {
                return Float((raw.forceHistory[1..<count].reduce(0.0, combine: +) / CGFloat(count - 1)) / raw.maximumPossibleForce)
            } else {
                return Float((raw.forceHistory[(count - 10)..<count].reduce(0.0, combine: +) / CGFloat(10)) / raw.maximumPossibleForce)
            }
        }
    }
}



