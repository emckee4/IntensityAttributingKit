//
//  IntensityAdjuster.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/3/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

class IntensityAdjuster: UIView {
    
    lazy var forceTouchAvailable:Bool = {
        return self.traitCollection.forceTouchCapability == UIForceTouchCapability.Available
    }()
    
    var intensityDisplay:UIButton!
    var stackView:UIStackView!
    var pressurePad:PressureButton!
    var slider:UISlider!
    
    ///This indicates to the owning IATextView that the defaultIntensity value should be treated as locked to external changes. When this is off, the IATextView may update the default intensity with the value from the last pressed intensity-capable key
    var defaultLocked:Bool {
        get{return intensityDisplay.selected}
        set{intensityDisplay.selected = newValue}
    }
    
    ///This default intensity is what we expect the IATextView to use for attributing actions when direct pressure input is unavailable (because of pasteing unattributed text/objects, typing on the system keyboard, or if 3d touch is unavailable on the device
    var defaultIntensity:Float = 0.40 {
        didSet {
            let intensityPercent = Int(100 * defaultIntensity)
            intensityDisplay?.setTitle(String(intensityPercent), forState: .Normal)}
    }
    
    var showPressurePad = true {
        didSet {pressurePad?.hidden = !showPressurePad}
    }
    var showPressureSlider = false {
        didSet {slider?.hidden = !showPressureSlider}
    }
    
    var stackViewSpacing:CGFloat {
        get{return stackView.spacing}
        set{stackView?.spacing = newValue}
    }
    
    var componentBackgroundColor:UIColor? {
        didSet{_ = stackView!.arrangedSubviews.map({$0.backgroundColor = componentBackgroundColor})}
    }
    var componentCornerRadius:CGFloat = 0.0{
        didSet{_ = stackView!.arrangedSubviews.map({$0.layer.cornerRadius = componentCornerRadius})}
    }
    var componentBorderWidth:CGFloat = 0.0 {
        didSet{_ = stackView!.arrangedSubviews.map({$0.layer.borderWidth = componentBorderWidth})}
    }
    var componentBorderColor:CGColor? {
        didSet{_ = stackView!.arrangedSubviews.map({$0.layer.borderColor = componentBorderColor})}
    }
    
    
    ///when true this causes values in the intensityDisplay button and the slider to update on .ValueChanged of the pressurePad rather than waiting for .TouchUpInside
    var updateWithPressesInProgress = false {
        didSet{
            if updateWithPressesInProgress {
                pressurePad?.removeTarget(self, action: "ppUpdated:", forControlEvents: .TouchUpInside)
                pressurePad?.addTarget(self, action: "ppUpdated:", forControlEvents: .ValueChanged)
            } else {
                pressurePad?.removeTarget(self, action: "ppUpdated:", forControlEvents: .ValueChanged)
                pressurePad?.addTarget(self, action: "ppUpdated:", forControlEvents: .TouchUpInside)
            }
            
        }
    }
    
    
    // provide base view with indicator (text, preferably in attributed text)
    // 3 views, 2+ visible, horizontal expansion, all updating in unison when displayed
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView(){
        self.translatesAutoresizingMaskIntoConstraints = false
        intensityDisplay = UIButton(type: .System)
        defaultIntensity = 0.40
        intensityDisplay.addTarget(self, action: "intensityDisplayButtonPressed:", forControlEvents: .TouchUpInside)
        intensityDisplay.setTitleColor(UIColor.greenColor(), forState: .Selected)
        intensityDisplay.translatesAutoresizingMaskIntoConstraints = false
        
        pressurePad = PressureButton()
        pressurePad.setTitle("press", forState: .Normal)
        self.updateWithPressesInProgress = false
        pressurePad.translatesAutoresizingMaskIntoConstraints = false
        pressurePad?.hidden = !showPressurePad
        
        
        slider = UISlider()
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.addTarget(self, action: "sliderUpdated:", forControlEvents: .ValueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider?.hidden = !showPressureSlider
        
        stackView = UIStackView(arrangedSubviews: [intensityDisplay, slider, pressurePad])
        stackView.axis = .Horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stackView)
        
        stackView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        stackView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        stackView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        
        intensityDisplay.widthAnchor.constraintLessThanOrEqualToAnchor(intensityDisplay.heightAnchor, multiplier: 2).active = true
        intensityDisplay.widthAnchor.constraintGreaterThanOrEqualToAnchor(intensityDisplay.heightAnchor, multiplier: 1.25).active = true
        
        pressurePad.widthAnchor.constraintLessThanOrEqualToAnchor(pressurePad.heightAnchor, multiplier: 2.0).active = true
        pressurePad.widthAnchor.constraintGreaterThanOrEqualToAnchor(pressurePad.heightAnchor, multiplier: 1.25).active = true
        
        
    }
    
