//
//  LinearRIMAdjustmentCell.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/15/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

final class LinearRIMAdjustmentCell:RawIntensityAdjustmentCellBase {
    
    var thresholdSV:LabeledSliderView!
    var ceilingSV:LabeledSliderView!

    
    override init() {
        super.init()

        var initialThreshold:Float = 0.0
        var initialCeiling:Float = 1.0
        let linearRIMDict = IAKitOptions.rawIntensityMapper.dictDescription
        if let ceil = (linearRIMDict["ceiling"] as? Float), thresh = (linearRIMDict["threshold"] as? Float) where (linearRIMDict["name"] as? String) == "Linear"{
            initialThreshold = thresh
            initialCeiling = ceil
        }

        self.itemDescriptionLabel.text = "Provides a linear mapping of the raw intensity after scaling for changes in the threshold and ceiling."
        thresholdSV = LabeledSliderView(labelText: "Threshold", sliderMin: 0.0, sliderMax: 0.4, sliderValue: initialThreshold)
        contentStackView.addArrangedSubview(thresholdSV)
        thresholdSV.slider.addTarget(self, action: "updateRIM:", forControlEvents: .ValueChanged)
        
        ceilingSV = LabeledSliderView(labelText: "Ceiling", sliderMin: 0.6, sliderMax: 1.0, sliderValue: initialCeiling)
        contentStackView.addArrangedSubview(ceilingSV)
        ceilingSV.slider.addTarget(self, action: "updateRIM:", forControlEvents: .ValueChanged)
        itemDescriptionLabel.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateRIM(slider:UISlider!){
        IAKitOptions.rawIntensityMapper = RawIntensityMapping.Linear(threshold: thresholdSV.value, ceiling: ceilingSV.value)
    }

    
}