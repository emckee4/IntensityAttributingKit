//
//  EPKey.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 12/3/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation


///Provides the grouping of the view and actionName/selector for the ExpandingKey classes while also providing a handful of convenience functions
class EPKey {
    var view:UIView
    var actionName:String
    var actionType:PressureKeyActionType
    weak var target:AnyObject?
    var triggeredSelector:String?
    
    var hidden:Bool {
        set {view.hidden = newValue}
        get {return view.hidden}
    }
    
    ///Init for delegate style actions
    init(view:UIView,actionName:String, actionType:PressureKeyActionType){
        self.view = view
        self.actionName = actionName
        self.actionType = actionType
    }
    
    ///Init for selector style actions
    init(view:UIView, actionName:String, target:AnyObject, selector:String){
        self.view = view
        self.actionName = actionName
        self.actionType = PressureKeyActionType.TriggerFunction
        self.target = target
        self.triggeredSelector = selector
    }
}