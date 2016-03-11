//
//  TempSettingVC.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/8/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

public class TempSettingVC: UIViewController, UITextFieldDelegate, PressureKeyActionDelegate {

    
    var dismissButton:UIButton!
    var touchInterpreterEK:ExpandingKeyControl!
    var rimEK:ExpandingKeyControl!
    var rimA:UISlider!
    var rimThresh:UISlider!
    var rimCeil:UISlider!
    
    var testButton:PressureKey!
    //var rawDisplay:UILabel!
    var resultDisplay:UILabel!
    
    //add override testing options?
    
    
    var mainStackView:UIStackView!
    
    var rimParamStackView:UIStackView!
    
    var testStackView:UIStackView!
    
    var currentRim = IAKitOptions.rawIntensityMapper
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        dismissButton = UIButton(type: .Custom)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.setTitle("Dismiss", forState: .Normal)
        dismissButton.sizeToFit()
        dismissButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        
        touchInterpreterEK = ExpandingKeyControl()
        touchInterpreterEK.backgroundColor = UIColor.redColor()
        touchInterpreterEK.translatesAutoresizingMaskIntoConstraints = false
        touchInterpreterEK.expansionDirection = .Right
        if IAKitOptions.forceTouchAvailable {
            touchInterpreterEK.addKey(withTextLabel: "Force", actionName: "Force")
        }
        touchInterpreterEK.addKey(withTextLabel: "Radius", actionName: "Radius")
        touchInterpreterEK.addKey(withTextLabel: "Duration", actionName: "Duration")
        touchInterpreterEK.setSelector(self, selector: "tiChosen:")
        touchInterpreterEK.selectedBecomesFirst = true
        
        //
        rimEK = ExpandingKeyControl()
        rimEK.translatesAutoresizingMaskIntoConstraints = false
        rimEK.expansionDirection = .Right
        rimEK.addKey(withTextLabel: "Linear", actionName: "Linear")
        rimEK.addKey(withTextLabel: "LogAx", actionName: "LogAx")
        rimEK.setSelector(self, selector: "rimChosen:")
        rimEK.selectedBecomesFirst = true
        rimEK.backgroundColor = UIColor.purpleColor()
        rimEK.setContentHuggingPriority(1000, forAxis: .Horizontal)
        
        ///
        
        rimA = UISlider(frame: CGRectZero)
        rimA.translatesAutoresizingMaskIntoConstraints = false
        rimA.tag = 1
        rimA.minimumValue = 1
        rimA.maximumValue = 100
        rimA.addTarget(self, action: "rimParamChanged:", forControlEvents: .ValueChanged)
        
        
        rimThresh = UISlider(frame: CGRectZero)
        rimThresh.translatesAutoresizingMaskIntoConstraints = false
        rimThresh.tag = 2
        rimThresh.value = 0.0
        rimThresh.minimumValue = 0
        rimThresh.maximumValue = 0.4
        rimThresh.addTarget(self, action: "rimParamChanged:", forControlEvents: .ValueChanged)
     
        rimCeil = UISlider(frame: CGRectZero)
        rimCeil.translatesAutoresizingMaskIntoConstraints = false
        rimCeil.tag = 3
        rimCeil.minimumValue = 0.6
        rimCeil.maximumValue = 1.0
        rimCeil.value = 1.0
        rimCeil.addTarget(self, action: "rimParamChanged:", forControlEvents: .ValueChanged)
        
        
        testButton = PressureKey()
        testButton.translatesAutoresizingMaskIntoConstraints = false
        testButton.setCharKey("test")
        testButton.sizeToFit()
        testButton.delegate = self
        testButton.widthAnchor.constraintEqualToConstant(50).activateWithPriority(1000)
        
        resultDisplay = UILabel(frame: CGRectZero)
        resultDisplay.translatesAutoresizingMaskIntoConstraints = false
        resultDisplay.text = " \(0)"
        resultDisplay.widthAnchor.constraintEqualToConstant(50).activateWithPriority(1000)
        
