//
//  LabeledSliderViews.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/15/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///Configurable cell type used in the RawIntensity param adjustment cells. This one has a label with title, a slider, and a value/result label.
class LabeledSliderView: UIView {
    
    var slider:UISlider!
    var label:UILabel!
    var resultLabel:UILabel!
    var resultFormat = "%.2f"
    
    
    var value:Float {
        get{return slider.value}
        set{setSliderValue(newValue)}
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        self.translatesAutoresizingMaskIntoConstraints = false
        slider = UISlider(frame: CGRectZero)
        slider.translatesAutoresizingMaskIntoConstraints = false
        label = UILabel(frame: CGRectZero)
        label.translatesAutoresizingMaskIntoConstraints = false
        resultLabel = UILabel(frame: CGRectZero)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(slider)
        self.addSubview(label)
        self.addSubview(resultLabel)
        
        label.font = UIFont.systemFontOfSize(18.0, weight: UIFontWeightMedium)
        label.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 2.0).active = true
        label.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor, constant: 8.0).active = true
        label.bottomAnchor.constraintLessThanOrEqualToAnchor(self.bottomAnchor).active = true
        label.widthAnchor.constraintGreaterThanOrEqualToConstant(60).active = true
        
        resultLabel.font = UIFont.systemFontOfSize(20.0)
        resultLabel.textAlignment = .Center
        resultLabel.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 12.0).active = true
        resultLabel.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor, constant: 2.0).active = true
        resultLabel.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: 2.0).active = true
        resultLabel.widthAnchor.constraintGreaterThanOrEqualToConstant(40).active = true
        
        
        slider.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 16.0).active = true
        slider.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor, constant: 2.0).active = true
        slider.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: 2.0).active = true
        slider.trailingAnchor.constraintEqualToAnchor(resultLabel.leadingAnchor, constant: -8).active = true
        
        slider.addTarget(self, action: #selector(self.sliderUpdated(_:)), forControlEvents: .ValueChanged)
        
        self.heightAnchor.constraintGreaterThanOrEqualToConstant(44).activateWithPriority(999,identifier: "LabeledSliderView minimum height")
        self.widthAnchor.constraintGreaterThanOrEqualToConstant(200).activateWithPriority(999, identifier: "LabeledSliderView minimum width")
    }

    
    ///Updates ressultLabel. Owning VC will be expected to add additional targets to actually do something with the changes
    @objc private func sliderUpdated(slider:UISlider!){
        resultLabel.text = String(format: resultFormat, slider.value)
    }
    
    func setSliderValue(value:Float, animated:Bool = false){
        //update slider + label
        slider.setValue(value, animated: animated)
        resultLabel.text = String(format: resultFormat, value)
    }
    
    convenience init(labelText:String,sliderMin:Float,sliderMax:Float, sliderValue:Float? = nil){
        self.init(frame:CGRectZero)
        label.text = labelText
        slider.minimumValue = sliderMin
        slider.maximumValue = sliderMax
        setSliderValue(sliderValue ?? sliderMin)
    }
    
}
