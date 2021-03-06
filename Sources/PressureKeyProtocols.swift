//
//  PressureKeyProtocols.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/7/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation





///protocol for PressureKey, PressureView and ExpandingPressureKey for the pressure sensitive buttons using the PressureKeyAction delegate pattern
public protocol PressureControl {
    weak var delegate:PressureKeyActionDelegate? {get set}
}

///Protocol for delegate used by PressureKey, PressureView and ExpandingPressureKey
public protocol PressureKeyActionDelegate:class {
    func pressureKeyPressed(_ sender:PressureControl, actionName:String, intensity:Int)
}



