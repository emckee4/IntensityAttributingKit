//
//  IAAccessoryVC.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/26/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

class IAAccessoryVC: UIInputViewController {

    
    var kbSwitchButton:UIButton!
    //var slider:UISlider!
    var intensityAdjuster:IntensityAdjuster!
    var optionButton:UIButton!
    
    var delegate:IAAccessoryDelegate?
    
    private lazy var bundle:NSBundle = { return NSBundle(forClass: self.dynamicType) }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.inputView!.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 41)
        self.inputView!.translatesAutoresizingMaskIntoConstraints = false
        
        kbSwitchButton = UIButton(type: .System)
        kbSwitchButton.setImage(UIImage(named: "Keyboard", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal )
        kbSwitchButton.imageView?.contentMode = .ScaleAspectFit
        kbSwitchButton.backgroundColor = UIColor.blueColor()
        kbSwitchButton.imageEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        kbSwitchButton.addTarget(self, action: "kbSwitchButtonPressed:", forControlEvents: .TouchUpInside)
        kbSwitchButton.translatesAutoresizingMaskIntoConstraints = false
        inputView!.addSubview(kbSwitchButton)
        kbSwitchButton.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor, multiplier: 0.12).active = true
       
//        slider = UISlider(frame:CGRectZero)
//        slider.value = 0.4
//        slider.addTarget(self, action: "sliderUpdatedWithValue:", forControlEvents: .ValueChanged)
        intensityAdjuster = IntensityAdjuster()
        intensityAdjuster.translatesAutoresizingMaskIntoConstraints = false
        intensityAdjuster.commonBackgroundColor = UIColor.lightGrayColor()
        inputView!.addSubview(intensityAdjuster)
        
        optionButton = UIButton(type: .Custom)
        optionButton.backgroundColor = UIColor.greenColor()
        optionButton.setTitle("Options", forState: .Normal)
        optionButton.addTarget(self, action: "optionButtonPressed", forControlEvents: .TouchUpInside)
        optionButton.translatesAutoresizingMaskIntoConstraints = false
        inputView!.addSubview(optionButton)
        
        //self.view.backgroundColor = UIColor.blackColor()
        //self.view.translatesAutoresizingMaskIntoConstraints = false
        
        setConstraints()
    }
    
    func setConstraints(){
        kbSwitchButton.topAnchor.constraintEqualToAnchor(inputView!.topAnchor).active = true
        
        kbSwitchButton.bottomAnchor.constraintEqualToAnchor(inputView!.bottomAnchor).active = true
        kbSwitchButton.leadingAnchor.constraintEqualToAnchor(inputView!.leadingAnchor).active = true
        
        intensityAdjuster.leadingAnchor.constraintEqualToAnchor(kbSwitchButton.trailingAnchor, constant: 5.0).active = true
        
        intensityAdjuster.topAnchor.constraintGreaterThanOrEqualToAnchor(inputView!.topAnchor, constant: 1.0).active = true
        intensityAdjuster.bottomAnchor.constraintLessThanOrEqualToAnchor(inputView!.bottomAnchor, constant: -1.0).active = true
        
        optionButton.leadingAnchor.constraintGreaterThanOrEqualToAnchor(intensityAdjuster.trailingAnchor, constant: 2.0).active = true
        
        optionButton.topAnchor.constraintEqualToAnchor(inputView!.topAnchor).active = true
        optionButton.bottomAnchor.constraintEqualToAnchor(inputView!.bottomAnchor).active = true
        optionButton.widthAnchor.constraintEqualToConstant(60.0).active = true
        optionButton.trailingAnchor.constraintEqualToAnchor(inputView!.trailingAnchor, constant: -1.0).active = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        layoutForBounds(UIScreen.mainScreen().bounds.size)

    }
    
    func layoutForBounds(size:CGSize){
        if !intensityAdjuster.forceTouchAvailable {
            intensityAdjuster.showPressureSlider = true
            intensityAdjuster.showPressurePad = false
        } else if size.width > size.height {
            intensityAdjuster.showPressureSlider = true
            intensityAdjuster.showPressurePad = true
        } else {
            intensityAdjuster.showPressurePad = true
            intensityAdjuster.showPressureSlider = false
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func kbSwitchButtonPressed(sender:UIButton!){
        print("accessory view frame \(self.inputView!.frame)")
        delegate?.keyboardChangeButtonPressed()
    }
    
//    func defaultIntensityUpdatedWithValue(sender:UISlider!){
//        delegate?.sliderUpdatedWithValue(sender.value)
//    }
    
    func optionButtonPressed(){
        delegate?.optionButtonPressed()
    }
    

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        layoutForBounds(size)
    }


}

protocol IAAccessoryDelegate {
    func keyboardChangeButtonPressed()
    //func sliderUpdatedWithValue(value:Float)
    func optionButtonPressed()
}