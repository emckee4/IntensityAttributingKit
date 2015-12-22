//
//  ForceIntensityMappingFunctions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/7/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation


public struct ForceIntensityMappingFunctions {
    
    public struct Linear {
        ///returns max(forceHistory) /
        public static func maxForce(raw:RawIntensity)->Float{
            return (raw.forceHistory.maxElement() ?? 0.0) / raw.maximumPossibleForce
        }
        
        ///average not including first value
        public static func averageForce(raw:RawIntensity)->Float{
            let count = raw.forceHistory.count
            return (raw.forceHistory[1..<count].reduce(0.0, combine: +) / Float(count - 1)) / raw.maximumPossibleForce
        }
        
        ///Average discarding first value. If the history is of length greater than ten then this only uses the ten most recent values. The interval over which 10 sequential touch events (within the same touch) occur seems to typically work out to a little less than 0.15 seconds in testing.
        public static func averageLastTen(raw:RawIntensity)->Float{
            let count = raw.forceHistory.count
            guard count > 1 else {return 0.0}
            if count < 10 {
                return (raw.forceHistory[1..<count].reduce(0.0, combine: +) / Float(count - 1)) / raw.maximumPossibleForce
            } else {
                return (raw.forceHistory[(count - 10)..<count].reduce(0.0, combine: +) / Float(10)) / raw.maximumPossibleForce
            }
        }
        
        ///Similar to averageLastTen except it removes the high and low values in the last 10
        public static func smoothedAverageLastTen(raw:RawIntensity)->Float{
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
    public struct Duration {
        public static var timeToFull:NSTimeInterval = 0.5
        
        public static func eventCount(raw:RawIntensity)->Float{
            return min(Float(raw.forceHistory.count) / 100.0, 1.0)
        }
        
        public static func linearScaleToConstant(raw:RawIntensity)->Float{
            guard raw.startTime != nil && Duration.timeToFull != 0.0 else {return 0.0}
            return min( Float(NSDate().timeIntervalSinceDate(raw.startTime) / Duration.timeToFull)  , 1.0)
        }
        
        
    }
    
    public enum AvailableFunctions:String {
        case SmoothedAverageLastTen = "SmoothedAverageLastTen"
        case MaxForce = "MaxForce"
        case AverageLastTenForce = "AverageLastTenForce"
        
        case DurationLinearScaleToConstant = "DurationLinearScaleToConstant"
        
        static var allAvailableNames:[String] {
            return availableDurationOnlyNames + availableForceOnlyNames
        }
        
        static var availableDurationOnlyNames:[String] {
            return ["DurationLinearScaleToConstant"]
        }
        
        static var availableForceOnlyNames:[String] {
            return ["SmoothedAverageLastTen","MaxForce","DurationLinearScaleToConstant"]
        }
        
        var namedFunction:(raw:RawIntensity)->Float {
            switch self {
            case .SmoothedAverageLastTen: return Linear.smoothedAverageLastTen
            case .MaxForce: return Linear.maxForce
            case .AverageLastTenForce: return Linear.averageLastTen
                
            case .DurationLinearScaleToConstant: return Duration.linearScaleToConstant
            }
        }
    }
}

