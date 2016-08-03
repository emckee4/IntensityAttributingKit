//
//  SmootherDefaultAdjuster.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/24/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///Prebaked tableview cell for adjusting the RawIntensity parameters within the keyboard options menu or otherwise.
public class SmootherOverrideAdjusterCell:LabeledStepperAdjusterCell{
    
    let adjustmentOptions:[(optionTitle:String,option:IAStringTokenizing?)] = [(optionTitle: "Message Default" ,option: nil ),(optionTitle: "By Character" ,option: IAStringTokenizing.Char ),(optionTitle: "By Word" ,option: IAStringTokenizing.Word ),(optionTitle: "By Sentence" ,option: IAStringTokenizing.Sentence ),(optionTitle: "By Message" ,option: IAStringTokenizing.Message )]

    
    override func setupCell() {
        super.setupCell()
        
        stepper.minimumValue = 0
        stepper.maximumValue = Double(adjustmentOptions.count - 1)
        stepper.continuous = false
        stepper.stepValue = 1.0
        
        
        let currentValue = IAKitPreferences.overridesTokenizer
        
        let aoIndex = adjustmentOptions.indexOf({$0.option == currentValue}) ?? 0
        stepper.value = Double(aoIndex)
        resultLabel.text = adjustmentOptions[aoIndex].optionTitle
        
        titleLabel.text = "Smoother Override:"
    }
    
    override func stepperValueChanged(sender: UIStepper!) {
        let val = clamp(Int(stepper.value), lowerBound: 0, upperBound: adjustmentOptions.count - 1)
        
        resultLabel.text = adjustmentOptions[val].optionTitle
        IAKitPreferences.overridesTokenizer = adjustmentOptions[val].option
        
    }
    
    
    
}
