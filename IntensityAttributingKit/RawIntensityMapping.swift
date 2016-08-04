//
//  ForceIntensityMappingFunctions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/7/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation

typealias RawIntensityMappingFunction = ((raw:Float)->Int)

///This enum keeps track of the available RIM functions.
public enum RawIntensityMapping:String {
    case Linear = "LinearMapping",
    LogAx = "LogAxMapping"
    
    var makeRIMFunction:RawIntensityMappingFunction{
        switch self{
        case .Linear: return LinearMapping.makeRIMFunction()
        case .LogAx: return LogAxMapping.makeRIMFunction()
        }
        
    }
}

///Rescales raw intensity linearly between the threshold and ceiling values
struct LinearMapping{
    private static var _threshold:Float = {return (NSUserDefaults.standardUserDefaults().objectForKey("LinearMapping:threshold") as? Float) ?? 0.0}()
    static var threshold:Float {
        get{return _threshold}
        set{_threshold = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "LinearMapping:threshold")}
    }
    
    private static var _ceiling:Float = {return (NSUserDefaults.standardUserDefaults().objectForKey("LinearMapping:ceiling") as? Float) ?? 1.0}()
    static var ceiling:Float {
        get{return _ceiling}
        set{_ceiling = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "LinearMapping:ceiling")}
    }
    
    static func makeRIMFunction()->RawIntensityMappingFunction{
        func linearMapping(raw:Float)->Int{
            guard raw > LinearMapping.threshold else {return 0}
            guard raw <= LinearMapping.ceiling else {return 100}
            return Int(100 * (raw - LinearMapping.threshold) / (LinearMapping.ceiling - LinearMapping.threshold))
        }
        return linearMapping
    }
}

///Rescales raw intensity logarithmically: rescaled = log(1 + (ceiling - threshold) * aParam) / 100
struct LogAxMapping {
    private static var _threshold:Float = {return (NSUserDefaults.standardUserDefaults().objectForKey("LogAxMapping:threshold") as? Float) ?? 0.0}()
    static var threshold:Float {
        get{return _threshold}
        set{_threshold = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "LogAxMapping:threshold")}
    }
    
    private static var _ceiling:Float = {return (NSUserDefaults.standardUserDefaults().objectForKey("LogAxMapping:ceiling") as? Float) ?? 1.0}()
    static var ceiling:Float {
        get{return _ceiling}
        set{_ceiling = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "LogAxMapping:ceiling")}
    }
    
    private static var _aParam:Float = {return (NSUserDefaults.standardUserDefaults().objectForKey("LogAxMapping:aParam") as? Float) ?? 10.0}()
    static var aParam:Float {
        get{return _aParam}
        set{_aParam = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "LogAxMapping:aParam")}
    }
    
    static func makeRIMFunction()->RawIntensityMappingFunction{
        let factor = log(1 + (ceiling - threshold) * aParam) / 100
        func rim(raw:Float)->Int{
            guard raw > threshold else {return 0}
            guard raw <= ceiling else {return 100}
            return Int((log(1 + (raw - threshold)*aParam) ) / factor)
        }
        return rim
    }
}

