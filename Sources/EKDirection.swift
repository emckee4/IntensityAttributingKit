//
//  EKDirection.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 12/3/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation


///The direction in which an ExpandingPressureKey grows on selection. It's helper computed variables are used by other layout functions.
public enum EKDirection {
    case up,down,left,right
    
    var hasForwardLayoutDirection:Bool
        {return self == .down || self == .right}
    
    var axis:UILayoutConstraintAxis {
        return (self == .up || self == .down) ? .vertical : .horizontal
    }
    
}
