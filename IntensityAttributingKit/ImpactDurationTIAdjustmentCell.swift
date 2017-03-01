//
//  ImpactDurationAdjustmentCell.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/15/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///Prebaked tableview cell for adjusting the RawIntensity parameters within the keyboard options menu or otherwise.
final class ImpactDurationTIAdjustmentCell:RawIntensityAdjustmentCellBase {
    
    var durationMultiplierSV:LabeledSliderView!
    var impactMultiplierSV:LabeledSliderView!
    ///Not currently adjustable by users but might be exposed later:
    //var impactExponent
    //var constantCoeficient
    
    override init() {
        super.init()
        self.itemDescriptionLabel.text = "Uses a combination of G-force data from the accelerometer and touch duration data to interpret intensities. Sharp taps and long holds will produce high values while light, quick taps will produce low values."
        durationMultiplierSV = LabeledSliderView(labelText: "DurationMultiplier", sliderMin: 0.0, sliderMax: 4.0, sliderValue: ImpactDurationTouchInterpreter.durationMultiplier)
        impactMultiplierSV = LabeledSliderView(labelText: "ImpactMultiplier", sliderMin: 0.0, sliderMax: 2.0, sliderValue: ImpactDurationTouchInterpreter.impactMultiplier)
        contentStackView.addArrangedSubview(impactMultiplierSV)
        contentStackView.addArrangedSubview(durationMultiplierSV)
        
        durationMultiplierSV.slider.addTarget(self, action: #selector(ImpactDurationTIAdjustmentCell.updateDurationMultiplier(_:)), for: .valueChanged)
        impactMultiplierSV.slider.addTarget(self, action: #selector(ImpactDurationTIAdjustmentCell.updateImpactMultiplier(_:)), for: .valueChanged)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateDurationMultiplier(_ slider:UISlider!){
        ImpactDurationTouchInterpreter.durationMultiplier = slider.value
    }
    func updateImpactMultiplier(_ slider:UISlider!){
        ImpactDurationTouchInterpreter.impactMultiplier = slider.value
    }
    
    
}
