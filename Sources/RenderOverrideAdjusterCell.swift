//
//  RenderOverrideAdjuster.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/24/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///Prebaked tableview cell for adjusting the RawIntensity parameters within the keyboard options menu or otherwise.
open class RenderOverrideAdjusterCell:LabeledStepperAdjusterCell{
    
    let adjustmentOptions:[(optionTitle:String,option:IntensityTransformers?)] = [(optionTitle: "Message Default" ,option: nil ),(optionTitle: "Text Weight" ,option: IntensityTransformers.WeightScheme ),(optionTitle: "Text Color (GYR)" ,option: IntensityTransformers.HueGYRScheme ),(optionTitle: "Text Size" ,option: IntensityTransformers.FontSizeScheme ), (optionTitle: "Text Opacity" ,option: IntensityTransformers.AlphaScheme )]
    
    
    override func setupCell() {
        super.setupCell()
        
        stepper.minimumValue = 0
        stepper.maximumValue = Double(adjustmentOptions.count - 1)
        stepper.isContinuous = false
        stepper.stepValue = 1.0
        
        
        let currentValue = IAKitPreferences.overridesTransformer
        
        let aoIndex = adjustmentOptions.index(where: {$0.option == currentValue}) ?? 0
        stepper.value = Double(aoIndex)
        resultLabel.text = adjustmentOptions[aoIndex].optionTitle
    
        titleLabel.text = "Render Scheme Override:"
    }
    
    override func stepperValueChanged(_ sender: UIStepper!) {
        let val = clamp(Int(stepper.value), lowerBound: 0, upperBound: adjustmentOptions.count - 1)
        
        resultLabel.text = adjustmentOptions[val].optionTitle
        IAKitPreferences.overridesTransformer = adjustmentOptions[val].option
        
    }
    
    
    
}
