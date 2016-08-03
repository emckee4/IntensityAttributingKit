//
//  DurationAdjustmentCell.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/15/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///Prebaked tableview cell for adjusting the RawIntensity parameters within the keyboard options menu or otherwise.
final class DurationTIAdjustmentCell:RawIntensityAdjustmentCellBase {
    
    
    var durationMultiplierSV:LabeledSliderView!
    
    
    override init() {
        super.init()
        self.itemDescriptionLabel.text = "Touch intensity is a function of touch duration. Longer touches yield higher intensities."
        durationMultiplierSV = LabeledSliderView(labelText: "DurationMultiplier", sliderMin: 0.0, sliderMax: 4.0, sliderValue: DurationTouchInterpreter.durationMultiplier)
        contentStackView.addArrangedSubview(durationMultiplierSV)
        durationMultiplierSV.slider.addTarget(self, action: "updateDurationMultiplier:", forControlEvents: .ValueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateDurationMultiplier(slider:UISlider!){
        DurationTouchInterpreter.durationMultiplier = slider.value
    }

    
    
}