//
//  ForceIntensityMappingFunctions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/7/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation

typealias RawIntensityMappingFunction = ((raw:Double)->Int)

public enum RawIntensityMapping {
    case Linear(threshold:Double,ceiling:Double),
    LogAx(a:Double,threshold:Double,ceiling:Double)
    
    var function:RawIntensityMappingFunction{
        switch self{
        case .Linear(let threshold, let ceiling): return LinearMapping.generateFunction(threshold:threshold, ceiling: ceiling)
        case .LogAx(let a, let threshold, let ceiling): return LogAxMapping.generateFunction(a,threshold:threshold,ceiling:ceiling)
        }
        
    }
    
    public var shortName:String {
        switch self {
        case .Linear: return "Linear"
        case .LogAx: return "LogAx"
        }
    }
    
    var dictDescription:[String:AnyObject]{
        switch self{
            case .Linear(let threshold, let ceiling): return ["name":self.shortName,"threshold":threshold, "ceiling":ceiling]
            case .LogAx(let a, let threshold, let ceiling): return ["name":self.shortName, "a":a,"threshold":threshold, "ceiling":ceiling]
        }
    }
    
    init!(dictDescription:[String:AnyObject]){
        //require matching name, otherwise fill in default values where needed
        guard let name = dictDescription["name"] as? String else {return nil}
        let threshold = (dictDescription["threshold"] as? Double) ?? 0.0
        let ceiling = (dictDescription["ceiling"] as? Double) ?? 1.0
        
        switch name {
            case "Linear": self = .Linear(threshold: threshold, ceiling: ceiling)
            case "LogAx":
                let a = (dictDescription["a"] as? Double) ?? 10.0
                self = .LogAx(a: a, threshold: threshold, ceiling: ceiling)
        default:
            return nil
        }
        
    }
    
    var threshold:Double {
        switch self {
        case .Linear(let threshold, _): return threshold
        case .LogAx(_, let threshold, _): return threshold
        }
    }
    var ceiling:Double {
        switch self {
        case .Linear( _, let ceiling): return ceiling
        case .LogAx( _,  _, let ceiling): return ceiling
        }
    }
    
    ///Parameter "a", where appropriate
    var a:Double? {
        switch self {
        case .Linear( _, _): return nil
        case .LogAx( let a,  _, _): return a
        }
    }
}

private struct LinearMapping{
    static func generateFunction(threshold thresh:Double,ceiling:Double)->RawIntensityMappingFunction{
        func linearMapping(raw:Double)->Int{
            guard raw > thresh else {return 0}
            guard raw <= ceiling else {return 100}
            return Int(100 * (raw - thresh) / (ceiling - thresh))
        }
        return linearMapping
    }
}

private struct LogAxMapping {
    static func generateFunction(a:Double, threshold:Double, ceiling:Double)->RawIntensityMappingFunction{
        let factor = log(1 + (ceiling - threshold)*a) / 100
        func rim(raw:Double)->Int{
            guard raw > threshold else {return 0}
            guard raw <= ceiling else {return 100}
            return Int((log(1 + (raw - threshold)*a) ) / factor)
        }
        return rim
    }
}




