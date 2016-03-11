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
    Force = "Force",
    Radius = "Radius"
    
    
    
    var newInstance:IATouchInterpretingProtocol! {
        switch self {
        case .Duration: return DurationTouchInterpreter()
        case .Force: return ForceTouchInterpreter()
        case .Radius: return MajorRadiusTouchInterpreter()
        }
    }
    
}


protocol IATouchInterpretingProtocol {
    mutating func updateIntensityYieldingRawResult(withTouch touch:UITouch)->Float
    mutating func endInteractionYieldingRawResult(withTouch touch:UITouch?)->Float
    mutating func cancelInteraction()
    var currentRawValue:Float! {get}
}


enum TISmoothingMethod:String {
    case AvgLastTen = "AvgLastTen",
    PeakPressure = "PeakPressure",
    SmoothedLastTen = "SmoothedLastTen"
}

protocol TISmoothableHistory:IATouchInterpretingProtocol {
    var history:[Float] {get set}
    var maxValue:Float {get set}
    static var tiSmoothing:TISmoothingMethod {get set}
    
    func processTouch(touch:UITouch)->Float
}

///Containts default implementations for TISmoothable touchInterpreters
extension TISmoothableHistory{
    mutating func updateIntensityYieldingRawResult(withTouch touch:UITouch)->Float{
        switch Self.tiSmoothing {
        case .AvgLastTen:
            history.append(processTouch(touch))
            return avgLastTenPressure
        case .SmoothedLastTen:
            history.append(processTouch(touch))
            return smoothedLastTen
        case .PeakPressure:
            maxValue = max(maxValue, processTouch(touch))
            return maxValue
        }
    }
    
    mutating func endInteractionYieldingRawResult(withTouch touch:UITouch?)->Float{
        var result:Float!
        switch Self.tiSmoothing {
        case .AvgLastTen:
            if let touch = touch {
                history.append(processTouch(touch))
            }
            result = avgLastTenPressure
            history.removeAll()
        case .SmoothedLastTen:
            if let touch = touch {
                history.append(processTouch(touch))
            }
            result = smoothedLastTen
            history.removeAll()
        case .PeakPressure:
            if let touch = touch {
                maxValue = max(maxValue, processTouch(touch))
            }
            result = maxValue
            maxValue = 0.0
        }
        return result
    }
    
    mutating func cancelInteraction(){
        history = []
        maxValue = 0.0
    }
    
    var currentRawValue:Float! {
        switch Self.tiSmoothing {
        case .AvgLastTen: return avgLastTenPressure
        case .SmoothedLastTen: return smoothedLastTen
        case .PeakPressure: return maxValue
        }
    }
    
    
    
    
    
    private var avgLastTenPressure:Float {
        let count = history.count
        guard count > 1 else {return 0.0}
        if count < 10 {
            return (history[1..<count].reduce(0.0, combine: +) / Float(count - 1)) // / ForceTouchInterpreter.maximumPossibleForce
        } else {
            return (history[(count - 10)..<count].reduce(0.0, combine: +) / Float(10)) // / ForceTouchInterpreter.maximumPossibleForce
        }
        
    }
    
    private var smoothedLastTen:Float {
        let count = history.count
        guard count > 2 else {return history.maxElement() ?? 0.0}
        //var truncated:[Float]!
        
        var sum:Float = 0
        var max:Float = 0
        var min:Float = 1
        var adjustedCount:Float!
        
        if count < 10 {
            for val in history[0..<count] {
                sum += val
                if val > max {max = val}
                if val < min {min = val}
            }
            adjustedCount = Float(count - 2)
        } else {
            for val in history[(count - 10)..<count] {
                sum += val
                if val > max {max = val}
                if val < min {min = val}
            }
            adjustedCount = 8.0
        }
        
        return ((sum - max - min) / adjustedCount) // / ForceTouchInterpreter.maximumPossibleForce
        
        //        if count < 10 {
        //            truncated = Array<Float>(history[1..<count])
        //        } else {
        //            truncated = Array<Float>(history[(count - 10)..<count])
        //        }
        //        truncated.sortInPlace()
        //        truncated.removeLast()
        //        truncated.removeFirst()
        //        return (truncated.reduce(0.0, combine: +) / Float(truncated.count)) / ForceTouchInterpreter.maximumPossibleForce
    }
}

private struct ForceTouchInterpreter:TISmoothableHistory {
    static var tiSmoothing:TISmoothingMethod = .AvgLastTen
    //static var ftOption:FTOptions = .SmoothedLastTen
    static var maximumPossibleForce:Float = 6.66667  //this should be determined by device type
    
