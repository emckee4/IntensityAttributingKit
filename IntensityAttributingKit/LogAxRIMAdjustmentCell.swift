//
//  LogAxRIMAdjustmentCell.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/15/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

final class LogAxRIMAdjustmentCell:RawIntensityAdjustmentCellBase {

    var thresholdSV:LabeledSliderView!
    var ceilingSV:LabeledSliderView!
    var aParamSV:LabeledSliderView!
    
    override init() {
        super.init()
        
        var initialThreshold:Float = 0.0
        var initialCeiling:Float = 1.0
        var initialA:Float = 10.0
        let rimDict = IAKitOptions.rawIntensityMapper.dictDescription
        if let ceil = (rimDict["ceiling"] as? Float), thresh = (rimDict["threshold"] as? Float), aParam = (rimDict["a"] as? Float)  where (rimDict["name"] as? String) == "LogAx"{
            initialThreshold = thresh
            initialCeiling = ceil
            initialA = aParam
        }
        
        self.itemDescriptionLabel.text = "Provides a logarithmic mapping of raw intensity in the form Log(1 + ax) scaled between the threshold and ceiling."
        thresholdSV = LabeledSliderView(labelText: "Threshold", sliderMin: 0.0, sliderMax: 0.4, sliderValue: initialThreshold)
        contentStackView.addArrangedSubview(thresholdSV)
        thresholdSV.slider.addTarget(self, action: "updateRIM:", forControlEvents: .ValueChanged)
        
        ceilingSV = LabeledSliderView(labelText: "Ceiling", sliderMin: 0.6, sliderMax: 1.0, sliderValue: initialCeiling)
        contentStackView.addArrangedSubview(ceilingSV)
        ceilingSV.slider.addTarget(self, action: "updateRIM:", forControlEvents: .ValueChanged)
        
        aParamSV = LabeledSliderView(labelText: "\"a\" Parameter", sliderMin: 1, sliderMax: 100.0, sliderValue: initialA)
        contentStackView.addArrangedSubview(ceilingSV)
        aParamSV.slider.addTarget(self, action: "updateRIM:", forControlEvents: .ValueChanged)
        itemDescriptionLabel.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateRIM(slider:UISlider!){
        IAKitOptions.rawIntensityMapper = RawIntensityMapping.LogAx(a: aParamSV.value, threshold: thresholdSV.value, ceiling: ceilingSV.value)
    }
    
    
}
