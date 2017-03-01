//
//  IATouchInterpreter.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/4/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation

///Enum for managing available IATouchInterpreters
public enum IATouchInterpreter:String{
    case Duration = "Duration",
    Force = "Force",
    //Radius = "Radius",
    ImpactDuration = "ImpactDuration"
    
    
    
    func newInstance()->IATouchInterpretingProtocol! {
        switch self {
        case .Duration: return DurationTouchInterpreter()
        case .Force: return ForceTouchInterpreter()
        //case .Radius: return MajorRadiusTouchInterpreter()
        case .ImpactDuration: return ImpactDurationTouchInterpreter()
        }
    }
    
    
    func activate(){
        if self == .ImpactDuration {AccelHistory.singleton.startCollecting()}
    }
    func deactivate(){
        if self == .ImpactDuration {AccelHistory.singleton.stopCollecting()}
    }
    
}


protocol IATouchInterpretingProtocol {
    mutating func updateIntensityYieldingRawResult(withTouch touch:UITouch)->Float
    mutating func endInteractionYieldingRawResult(withTouch touch:UITouch?)->Float
    mutating func cancelInteraction()
    var currentRawValue:Float! {get}
}
