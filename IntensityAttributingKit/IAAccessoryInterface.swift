//
//  IAccessoryInterface.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/5/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit






extension IAAccessoryVC: IntensityAdjusterDelegate {
    
    
    //MARK:- user interface actions
    
    func kbSwitchButtonPressed(sender:UIButton!){
        delegate?.keyboardChangeButtonPressed()
    }
    
    func cameraButtonPressed(sender:UIButton){
        self.delegate?.requestPickerLaunch()
    }
    
    
    func optionButtonPressed(){
        delegate?.optionButtonPressed()
    }
    
    func transformButtonPressed(actionName:String!){
        if IntensityTransformers(rawValue: actionName) != nil {
            self.delegate?.requestTransformerChange(toTransformerWithName: actionName)
        }
    }
    
//    func pressureKeyPressed(sender: PressureControl, actionName: String, actionType: PressureKeyActionType, intensity: Float) {
//
//    }
    
    func setTransformKeyForScheme(withName schemeName:String){
        self.transformButton.centerKeyWithActionName(schemeName)
    }
    
    
    func intensityLockButtonPressed(newValue:Bool){
        self.delegate?.iaAccessoryDidSetIntensityLock(newValue)
    }
    func intensityAdjusted(toValue:Int){
        self.delegate?.defaultIntensityUpdated(withValue: toValue)
    }
    
    func updateDisplayedIntensity(toValue:Int){
        self.intensityAdjuster.defaultIntensity = toValue
    }
}

///IAAccessoryDelegate delivers actions from the IAAccessory to the IATextView
protocol IAAccessoryDelegate:class {
    func keyboardChangeButtonPressed()
    
    func optionButtonPressed()
    func requestTransformerChange(toTransformerWithName name:String)

    func requestPickerLaunch()
    
    func defaultIntensityUpdated(withValue value:Int)
    
    
    ///The user has pressed the iaAccessory lock intensity button.
    func iaAccessoryDidSetIntensityLock(toValue:Bool)
}
    




