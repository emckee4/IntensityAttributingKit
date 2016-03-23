//
//  ForceIntensityMappingFunctions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/7/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation

typealias RawIntensityMappingFunction = ((raw:Float)->Int)

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


//public enum RawIntensityMapping {
//    case Linear(threshold:Float,ceiling:Float),
//    LogAx(a:Float,threshold:Float,ceiling:Float)
//
//    var function:RawIntensityMappingFunction{
//        switch self{
//        case .Linear(let threshold, let ceiling): return LinearMapping.generateFunction(threshold:threshold, ceiling: ceiling)
//        case .LogAx(let a, let threshold, let ceiling): return LogAxMapping.generateFunction(a,threshold:threshold,ceiling:ceiling)
//        }
//
//    }
//
//    public var shortName:String {
//        switch self {
//        case .Linear: return "Linear"
//        case .LogAx: return "LogAx"
//        }
//    }
//
//    var dictDescription:[String:AnyObject]{
//        switch self{
//            case .Linear(let threshold, let ceiling): return ["name":self.shortName,"threshold":threshold, "ceiling":ceiling]
//            case .LogAx(let a, let threshold, let ceiling): return ["name":self.shortName, "a":a,"threshold":threshold, "ceiling":ceiling]
//        }
//    }
//
//    init!(dictDescription:[String:AnyObject]){
//        //require matching name, otherwise fill in default values where needed
//        guard let name = dictDescription["name"] as? String else {return nil}
//        let threshold = (dictDescription["threshold"] as? Float) ?? 0.0
//        let ceiling = (dictDescription["ceiling"] as? Float) ?? 1.0
//
//        switch name {
//            case "Linear": self = .Linear(threshold: threshold, ceiling: ceiling)
//            case "LogAx":
//                let a = (dictDescription["a"] as? Float) ?? 10.0
//                self = .LogAx(a: a, threshold: threshold, ceiling: ceiling)
//        default:
//            return nil
//        }
//
//    }
//
//    var threshold:Float {
//        switch self {
//        case .Linear(let threshold, _): return threshold
//        case .LogAx(_, let threshold, _): return threshold
//        }
//    }
//    var ceiling:Float {
//        switch self {
//        case .Linear( _, let ceiling): return ceiling
//        case .LogAx( _,  _, let ceiling): return ceiling
//        }
//    }
//
//    ///Parameter "a", where appropriate
//    var a:Float? {
//        switch self {
//        case .Linear( _, _): return nil
//        case .LogAx( let a,  _, _): return a
//        }
//    }
//}