        testStackView = UIStackView(arrangedSubviews: [resultDisplay,testButton])
        testStackView.translatesAutoresizingMaskIntoConstraints = false
        testStackView.axis = .Horizontal
        testStackView.distribution = .EqualCentering
        
        
        mainStackView = UIStackView(arrangedSubviews: [dismissButton,touchInterpreterEK,rimEK,rimA,rimThresh,rimCeil,testStackView])
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .Vertical
        mainStackView.alignment = .Center
        mainStackView.distribution = .EqualSpacing
        mainStackView.backgroundColor = UIColor.lightGrayColor()
        
        //self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mainStackView)
        self.view.backgroundColor = UIColor.lightGrayColor()
        
        mainStackView.topAnchor.constraintEqualToAnchor(self.topLayoutGuide.bottomAnchor    ).active = true
        mainStackView.bottomAnchor.constraintEqualToAnchor(self.bottomLayoutGuide.topAnchor).active = true
        mainStackView.leadingAnchor.constraintEqualToAnchor(self.view.layoutMarginsGuide.leadingAnchor).active = true
        mainStackView.trailingAnchor.constraintEqualToAnchor(self.view.layoutMarginsGuide.trailingAnchor).active = true
        
        
        testStackView.widthAnchor.constraintEqualToAnchor(mainStackView.widthAnchor, constant:-20).activateWithPriority(900)
        rimA.widthAnchor.constraintEqualToAnchor(mainStackView.widthAnchor, constant:-20).activateWithPriority(900)
        rimThresh.widthAnchor.constraintEqualToAnchor(mainStackView.widthAnchor, constant:-20).activateWithPriority(900)
        rimCeil.widthAnchor.constraintEqualToAnchor(mainStackView.widthAnchor, constant:-20).activateWithPriority(900)
        
    }


    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplay()
    }
    
    func updateDisplay(){
        let ti = IAKitOptions.touchInterpreter.rawValue
        touchInterpreterEK.centerKeyWithActionName(ti)
        
        let rimDict = IAKitOptions.rawIntensityMapper.dictDescription
        rimThresh.value = Float((rimDict["threshold"] as! Double))
        rimCeil.value = Float((rimDict["ceiling"] as! Double))
        rimA.value = Float((rimDict["a"] as? Double) ?? 1)
        
        rimEK.centerKeyWithActionName(rimDict["name"] as! String)
    }

    func dismiss(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func tiChosen(actionName:String!){
        if let ti = IATouchInterpreter(rawValue: actionName) {
            IAKitOptions.touchInterpreter = ti
            print("Touchinterpreter updated to \(actionName)")
        }
        updateDisplay()
    }
    
    func rimChosen(actionName:String!){
        let thresh = Float(rimThresh.value)
        let ceil = Float(rimCeil.value)
        
        if actionName == "Linear" {
            currentRim = RawIntensityMapping.Linear(threshold: thresh, ceiling: ceil)
        } else if actionName == "LogAx" {
            currentRim = RawIntensityMapping.LogAx(a: Float(rimA.value), threshold: thresh, ceiling: ceil)
        }
        
        IAKitOptions.rawIntensityMapper = currentRim
        updateDisplay()
    }
    
    func rimParamChanged(sender:UISlider!){
        var lastRim = currentRim.dictDescription
        switch sender.tag {
        case 1: lastRim["a"] = Double(sender.value) //a
        case 2: lastRim["threshold"] = Double(sender.value)//thresh
        case 3: lastRim["ceiling"] = Double(sender.value) //ceil
        default: return
        }
        currentRim = RawIntensityMapping(dictDescription: lastRim)
        IAKitOptions.rawIntensityMapper = currentRim
    }
    
    public func pressureKeyPressed(sender: PressureControl, actionName: String, intensity: Int) {
        resultDisplay.text = "\(intensity)"
    }
}
