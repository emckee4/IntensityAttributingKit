//
//  TouchInterpreters.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/10/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


public enum IATouchInterpreter:String{
    case Duration = "Duration",
    Force = "Force"
    
    
    
    var newInstance:IATouchInterpretingProtocol! {
        switch self {
        case .Duration: return DurationTouchInterpreter()
        case .Force: return ForceTouchInterpreter()
        }
    }
    
    //var optionsForInterpreter:[String:AnyObject]{return [:]}
    
    
    
}


protocol IATouchInterpretingProtocol {
    mutating func updateIntensityYieldingRawResult(withTouch touch:UITouch)->Double
    mutating func endInteractionYieldingRawResult(withTouch touch:UITouch?)->Double
    mutating func cancelInteraction()
    var currentRawValue:Double! {get}
}


private struct ForceTouchInterpreter:IATouchInterpretingProtocol {
    
    static var ftOption:FTOptions = .SmoothedLastTen
    static var maximumPossibleForce:Double = 6.66667  //this should be determined by device type
    
    var history:[Double] = []
    var maxForce:Double = 0.0
    
    mutating func updateIntensityYieldingRawResult(withTouch touch:UITouch)->Double{
        switch ForceTouchInterpreter.ftOption {
        case .AvgLastTen:
            history.append(Double(touch.force))
            return avgLastTenPressure
        case .SmoothedLastTen:
            history.append(Double(touch.force))
            return smoothedLastTen
        case .PeakPressure:
            maxForce = max(maxForce, Double(touch.force))
            return peakScaledPressure
        }
    }
    
    mutating func endInteractionYieldingRawResult(withTouch touch:UITouch?)->Double{
        var result:Double!
        switch ForceTouchInterpreter.ftOption {
        case .AvgLastTen:
            if let touch = touch {
                history.append(Double(touch.force))
            }
            result = avgLastTenPressure
            history.removeAll()
        case .SmoothedLastTen:
            if let touch = touch {
                history.append(Double(touch.force))
            }
            result = smoothedLastTen
            history.removeAll()
        case .PeakPressure:
            if let touch = touch {
                maxForce = max(maxForce, Double(touch.force))
            }
            result = peakScaledPressure
            maxForce = 0.0
        }
        return result
    }
    
    mutating func cancelInteraction(){
        history = []
        maxForce = 0.0
    }
    
    var currentRawValue:Double! {
        switch ForceTouchInterpreter.ftOption {
        case .AvgLastTen: return avgLastTenPressure
        case .SmoothedLastTen: return smoothedLastTen
        case .PeakPressure: return peakScaledPressure
        }
    }
    
    
    enum FTOptions:String {
        case AvgLastTen = "AvgLastTen",
        PeakPressure = "PeakPressure",
        SmoothedLastTen = "SmoothedLastTen"
    }
    
    
    private var avgLastTenPressure:Double {
        let count = history.count
        guard count > 1 else {return 0.0}
        if count < 10 {
            return (history[1..<count].reduce(0.0, combine: +) / Double(count - 1)) / ForceTouchInterpreter.maximumPossibleForce
        } else {
            return (history[(count - 10)..<count].reduce(0.0, combine: +) / Double(10)) / ForceTouchInterpreter.maximumPossibleForce
        }
        
    }
    
    private var peakScaledPressure:Double {
        return maxForce / ForceTouchInterpreter.maximumPossibleForce
    }
 
    
    private var smoothedLastTen:Double {
        let count = history.count
        guard count > 2 else {return history.maxElement() ?? 0.0}
        //var truncated:[Double]!
        
        var sum:Double = 0
        var max:Double = 0
        var min:Double = 1
        var adjustedCount:Double!
        
        if count < 10 {
            for val in history[0..<count] {
                sum += val
                if val > max {max = val}
                if val < min {min = val}
            }
            adjustedCount = Double(count - 2)
        } else {
            for val in history[(count - 10)..<count] {
                sum += val
                if val > max {max = val}
                if val < min {min = val}
            }
            adjustedCount = 8.0
        }
        
        return ((sum - max - min) / adjustedCount) / ForceTouchInterpreter.maximumPossibleForce
        
//        if count < 10 {
//            truncated = Array<Double>(history[1..<count])
//        } else {
//            truncated = Array<Double>(history[(count - 10)..<count])
//        }
//        truncated.sortInPlace()
//        truncated.removeLast()
//        truncated.removeFirst()
//        return (truncated.reduce(0.0, combine: +) / Double(truncated.count)) / ForceTouchInterpreter.maximumPossibleForce
    }
    
}



private struct DurationTouchInterpreter:IATouchInterpretingProtocol{
    static var fullTouchDuration:Double = 0.5
    
    var touchStartTime:CFTimeInterval!
    
    mutating func updateIntensityYieldingRawResult(withTouch touch:UITouch)->Double{
        if touchStartTime == nil {
            touchStartTime = CACurrentMediaTime()
            return 0.0
        } else {
            return max((CACurrentMediaTime() - touchStartTime) / DurationTouchInterpreter.fullTouchDuration, 1.0)
        }
    }
    mutating func endInteractionYieldingRawResult(withTouch touch:UITouch?)->Double{
        let raw = self.currentRawValue ?? 0.0
        touchStartTime = nil
        return raw
    }
    mutating func cancelInteraction(){
        touchStartTime = nil
    }
    var currentRawValue:Double! {
        guard touchStartTime != nil else {return nil}
        return min((CACurrentMediaTime() - touchStartTime) / DurationTouchInterpreter.fullTouchDuration, 1.0)
    }
}
