//
//  LabeledStepperAdjusterView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/24/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


///Configurable cell type used in the RawIntensity param adjustment cells. This one has a label with title, a stepper, and a label for results/value.
open class LabeledStepperAdjusterCell:UITableViewCell{
    
    @IBInspectable open var titleLabel:UILabel!
    @IBInspectable open var stepper:UIStepper!
    @IBInspectable open var resultLabel:UILabel!
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        titleLabel = aDecoder.decodeObject(forKey: "titleLabel") as? UILabel
        stepper = aDecoder.decodeObject(forKey: "stepper") as? UIStepper
        resultLabel = aDecoder.decodeObject(forKey: "resultLabel") as? UILabel
        setupCell()
    }
    
    
    
    func setupCell(){
        if titleLabel == nil {
            titleLabel = UILabel(frame: CGRect.zero)
        }
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(titleLabel)
        if stepper == nil {
            stepper = UIStepper(frame: CGRect.zero)
        }
        stepper.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(stepper)
        if resultLabel == nil {
            resultLabel = UILabel(frame: CGRect.zero)
        }
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(resultLabel)
        
        titleLabel.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: stepper.topAnchor, constant: -6).isActive = true
        
        stepper.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        stepper.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        
        resultLabel.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        resultLabel.leadingAnchor.constraint(equalTo: stepper.leadingAnchor).isActive = true
        resultLabel.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        resultLabel.textAlignment = .right
        
        stepper.addTarget(self, action: #selector(self.stepperValueChanged(_:)), for: .valueChanged)

        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
    }
 
    
    func stepperValueChanged(_ sender:UIStepper!){
        print("stepper value changed. Override me")
        
    }
    
    open override func encode(with aCoder: NSCoder) {
        aCoder.encode(titleLabel, forKey: "titleLabel")
        aCoder.encode(stepper, forKey: "stepper")
        aCoder.encode(resultLabel, forKey: "resultLabel")
    }
}

