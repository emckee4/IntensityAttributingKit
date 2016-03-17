//
//  DurationAdjustmentCell.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/15/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

final class DurationTIAdjustmentCell:RawIntensityAdjustmentCellBase {
    
    
    var durationMultiplierSV:LabeledSliderView!
    
    
    override init() {
        super.init()
        //self.translatesAutoresizingMaskIntoConstraints = false
        //self.textLabel?.text = "Duration"
        self.itemDescriptionLabel.text = "Touch intensity is a function of touch duration. Longer touches yield higher intensities."
        durationMultiplierSV = LabeledSliderView(labelText: "DurationMultiplier", sliderMin: 0.0, sliderMax: 4.0, sliderValue: DurationTouchInterpreter.durationMultiplier)
        contentStackView.addArrangedSubview(durationMultiplierSV)
        durationMultiplierSV.slider.addTarget(self, action: "updateDurationMultiplier:", forControlEvents: .ValueChanged)
        //itemDescriptionTextView.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateDurationMultiplier(slider:UISlider!){
        DurationTouchInterpreter.durationMultiplier = slider.value
    }

    
    
}