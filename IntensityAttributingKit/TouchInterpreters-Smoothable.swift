//
//  TouchInterpreters-Smoothable.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/4/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


///Used by TISmoothableHistory based interpreters
enum TISmoothingMethod:String {
    case AvgLastTen = "AvgLastTen",
    PeakPressure = "PeakPressure",
    SmoothedLastTen = "SmoothedLastTen"
}

///Contains default implementations for TISmoothable touchInterpreters, which are those which average data from multiple touches. This includes the force touch interpreter and excludes duration based interpreters
protocol TISmoothableHistory:IATouchInterpretingProtocol {
    var history:[Float] {get set}
    var maxValue:Float {get set}
    static var tiSmoothing:TISmoothingMethod {get set}
    
    func processTouch(touch:UITouch)->Float
}

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
    }
}

///The standard interpreter for 3dTouch capable devices. The harder you press, the higher the intensity.
struct ForceTouchInterpreter:TISmoothableHistory {
    private static var _tiSmoothing:TISmoothingMethod = {
        if let tiSmoothingName = (NSUserDefaults.standardUserDefaults().objectForKey("FTI:TISmoothing") as? String) {
            if let tism = TISmoothingMethod(rawValue: tiSmoothingName) {
                return tism
            }
        }
        return TISmoothingMethod.SmoothedLastTen
    }()
    static var tiSmoothing:TISmoothingMethod {
        get{return _tiSmoothing}
        set{_tiSmoothing = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue.rawValue, forKey: "FTI:TISmoothing")}
    }
    
    //static var ftOption:FTOptions = .SmoothedLastTen
    //static var maximumPossibleForce:Float = 6.66667  //this should be determined by device type
    
    var history:[Float] = []
    var maxValue:Float = 0.0
    
    func processTouch(touch:UITouch)->Float{
        return Float(touch.force / touch.maximumPossibleForce)
    }
}

///Not currently presented as available since the system doesn't make available sufficiently useful/granular radius data.
struct MajorRadiusTouchInterpreter:TISmoothableHistory {
    
    private static var _tiSmoothing:TISmoothingMethod = {
        if let tiSmoothingName = (NSUserDefaults.standardUserDefaults().objectForKey("MRTI:TISmoothing") as? String) {
            if let tism = TISmoothingMethod(rawValue: tiSmoothingName) {
                return tism
            }
        }
        return TISmoothingMethod.AvgLastTen
    }()
    static var tiSmoothing:TISmoothingMethod {
        get{return _tiSmoothing}
        set{_tiSmoothing = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue.rawValue, forKey: "MRTI:TISmoothing")}
    }
    private static var _maxRadius = {return (NSUserDefaults.standardUserDefaults().objectForKey("MRTI:maxRadius") as? CGFloat) ?? 50}()
    static var maxRadius:CGFloat {
        get{return _maxRadius}
        set{_maxRadius = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "MRTI:maxRadius")}
    }
    
    var history:[Float] = []
    var maxValue:Float = 0.0
    
    func processTouch(touch:UITouch)->Float{
        return Float(touch.majorRadius / MajorRadiusTouchInterpreter.maxRadius)
    }
    
}
