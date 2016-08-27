//
//  LogAxRIMAdjustmentCell.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/15/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///Prebaked tableview cell for adjusting the RawIntensity parameters within the keyboard options menu or otherwise.
final class LogAxRIMAdjustmentCell:RawIntensityAdjustmentCellBase {

    var thresholdSV:LabeledSliderView!
    var ceilingSV:LabeledSliderView!
    var aParamSV:LabeledSliderView!
    
    override init() {
        super.init()

        self.itemDescriptionLabel.text = "Provides a logarithmic mapping of raw intensity in the form Log(1 + ax) scaled between the threshold and ceiling."
        thresholdSV = LabeledSliderView(labelText: "Threshold", sliderMin: 0.0, sliderMax: 0.4, sliderValue: LogAxMapping.threshold)
        contentStackView.addArrangedSubview(thresholdSV)
        thresholdSV.slider.addTarget(self, action: #selector(LogAxRIMAdjustmentCell.updateRIM(_:)), forControlEvents: .ValueChanged)
        
        ceilingSV = LabeledSliderView(labelText: "Ceiling", sliderMin: 0.6, sliderMax: 1.0, sliderValue: LogAxMapping.ceiling)
        contentStackView.addArrangedSubview(ceilingSV)
        ceilingSV.slider.addTarget(self, action: #selector(LogAxRIMAdjustmentCell.updateRIM(_:)), forControlEvents: .ValueChanged)
        
        aParamSV = LabeledSliderView(labelText: "\"a\" Parameter", sliderMin: 1, sliderMax: 100.0, sliderValue: LogAxMapping.aParam)
        contentStackView.addArrangedSubview(ceilingSV)
        aParamSV.slider.addTarget(self, action: #selector(LogAxRIMAdjustmentCell.updateRIM(_:)), forControlEvents: .ValueChanged)
        itemDescriptionLabel.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateRIM(slider:UISlider!){
        LogAxMapping.threshold = thresholdSV.value
        LogAxMapping.ceiling = ceilingSV.value
        LogAxMapping.aParam = aParamSV.value
        IAKitPreferences.rawIntensityMapper = RawIntensityMapping.LogAx
    }
    
    
}
