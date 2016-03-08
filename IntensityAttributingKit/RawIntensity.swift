//
//  RawIntensity.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/1/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation


//public struct RawIntensity {
//    ///raw force value
//    var forceHistory:[Float]
//    ///As far as I can tell this is constant on a device and may well be 6.667 across all devices.
//    var maximumPossibleForce:Float
//    
//    ///returns the intensity value for this RawIntensity object as determined using the global static var forceIntensityMapping(RawIntensity)
//    var intensity:Int {
//        return Int(RawIntensity.forceIntensityMapping(raw: self) * 100)
//    }
//    var startTime:CFTimeInterval!
//    
//    var avgPressure:Float {
//        let count = forceHistory.count
//        guard count > 1 else {return 0.0}
//        if count < 10 {
//            return (forceHistory[1..<count].reduce(0.0, combine: +) / Float(count - 1)) / self.maximumPossibleForce
//        } else {
//            return (forceHistory[(count - 10)..<count].reduce(0.0, combine: +) / Float(10)) / self.maximumPossibleForce
//        }
//        
//    }
//    
//    var peakPressure:Float {
//        return (forceHistory.maxElement() ?? 0.0) / self.maximumPossibleForce
//    }
//    
//    mutating func reset(withValue:CGFloat = 0.0){
//        forceHistory = [Float(withValue)]
//        startTime = CACurrentMediaTime()
//    }
//    
//    mutating func append(value:CGFloat){
//        forceHistory.append(Float(value))
//    }
//    mutating func append(value:Float){
//        forceHistory.append(value)
//    }
//    
//    init(withValue:CGFloat, maximumPossibleForce:CGFloat = RawIntensity.maximumPossibleForceForDevice){
//        forceHistory = [Float(withValue)]
//        self.maximumPossibleForce = Float(maximumPossibleForce)
//        startTime = CACurrentMediaTime()
//    }
//    
//    init(withFloatValue float:Float = 0.0, maximumPossibleForce:Float = Float(RawIntensity.maximumPossibleForceForDevice)){
//        forceHistory = [float]
//        self.maximumPossibleForce = maximumPossibleForce
//        startTime = CACurrentMediaTime()
//    }
//    
//    ///As far as I can tell maximumPossibleForce is constant across the device
//    static var maximumPossibleForceForDevice:CGFloat = 6.667
//    
//    
//    ///Global mapping function between Force and intensity value
//    public static var forceIntensityMapping:(raw:RawIntensity)->Float = ForceIntensityMappingFunctions.Linear.smoothedAverageLastTen
//    
//
//    
//
//    
//}


public struct RawIntensity{
    
    public static var rawIntensityMapping:RawIntensityMapping = IAKitOptions.rawIntensityMapper {
        didSet{intensityMappingFunction = rawIntensityMapping.function}
    }
    
    static var intensityMappingFunction:RawIntensityMappingFunction = IAKitOptions.rawIntensityMapper.function
    
    static var touchInterpreter:IATouchInterpreter = IAKitOptions.touchInterpreter
    
    private var currentInterpreter:IATouchInterpretingProtocol = RawIntensity.touchInterpreter.newInstance
    
    mutating func updateIntensity(withTouch touch:UITouch){
        currentInterpreter.updateIntensityYieldingRawResult(withTouch: touch)
    }
    
    mutating func endInteraction(withTouch touch:UITouch?)->Int{
        let raw = currentInterpreter.endInteractionYieldingRawResult(withTouch: touch)
        return RawIntensity.intensityMappingFunction(raw:raw)
    }
    
    mutating func cancelInteraction(){
        currentInterpreter.cancelInteraction()
    }
    
    var currentIntensity:Int! {
        guard let raw = currentInterpreter.currentRawValue else {return nil}
        return RawIntensity.intensityMappingFunction(raw: raw)
    }
}




public enum IATouchInterpreter:String{
    case Duration = "Duration",
    Force = "Force"
    
    
    
    var newInstance:IATouchInterpretingProtocol! {
        switch self {
        case .Duration: return DurationTouchInterpreter()
        case .Force: return ForceTouchInterpreter()
        }
    }
    
    var optionsForInterpreter:[String:AnyObject]{return [:]}
    
    
    
}


protocol IATouchInterpretingProtocol {
    mutating func updateIntensityYieldingRawResult(withTouch touch:UITouch)->Double
    mutating func endInteractionYieldingRawResult(withTouch touch:UITouch?)->Double
    mutating func cancelInteraction()
    var currentRawValue:Double! {get}
}


private struct ForceTouchInterpreter:IATouchInterpretingProtocol {
    
    static var ftOption:FTOptions = .AvgLastTen
    static var maximumPossibleForce:Double = 6.66667  //this should be determined by device type
    
    var history:[Double] = []
    var maxForce:Double = 0.0
    
    mutating func updateIntensityYieldingRawResult(withTouch touch:UITouch)->Double{
        if ForceTouchInterpreter.ftOption == .AvgLastTen {
            history.append(Double(touch.force))
            return avgLastTenPressure
        } else {
            maxForce = max(maxForce, Double(touch.force))
            return peakScaledPressure
        }
    }
    
    mutating func endInteractionYieldingRawResult(withTouch touch:UITouch?)->Double{
        var result:Double!
        if ForceTouchInterpreter.ftOption == .AvgLastTen {
            if let touch = touch {
                history.append(Double(touch.force))
            }
            result = avgLastTenPressure
            history.removeAll()
        } else {
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
        if ForceTouchInterpreter.ftOption == .AvgLastTen {
            return avgLastTenPressure
        } else {
            return peakScaledPressure
        }
    }
    
    
    enum FTOptions:String {
        case AvgLastTen = "AvgLastTen",
        PeakPressure = "PeakPressure"
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
        return max((CACurrentMediaTime() - touchStartTime) / DurationTouchInterpreter.fullTouchDuration, 1.0)
    }
}


/* Notes:

Process: rawIntensity contained by control is reset on touches began with:
rawIntensity = RawIntensity(withValue: touch.force,maximumPossibleForce: touch.maximumPossibleForce)
    or
rawIntensity.reset()

This restarts the timer and sets the force array to [0]

This should be replaced by a touchinside method and a reset method/ or 
update/begin
end -> with result
cancel

RawIntensity handles touch, packages everything




//intensitymapping is limited to the mapping curve and can be handled more or less as is, with some adjustments to the interface for saving/restoring-  and with function parameters being (raw:Int)->Int





*/






























