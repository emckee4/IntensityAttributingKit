//
//  PressureButton.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/25/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

class PressureButton: UIButton {
    
    lazy var forceTouchAvailable:Bool = {
        return self.traitCollection.forceTouchCapability == UIForceTouchCapability.Available
    }()

    lazy var rawIntensity:RawIntensity = RawIntensity()
    
    ///this value is made available for the receiving class after it receives the action message from a touch
    var lastIntensity:Float {
        return rawIntensity.intensity
    }
    
    private var baseBackgroundColor:UIColor? {
        didSet {super.backgroundColor = baseBackgroundColor}
    }
    override var backgroundColor:UIColor? {
        get{return baseBackgroundColor }
        set{baseBackgroundColor = newValue}
    }

    
    private func setBackgroundColorForIntensity(intensityVal:CGFloat){
        guard baseBackgroundColor != nil else {return}
        guard intensityVal > 0.0 else {super.backgroundColor = baseBackgroundColor; return}
        let boundedIntensity = bound(intensityVal, min: 0.0, max: 1.0)
        var white:CGFloat = -1.0
        var alpha:CGFloat = 1.0
        baseBackgroundColor!.getWhite(&white, alpha: &alpha)
        
        let newAlpha:CGFloat = max(alpha * CGFloat(1 + boundedIntensity), 1.0)
        let newWhite:CGFloat = white * CGFloat(1 - boundedIntensity)
        super.backgroundColor = UIColor(white: newWhite, alpha: newAlpha)
    }
    
    
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        if touchInside {
            forceTouchAvailable ? rawIntensity.reset(touch.force) : rawIntensity.reset(0.0)
            setBackgroundColorForIntensity(pressure(touch))
        }
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        if touchInside {
            rawIntensity.append(touch.force)
            setBackgroundColorForIntensity(pressure(touch))
        }
        return super.continueTrackingWithTouch(touch, withEvent: event)
    }
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if touchInside && touch != nil {
            rawIntensity.append(touch!.force)
        }
        setBackgroundColorForIntensity(0.0)
        super.endTrackingWithTouch(touch, withEvent: event)
        
    }
    override func cancelTrackingWithEvent(event: UIEvent?) {
        super.cancelTrackingWithEvent(event)
        setBackgroundColorForIntensity(0.0)
    }
    
    
    ///produces a rough intensity value for the setBackgroundColorForIntensity function
    private func pressure(touch:UITouch)->CGFloat{
        if forceTouchAvailable {
            return (touch.force / touch.maximumPossibleForce)
        } else {
            return 0.5
        }
    }

}
