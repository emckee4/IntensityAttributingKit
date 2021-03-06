//
//  LinearRIMAdjustmentCell.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/15/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///Prebaked tableview cell for adjusting the RawIntensity parameters within the keyboard options menu or otherwise.
final class LinearRIMAdjustmentCell:RawIntensityAdjustmentCellBase {
    
    var thresholdSV:LabeledSliderView!
    var ceilingSV:LabeledSliderView!

    
    override init() {
        super.init()
        self.itemDescriptionLabel.text = "Provides a linear mapping of the raw intensity after scaling for changes in the threshold and ceiling."
        thresholdSV = LabeledSliderView(labelText: "Threshold", sliderMin: 0.0, sliderMax: 0.4, sliderValue: LinearMapping.threshold)
        contentStackView.addArrangedSubview(thresholdSV)
        thresholdSV.slider.addTarget(self, action: #selector(LinearRIMAdjustmentCell.updateRIM(_:)), for: .valueChanged)
        
        ceilingSV = LabeledSliderView(labelText: "Ceiling", sliderMin: 0.6, sliderMax: 1.0, sliderValue: LinearMapping.ceiling)
        contentStackView.addArrangedSubview(ceilingSV)
        ceilingSV.slider.addTarget(self, action: #selector(LinearRIMAdjustmentCell.updateRIM(_:)), for: .valueChanged)
        itemDescriptionLabel.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateRIM(_ slider:UISlider!){
        LinearMapping.threshold = thresholdSV.value
        LinearMapping.ceiling = ceilingSV.value
        IAKitPreferences.rawIntensityMapper = RawIntensityMapping.Linear
    }

    
}
