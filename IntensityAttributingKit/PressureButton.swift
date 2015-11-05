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

    var pressureHistory:[CGFloat] = []
    
    var avgPressure:CGFloat {
        let count = pressureHistory.count
        guard count > 1 && forceTouchAvailable else {return 0.0}
        if count < 10 {
            return pressureHistory[1..<count].reduce(0.0, combine: +) / CGFloat(pressureHistory.count - 1)
        } else {
            return pressureHistory[(count - 10)..<count].reduce(0.0, combine: +) / CGFloat(10)
        }
        
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
    
    
//    var peakPressure:CGFloat {
//        return pressureHistory.maxElement() ?? 0.0
//    }
    
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        pressureHistory = []
        if touchInside {
            pressureHistory.append(pressure(touch))
            setBackgroundColorForIntensity(pressure(touch))
        }
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        if touchInside {
            pressureHistory.append(pressure(touch))
            setBackgroundColorForIntensity(pressure(touch))
        }
        return super.continueTrackingWithTouch(touch, withEvent: event)
    }
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if touchInside && touch != nil {
            pressureHistory.append(pressure(touch!))
        }
        setBackgroundColorForIntensity(0.0)
        super.endTrackingWithTouch(touch, withEvent: event)
        
    }
    override func cancelTrackingWithEvent(event: UIEvent?) {
        super.cancelTrackingWithEvent(event)
        setBackgroundColorForIntensity(0.0)
    }
    
    
    
    func pressure(touch:UITouch)->CGFloat{
        if forceTouchAvailable {
            //print("\(touch.force) / \(touch.maximumPossibleForce)")
            return (touch.force / touch.maximumPossibleForce)
        } else {
            return 0
        }
        
    }

}
