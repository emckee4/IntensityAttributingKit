//
//  RenderOverrideAdjuster.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/24/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

@IBDesignable
public class RenderOverrideAdjusterCell:LabeledStepperAdjusterCell{
    
    let adjustmentOptions:[(optionTitle:String,option:IntensityTransformers?)] = [(optionTitle: "Message Default" ,option: nil ),(optionTitle: "Text Weight" ,option: IntensityTransformers.WeightScheme ),(optionTitle: "Text Color (GYR)" ,option: IntensityTransformers.HueGYRScheme ),(optionTitle: "Text Size" ,option: IntensityTransformers.FontSizeScheme ), (optionTitle: "Text Opacity" ,option: IntensityTransformers.AlphaScheme )]
    
    
    override func setupCell() {
        super.setupCell()
        
        stepper.minimumValue = 0
        stepper.maximumValue = Double(adjustmentOptions.count - 1)
        stepper.continuous = false
        stepper.stepValue = 1.0
        
        
        let currentValue = IAKitOptions.overridesTransformer
        
        let aoIndex = adjustmentOptions.indexOf({$0.option == currentValue}) ?? 0
        stepper.value = Double(aoIndex)
        resultLabel.text = adjustmentOptions[aoIndex].optionTitle
    
        titleLabel.text = "Render Scheme Override:"
    }
    
    override func stepperValueChanged(sender: UIStepper!) {
        let val = clamp(Int(stepper.value), lowerBound: 0, upperBound: adjustmentOptions.count - 1)
        
        resultLabel.text = adjustmentOptions[val].optionTitle
        IAKitOptions.overridesTransformer = adjustmentOptions[val].option
        
    }
    
    
    
}
