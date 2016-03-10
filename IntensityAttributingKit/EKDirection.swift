//
//  EKDirection.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 12/3/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation





///The direction in which an ExpandingPressureKey grows on selection
public enum EKDirection {
    case Up,Down,Left,Right
    
    var hasForwardLayoutDirection:Bool
        {return self == .Down || self == .Right}
    
    var axis:UILayoutConstraintAxis {
        return (self == .Up || self == .Down) ? .Vertical : .Horizontal
    }
    
}