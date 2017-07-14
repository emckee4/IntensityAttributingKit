//
//  IAAccessoryDelegateProtocol.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/8/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation



///IAAccessoryDelegate delivers actions from the IAAccessory to the IATextView
protocol IAAccessoryDelegate:class {
    func accessoryKeyboardChangeButtonPressed(_ accessory:IAAccessoryVC!)
    
    func accessoryOptionButtonPressed(_ accessory:IAAccessoryVC!)
    
    ///Return true to inform the iaAccessory that it should center the button associated with the transformer.
    func accessoryRequestsTransformerChange(_ accessory:IAAccessoryVC!, toTransformer:IntensityTransformers)->Bool
    
    func accessoryRequestsPickerLaunch(_ accessory:IAAccessoryVC!, pickerName:String)
    
    func accessoryUpdatedDefaultIntensity(_ accessory:IAAccessoryVC!, withValue value:Int)
    
    ///Return true to inform the iaAccessory that it should center the button associated with the smoothing tokenizer.
    func accessoryRequestsSmoothingChange(_ accessory:IAAccessoryVC!, toValue:IAStringTokenizing)->Bool
    
    func iaKeyboardIsShowing()->Bool

}
