//
//  RawIntensity.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/1/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation


struct RawIntensity {
    var pressureHistory:[CGFloat]
    
    var avgPressure:CGFloat {
        let count = pressureHistory.count
        guard count > 1 else {return 0.0}
        if count < 10 {
            return pressureHistory[1..<count].reduce(0.0, combine: +) / CGFloat(pressureHistory.count - 1)
        } else {
            return pressureHistory[(count - 10)..<count].reduce(0.0, combine: +) / CGFloat(10)
        }
        
    }
    
    var peakPressure:CGFloat {
        return pressureHistory.maxElement() ?? 0.0
    }
    
    mutating func reset(withValue:CGFloat = 0.0){
        pressureHistory = [withValue]
    }
    
    mutating func append(value:CGFloat){
        pressureHistory.append(value)
    }
    
    
    init(withValue:CGFloat = 0.0){
        pressureHistory = [withValue]
    }
}

