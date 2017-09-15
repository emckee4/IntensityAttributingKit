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
    
    func kbSwitchButtonPressed(_ sender:UIButton!){
        delegate?.accessoryKeyboardChangeButtonPressed(self)
    }
    
    func attachmentButtonPressed(_ actionName:String!){
        self.delegate?.accessoryRequestsPickerLaunch(self, pickerName: actionName)
    }
    
    
    func optionButtonPressed(){
        delegate?.accessoryOptionButtonPressed(self)
    }
    
    func tokenizerButtonPressed(_ actionName:String!){
        guard let tokenizer = IAStringTokenizing(withName: actionName) else {return}
        if self.delegate?.accessoryRequestsSmoothingChange(self, toValue: tokenizer) ?? false {
            tokenizerButton.centerKeyWithActionName(actionName)
        }
    }
    
    func transformButtonPressed(_ actionName:String!){
        guard let transformer = IntensityTransformers(rawOptional: actionName) else {return}
        if self.delegate?.accessoryRequestsTransformerChange(self, toTransformer:transformer) ?? false {
            self.transformButton.centerKeyWithActionName(actionName)
        }
    }
    
    func sliderValueChanged(_ slider:UISlider!){
        let value = clamp(Int(round(slider.value)), lowerBound: 0, upperBound: 100)
        self.delegate?.accessoryUpdatedDefaultIntensity(self ,withValue: value)
    }
    
    func updateDisplayedIntensity(_ toValue:Int){
        self.intensityButton.text = "\(toValue)"
        self.intensitySlider.value = Float(toValue)
    }
    
    func pressureKeyPressed(_ sender: PressureControl, actionName: String, intensity: Int) {
        guard actionName == "intensityButtonPressed" else {assertionFailure(); return}
        self.delegate?.accessoryUpdatedDefaultIntensity(self, withValue: intensity)
    }
    
    func setTransformKeyForScheme(_ transformerScheme:IntensityTransformers){
        self.transformButton.centerKeyWithActionName(transformerScheme.rawValue)
    }
    
    func setTokenizerKeyValue(_ value:IAStringTokenizing){
        tokenizerButton.centerKeyWithActionName(value.shortLabel)
    }
    
}

    




