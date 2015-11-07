//
//  KeyProtocols.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/7/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation





///protocol for PressureView and ExpandingPressureKey for the pressure sensitive buttons using the PressureKeyAction delegate pattern
protocol PressureControl {
    weak var delegate:PressureKeyAction? {get set}
}

///Protocol for delegate used by PressureView and ExpandingPressureKey
protocol PressureKeyAction:class {
    func pressureKeyPressed(sender:PressureControl, actionName:String, actionType:PressureKeyActionType, intensity:Float)
}


enum PressureKeyActionType {
    case CharInsert, TriggerFunction
}


