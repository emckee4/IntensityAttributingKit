//
//  IAccessoryInterface.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/5/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit






extension IAAccessoryVC: PressureKeyActionDelegate {
    
    
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
    
    func tokenizerButtonPressed(actionName:String!){
        guard let tokenizer = IAStringTokenizing(shortLabel: actionName) else {return}
        self.delegate?.requestTokenizerChange(tokenizer)
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
    
    func setTokenizerKeyValue(value:IAStringTokenizing){
        tokenizerButton.centerKeyWithActionName(value.shortLabel)
    }
    
//    func intensityLockButtonPressed(newValue:Bool){
//        self.delegate?.iaAccessoryDidSetIntensityLock(newValue)
//    }
    func sliderValueChanged(slider:UISlider!){
        self.delegate?.defaultIntensityUpdated(withValue: Int(slider.value))
    }
    
    func updateDisplayedIntensity(toValue:Int){
        self.intensityButton.text = "\(toValue)"
        self.intensitySlider.value = Float(toValue)
    }
    
    func pressureKeyPressed(sender: PressureControl, actionName: String, intensity: Int) {
        guard actionName == "intensityButtonPressed" else {assertionFailure(); return}
        self.delegate?.defaultIntensityUpdated(withValue: intensity)
    }
    
    /*
    NSStringEnumerationByLines = 0,
    NSStringEnumerationByParagraphs = 1,
    NSStringEnumerationByComposedCharacterSequences = 2,
    NSStringEnumerationByWords = 3,
    NSStringEnumerationBySentences = 4,
    
    */
    
}

///IAAccessoryDelegate delivers actions from the IAAccessory to the IATextView
protocol IAAccessoryDelegate:class {
    func keyboardChangeButtonPressed()
    
    func optionButtonPressed()
    func requestTransformerChange(toTransformerWithName name:String)

    func requestPickerLaunch()
    
    func defaultIntensityUpdated(withValue value:Int)
    
    func requestTokenizerChange(toValue:IAStringTokenizing)
    
    func iaKeyboardIsShowing()->Bool
    
    ///The user has pressed the iaAccessory lock intensity button.
//    func iaAccessoryDidSetIntensityLock(toValue:Bool)
}
    




