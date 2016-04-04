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
        self.itemDescriptionLabel.text = "Provides a linear mapping of the raw intensity after scaling for changes in the threshold and ceiling."
        thresholdSV = LabeledSliderView(labelText: "Threshold", sliderMin: 0.0, sliderMax: 0.4, sliderValue: LinearMapping.threshold)
        contentStackView.addArrangedSubview(thresholdSV)
        thresholdSV.slider.addTarget(self, action: "updateRIM:", forControlEvents: .ValueChanged)
        
        ceilingSV = LabeledSliderView(labelText: "Ceiling", sliderMin: 0.6, sliderMax: 1.0, sliderValue: LinearMapping.ceiling)
        contentStackView.addArrangedSubview(ceilingSV)
        ceilingSV.slider.addTarget(self, action: "updateRIM:", forControlEvents: .ValueChanged)
        itemDescriptionLabel.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateRIM(slider:UISlider!){
        LinearMapping.threshold = thresholdSV.value
        LinearMapping.ceiling = ceilingSV.value
        IAKitPreferences.rawIntensityMapper = RawIntensityMapping.Linear
    }

    
}