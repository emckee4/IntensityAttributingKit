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
    func accessoryKeyboardChangeButtonPressed(accessory:IAAccessoryVC!)
    
    func accessoryOptionButtonPressed(accessory:IAAccessoryVC!)
    
    ///Return true to inform the iaAccessory that it should center the button associated with the transformer.
    func accessoryRequestsTransformerChange(accessory:IAAccessoryVC!, toTransformer:IntensityTransformers)->Bool
    
    func accessoryRequestsPickerLaunch(accessory:IAAccessoryVC!)
    
    func accessoryUpdatedDefaultIntensity(accessory:IAAccessoryVC!, withValue value:Int)
    
    ///Return true to inform the iaAccessory that it should center the button associated with the smoothing tokenizer.
    func accessoryRequestsSmoothingChange(accessory:IAAccessoryVC!, toValue:IAStringTokenizing)->Bool
    
    func iaKeyboardIsShowing()->Bool

}