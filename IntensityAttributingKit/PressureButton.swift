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
    
    var peakPressure:CGFloat {
        return pressureHistory.maxElement() ?? 0.0
    }
    
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        pressureHistory = []
        if touchInside {
            pressureHistory.append(pressure(touch))
        }
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        if touchInside {
            pressureHistory.append(pressure(touch))
        }
        return super.continueTrackingWithTouch(touch, withEvent: event)
    }
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if touchInside && touch != nil {
            pressureHistory.append(pressure(touch!))
        }
        
        super.endTrackingWithTouch(touch, withEvent: event)
        
    }
    override func cancelTrackingWithEvent(event: UIEvent?) {
        super.cancelTrackingWithEvent(event)
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
