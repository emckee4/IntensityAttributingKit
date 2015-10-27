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
    var slider:UISlider!
    var optionButton:UIButton!
    
    var delegate:IAAccessoryDelegate?
    
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.inputView!.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 41)
        self.inputView!.translatesAutoresizingMaskIntoConstraints = false
        
        kbSwitchButton = UIButton(type: .System)
        kbSwitchButton.setTitle("swapKB", forState: .Normal)
        kbSwitchButton.backgroundColor = UIColor.blueColor()
        kbSwitchButton.addTarget(self, action: "kbSwitchButtonPressed:", forControlEvents: .TouchUpInside)
        kbSwitchButton.translatesAutoresizingMaskIntoConstraints = false
        inputView!.addSubview(kbSwitchButton)
        
        slider = UISlider(frame:CGRectZero)
        slider.value = 0.4
        slider.addTarget(self, action: "sliderUpdatedWithValue:", forControlEvents: .ValueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        inputView!.addSubview(slider)
        
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
        
        slider.leadingAnchor.constraintEqualToAnchor(kbSwitchButton.trailingAnchor, constant: 5.0).active = true
        
        slider.topAnchor.constraintGreaterThanOrEqualToAnchor(inputView!.topAnchor, constant: 1.0).active = true
        slider.bottomAnchor.constraintLessThanOrEqualToAnchor(inputView!.bottomAnchor, constant: -1.0).active = true
        
        optionButton.leadingAnchor.constraintEqualToAnchor(slider.trailingAnchor, constant: 2.0).active = true
        
        optionButton.topAnchor.constraintEqualToAnchor(inputView!.topAnchor).active = true
        optionButton.bottomAnchor.constraintEqualToAnchor(inputView!.bottomAnchor).active = true
        
        optionButton.trailingAnchor.constraintEqualToAnchor(inputView!.trailingAnchor, constant: -1.0).active = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func kbSwitchButtonPressed(sender:UIButton!){
        print("accessory view frame \(self.inputView!.frame)")
        delegate?.keyboardChangeButtonPressed()
    }
    
    func sliderUpdatedWithValue(sender:UISlider!){
        delegate?.sliderUpdatedWithValue(sender.value)
    }
    
    func optionButtonPressed(){
        delegate?.optionButtonPressed()
    }
    

    


}

protocol IAAccessoryDelegate {
    func keyboardChangeButtonPressed()
    func sliderUpdatedWithValue(value:Float)
    func optionButtonPressed()
}