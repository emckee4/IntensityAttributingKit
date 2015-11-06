//
//  KeysetComponents.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/5/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation


protocol IAKeyset {
    var numberOfPages:Int {get}
    var qRow:[IAKeyType] {get}
    var aRow:[IAKeyType] {get}
    var zRow:[IAKeyType] {get}
    var spaceRow:[IAKeyType] {get}
}




struct IASingleKey:IAKeyType {
    var character:String
}

///Used for representing an expanding key
struct IAMultiKey:IAKeyType {
    
    
    //if I use the delegate pattern on ExpandingPressureKey with pressure control then this should be able to setup keys to feed into the single pressure key action
    
    
}

struct IAReservedKey {
    //don't change/touch these-- maybe make some indication in the keys themselves? could make tag values over 1000 for instance
}


protocol IAKeyType {
    
}





///protocol for both PressureButton and ExpandingControls
protocol PressureControl {
    //var lastTriggeredName:String {get}
    //var lastIntensity:Float {get}
}

struct BasicEnglishKeyset {
    
}


protocol PressureKeyAction {
    func pressureKeyPressed(sender:PressureControl, actionName:String, actionType:PressureKeyActionType, intensity:Float)
}

enum PressureKeyActionType {
    case CharInsert, TriggerFunction
}