    func intensityDisplayButtonPressed(sender:UIButton!){
        sender.selected = !sender.selected
    }
    
    
    func ppUpdated(sender:PressureButton){
        defaultIntensity = sender.lastIntensity
        slider.value = sender.lastIntensity
    }
    
    
    func sliderUpdated(sender:UISlider){
        defaultIntensity = sender.value
    }
    
    
    
}

/*

///This pressure based controller suports .ValueChanged UIControlEvents for pressure values. This control is rather useless on a non-3dTouch device and should be replaced by more appropriate controls in that context
class PressureControl: UIControl {
    
    var contentView:UIView!
    
    lazy var forceTouchAvailable:Bool = {
        return self.traitCollection.forceTouchCapability == UIForceTouchCapability.Available
    }()
    
    lazy var rawIntensity:RawIntensity = RawIntensity()
    var intensity:Float {
        return rawIntensity.intensity
    }
    
    private var baseBackgroundColor:UIColor? {
        didSet {super.backgroundColor = baseBackgroundColor}
    }
    override var backgroundColor:UIColor? {
        get{return baseBackgroundColor }
        set{baseBackgroundColor = newValue}
    }
    
    ///Color for background of selected cell if 3dTouch (and so our dynamic selection background color) are not available
    var nonTouchSelectionBGColor = UIColor.darkGrayColor()
    
    private func setBackgroundColorForIntensity(){
        guard forceTouchAvailable else {super.backgroundColor = nonTouchSelectionBGColor; return}
        let intensity = rawIntensity.intensity
        guard intensity > 0.0 else {super.backgroundColor = baseBackgroundColor; return}
        var white:CGFloat = -1.0
        var alpha:CGFloat = 1.0
        baseBackgroundColor!.getWhite(&white, alpha: &alpha)
        let newAlpha:CGFloat = max(alpha * CGFloat(1 + intensity), 1.0)
        let newWhite:CGFloat = white * CGFloat(1 - intensity)
        super.backgroundColor = UIColor(white: newWhite, alpha: newAlpha)
    }
    ///When the touch ends this sets the background color to normal
    private func resetBackground(){
        super.backgroundColor = baseBackgroundColor
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        rawIntensity.reset( forceTouchAvailable ? touch.force : 0.0 )
        sendActionsForControlEvents(.ValueChanged)
        setBackgroundColorForIntensity()
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        if touchInside {
            rawIntensity.append( forceTouchAvailable ? touch.force : 0.0 )
            sendActionsForControlEvents(.ValueChanged)
            setBackgroundColorForIntensity()
        } else {
            resetBackground()
            return false
        }
        return super.continueTrackingWithTouch(touch, withEvent: event)
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if let touch = touch {
            if self.pointInside((touch.locationInView(self)), withEvent: event) {
                rawIntensity.append( forceTouchAvailable ? touch.force : 0.0 )
                sendActionsForControlEvents(.ValueChanged)
            }
        }
        resetBackground()
        super.endTrackingWithTouch(touch, withEvent: event)
    }
}


*/








