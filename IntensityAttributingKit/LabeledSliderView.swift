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
        slider = UISlider(frame: CGRect.zero)
        slider.translatesAutoresizingMaskIntoConstraints = false
        label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        resultLabel = UILabel(frame: CGRect.zero)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(slider)
        self.addSubview(label)
        self.addSubview(resultLabel)
        
        label.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightMedium)
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: 2.0).isActive = true
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0).isActive = true
        label.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor).isActive = true
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        
        resultLabel.font = UIFont.systemFont(ofSize: 20.0)
        resultLabel.textAlignment = .center
        resultLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12.0).isActive = true
        resultLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 2.0).isActive = true
        resultLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 2.0).isActive = true
        resultLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        
        
        slider.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0).isActive = true
        slider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2.0).isActive = true
        slider.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 2.0).isActive = true
        slider.trailingAnchor.constraint(equalTo: resultLabel.leadingAnchor, constant: -8).isActive = true
        
        slider.addTarget(self, action: #selector(self.sliderUpdated(_:)), for: .valueChanged)
        
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).activateWithPriority(999,identifier: "LabeledSliderView minimum height")
        self.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).activateWithPriority(999, identifier: "LabeledSliderView minimum width")
    }

    
    ///Updates ressultLabel. Owning VC will be expected to add additional targets to actually do something with the changes
    @objc fileprivate func sliderUpdated(_ slider:UISlider!){
        resultLabel.text = String(format: resultFormat, slider.value)
    }
    
    func setSliderValue(_ value:Float, animated:Bool = false){
        //update slider + label
        slider.setValue(value, animated: animated)
        resultLabel.text = String(format: resultFormat, value)
    }
    
    convenience init(labelText:String,sliderMin:Float,sliderMax:Float, sliderValue:Float? = nil){
        self.init(frame:CGRect.zero)
        label.text = labelText
        slider.minimumValue = sliderMin
        slider.maximumValue = sliderMax
        setSliderValue(sliderValue ?? sliderMin)
    }
    
}
