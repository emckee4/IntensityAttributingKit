//
//  TouchInterpreters.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/10/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


///Longer presses yield higher raw intensities.
struct DurationTouchInterpreter:IATouchInterpretingProtocol{
    private static var _durationMultiplier:Float = {return (NSUserDefaults.standardUserDefaults().objectForKey("DTI:durationMultiplier") as? Float) ?? 2.0}()
    static var durationMultiplier:Float {
        get{return _durationMultiplier}
        set{_durationMultiplier = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "DTI:durationMultiplier")}
    }
    

    var touchStartTime:NSTimeInterval!
    
    mutating func updateIntensityYieldingRawResult(withTouch touch:UITouch)->Float{
        if touch.phase == .Began || touchStartTime == nil{
            touchStartTime = touch.timestamp
            return 0.0
        } else {
            return min(Float(touch.timestamp - touchStartTime) * DurationTouchInterpreter.durationMultiplier, 1.0)
        }
    }
    mutating func endInteractionYieldingRawResult(withTouch touch:UITouch?)->Float{
        guard let ts = touch?.timestamp where touchStartTime != nil else {touchStartTime = nil; return 0.0}
        let result = min(Float(ts - touchStartTime) * DurationTouchInterpreter.durationMultiplier, 1.0)
        touchStartTime = nil
        return result
    }
    mutating func cancelInteraction(){
        touchStartTime = nil
    }
    var currentRawValue:Float! {
        guard touchStartTime != nil else {return nil}
        return min(Float(NSProcessInfo.processInfo().systemUptime - touchStartTime) * DurationTouchInterpreter.durationMultiplier, 1.0)
    }
}


///Utilizes both timer based methods of DurationTouchInterpreter as well as the AccelHistory accelerometer data.
class ImpactDurationTouchInterpreter:IATouchInterpretingProtocol{
    private static var _durationMultiplier:Float = {return (NSUserDefaults.standardUserDefaults().objectForKey("IDTI:durationMultiplier") as? Float) ?? 2.4}()
    static var durationMultiplier:Float {
        get{return _durationMultiplier}
        set{_durationMultiplier = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "IDTI:durationMultiplier")}
    }
    
    private static var _impactMultiplier:Float = {return (NSUserDefaults.standardUserDefaults().objectForKey("IDTI:impactMultiplier") as? Float) ?? 0.9}()
    ///Multiplier for max absolute user z force
    static var impactMultiplier:Float {
        get{return _impactMultiplier}
        set{_impactMultiplier = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "IDTI:impactMultiplier")}
    }
    
    static let coefficient:Float = -0.38
    static let impactPower:Float = 0.5
    
    private static func calcRawResult(maxAbsZ:Float, elapsedTime:NSTimeInterval)->Float{
        let raw = (self.durationMultiplier * Float(elapsedTime)) + (pow(maxAbsZ, self.impactPower) * self.impactMultiplier) + coefficient
        return max(min(raw, 1.0),0.0)
    }
    
    ///
    
    var touchStartTime:NSTimeInterval!
    
    func updateIntensityYieldingRawResult(withTouch touch:UITouch)->Float{
        if touch.phase == .Began {
            touchStartTime = touch.timestamp
            AccelHistory.singleton.resetMaxAbsZ()
            return 0.0
        } else {
            return ImpactDurationTouchInterpreter.calcRawResult(Float(AccelHistory.singleton.maxAbsZ), elapsedTime: touch.timestamp - touchStartTime)
        }
    }
    func endInteractionYieldingRawResult(withTouch touch:UITouch?)->Float{
        guard let ts = touch?.timestamp else {touchStartTime = nil;return 0.0}
        let z = Float(AccelHistory.singleton.maxAbsZ)
        let elapsed = ts - touchStartTime
        touchStartTime = nil
        return ImpactDurationTouchInterpreter.calcRawResult(z, elapsedTime: elapsed)
    }
    func cancelInteraction(){
        touchStartTime = nil
    }
    var currentRawValue:Float! {
        guard touchStartTime != nil else {return nil}
        return ImpactDurationTouchInterpreter.calcRawResult(Float(AccelHistory.singleton.maxAbsZ), elapsedTime: NSProcessInfo.processInfo().systemUptime - touchStartTime)
    }
    

}






