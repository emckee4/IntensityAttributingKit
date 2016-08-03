//
//  IAccessoryInterface.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/5/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit





///This is the primary interface between the accessory and the IACompositeTextEditor
extension IAAccessoryVC: PressureKeyActionDelegate {
    
    
    //MARK:- user interface actions
    
    func kbSwitchButtonPressed(sender:UIButton!){
        delegate?.accessoryKeyboardChangeButtonPressed(self)
    }
    
    func cameraButtonPressed(sender:UIButton){
        self.delegate?.accessoryRequestsPickerLaunch(self)
    }
    
    
    func optionButtonPressed(){
        delegate?.accessoryOptionButtonPressed(self)
    }
    
    func tokenizerButtonPressed(actionName:String!){
        guard let tokenizer = IAStringTokenizing(shortLabel: actionName) else {return}
        if self.delegate?.accessoryRequestsSmoothingChange(self, toValue: tokenizer) ?? false {
            tokenizerButton.centerKeyWithActionName(actionName)
        }
    }
    
    func transformButtonPressed(actionName:String!){
        guard let transformer = IntensityTransformers(rawOptional: actionName) else {return}
        if self.delegate?.accessoryRequestsTransformerChange(self, toTransformer:transformer) ?? false {
            self.transformButton.centerKeyWithActionName(actionName)
        }
    }
    
    func sliderValueChanged(slider:UISlider!){
        let value = clamp(Int(round(slider.value)), lowerBound: 0, upperBound: 100)
        self.delegate?.accessoryUpdatedDefaultIntensity(self ,withValue: value)
    }
    
    func updateDisplayedIntensity(toValue:Int){
        self.intensityButton.text = "\(toValue)"
        self.intensitySlider.value = Float(toValue)
    }
    
    func pressureKeyPressed(sender: PressureControl, actionName: String, intensity: Int) {
        guard actionName == "intensityButtonPressed" else {assertionFailure(); return}
        self.delegate?.accessoryUpdatedDefaultIntensity(self, withValue: intensity)
    }
    
    func setTransformKeyForScheme(transformerScheme:IntensityTransformers){
        self.transformButton.centerKeyWithActionName(transformerScheme.rawValue)
    }
    
    func setTokenizerKeyValue(value:IAStringTokenizing){
        tokenizerButton.centerKeyWithActionName(value.shortLabel)
    }
    
}

    