    var history:[Float] = []
    var maxValue:Float = 0.0
    
    func processTouch(touch:UITouch)->Float{
        return Float(touch.force / touch.maximumPossibleForce)
    }
/*
    mutating func updateIntensityYieldingRawResult(withTouch touch:UITouch)->Float{
        switch ForceTouchInterpreter.ftOption {
        case .AvgLastTen:
            history.append(Float(touch.force))
            return avgLastTenPressure
        case .SmoothedLastTen:
            history.append(Float(touch.force))
            return smoothedLastTen
        case .PeakPressure:
            maxForce = max(maxForce, Float(touch.force))
            return peakScaledPressure
        }
    }
    
    mutating func endInteractionYieldingRawResult(withTouch touch:UITouch?)->Float{
        var result:Float!
        switch ForceTouchInterpreter.ftOption {
        case .AvgLastTen:
            if let touch = touch {
                history.append(Float(touch.force))
            }
            result = avgLastTenPressure
            history.removeAll()
        case .SmoothedLastTen:
            if let touch = touch {
                history.append(Float(touch.force))
            }
            result = smoothedLastTen
            history.removeAll()
        case .PeakPressure:
            if let touch = touch {
                maxForce = max(maxForce, Float(touch.force))
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
    
    var currentRawValue:Float! {
        switch ForceTouchInterpreter.ftOption {
        case .AvgLastTen: return avgLastTenPressure
        case .SmoothedLastTen: return smoothedLastTen
        case .PeakPressure: return peakScaledPressure
        }
    }
    
    

    
    
    private var avgLastTenPressure:Float {
        let count = history.count
        guard count > 1 else {return 0.0}
        if count < 10 {
            return (history[1..<count].reduce(0.0, combine: +) / Float(count - 1)) / ForceTouchInterpreter.maximumPossibleForce
        } else {
            return (history[(count - 10)..<count].reduce(0.0, combine: +) / Float(10)) / ForceTouchInterpreter.maximumPossibleForce
        }
        
    }
    
    private var peakScaledPressure:Float {
        return maxForce / ForceTouchInterpreter.maximumPossibleForce
    }
 
    
    private var smoothedLastTen:Float {
        let count = history.count
        guard count > 2 else {return history.maxElement() ?? 0.0}
        //var truncated:[Float]!
        
        var sum:Float = 0
        var max:Float = 0
        var min:Float = 1
        var adjustedCount:Float!
        
        if count < 10 {
            for val in history[0..<count] {
                sum += val
                if val > max {max = val}
                if val < min {min = val}
            }
            adjustedCount = Float(count - 2)
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
//            truncated = Array<Float>(history[1..<count])
//        } else {
//            truncated = Array<Float>(history[(count - 10)..<count])
//        }
//        truncated.sortInPlace()
//        truncated.removeLast()
//        truncated.removeFirst()
//        return (truncated.reduce(0.0, combine: +) / Float(truncated.count)) / ForceTouchInterpreter.maximumPossibleForce
    }
    */
}

private struct MajorRadiusTouchInterpreter:TISmoothableHistory {
    
    
    static var tiSmoothing:TISmoothingMethod = .AvgLastTen
    static var maxRadius:CGFloat = 50.0
    
    var history:[Float] = []
    var maxValue:Float = 0.0
    
    func processTouch(touch:UITouch)->Float{
        return Float(touch.majorRadius / MajorRadiusTouchInterpreter.maxRadius)
    }

}

private struct DurationTouchInterpreter:IATouchInterpretingProtocol{
    static var fullTouchDuration:Float = 0.5
    
    var touchStartTime:CFTimeInterval!
    
    mutating func updateIntensityYieldingRawResult(withTouch touch:UITouch)->Float{
        if touchStartTime == nil {
            touchStartTime = CACurrentMediaTime()
            return 0.0
        } else {
            return max(Float(CACurrentMediaTime() - touchStartTime) / DurationTouchInterpreter.fullTouchDuration, 1.0)
        }
    }
    mutating func endInteractionYieldingRawResult(withTouch touch:UITouch?)->Float{
        let raw = self.currentRawValue ?? 0.0
        touchStartTime = nil
        return raw
    }
    mutating func cancelInteraction(){
        touchStartTime = nil
    }
    var currentRawValue:Float! {
        guard touchStartTime != nil else {return nil}
        return min(Float(CACurrentMediaTime() - touchStartTime) / DurationTouchInterpreter.fullTouchDuration, 1.0)
    }
}





