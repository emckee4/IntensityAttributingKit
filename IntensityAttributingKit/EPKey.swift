//
//  EPKey.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 12/3/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation


///Provides the grouping of the view and actionName for the ExpandingKey classes. These are used by the ExpandingKeyBase subclasses for managing indivual keys.
class EPKey {
    var view:UIView
    var actionName:String
    
    var hidden:Bool {
        set {view.hidden = newValue}
        get {return view.hidden}
    }
    
    ///Init for delegate style actions
    init(view:UIView,actionName:String){
        self.view = view
        self.actionName = actionName
    }
    
}

func ==(lhs:EPKey, rhs:EPKey)->Bool{
    return lhs.view == rhs.view && lhs.actionName == rhs.actionName
}

func !=(lhs:EPKey, rhs:EPKey)->Bool{
    return !(lhs == rhs)
}