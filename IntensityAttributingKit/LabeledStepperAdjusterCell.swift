//
//  LabeledStepperAdjusterView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/24/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


///Configurable cell type used in the RawIntensity param adjustment cells. This one has a label with title, a stepper, and a label for results/value.
public class LabeledStepperAdjusterCell:UITableViewCell{
    
    @IBInspectable public var titleLabel:UILabel!
    @IBInspectable public var stepper:UIStepper!
    @IBInspectable public var resultLabel:UILabel!
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        titleLabel = aDecoder.decodeObjectForKey("titleLabel") as? UILabel
        stepper = aDecoder.decodeObjectForKey("stepper") as? UIStepper
        resultLabel = aDecoder.decodeObjectForKey("resultLabel") as? UILabel
        setupCell()
    }
    
    
    
    func setupCell(){
        if titleLabel == nil {
            titleLabel = UILabel(frame: CGRectZero)
        }
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(titleLabel)
        if stepper == nil {
            stepper = UIStepper(frame: CGRectZero)
        }
        stepper.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(stepper)
        if resultLabel == nil {
            resultLabel = UILabel(frame: CGRectZero)
        }
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(resultLabel)
        
        titleLabel.topAnchor.constraintEqualToAnchor(self.contentView.layoutMarginsGuide.topAnchor).active = true
        titleLabel.leadingAnchor.constraintEqualToAnchor(self.contentView.layoutMarginsGuide.leadingAnchor).active = true
        titleLabel.bottomAnchor.constraintLessThanOrEqualToAnchor(stepper.topAnchor, constant: -6).active = true
        
        stepper.bottomAnchor.constraintEqualToAnchor(self.contentView.layoutMarginsGuide.bottomAnchor).active = true
        stepper.leadingAnchor.constraintEqualToAnchor(self.contentView.layoutMarginsGuide.leadingAnchor).active = true
        
        resultLabel.bottomAnchor.constraintEqualToAnchor(self.contentView.layoutMarginsGuide.bottomAnchor).active = true
        resultLabel.leadingAnchor.constraintEqualToAnchor(stepper.leadingAnchor).active = true
        resultLabel.trailingAnchor.constraintEqualToAnchor(self.contentView.layoutMarginsGuide.trailingAnchor).active = true
        resultLabel.textAlignment = .Right
        
        stepper.addTarget(self, action: #selector(self.stepperValueChanged(_:)), forControlEvents: .ValueChanged)

        titleLabel.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
    }
 
    
    func stepperValueChanged(sender:UIStepper!){
        print("stepper value changed. Override me")
        
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(titleLabel, forKey: "titleLabel")
        aCoder.encodeObject(stepper, forKey: "stepper")
        aCoder.encodeObject(resultLabel, forKey: "resultLabel")
    }
}

