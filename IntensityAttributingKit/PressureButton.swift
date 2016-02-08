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
    var lastIntensity:Int {
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
        guard baseBackgroundColor != nil else {return}
        guard forceTouchAvailable else {super.backgroundColor = nonTouchSelectionBGColor; return}
        let intensity = rawIntensity.intensity
        guard intensity > 0 else {super.backgroundColor = baseBackgroundColor; return}
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
        if touchInside {
            forceTouchAvailable ? rawIntensity.reset(touch.force) : rawIntensity.reset(0.0)
            setBackgroundColorForIntensity()
            sendActionsForControlEvents(.ValueChanged)
        }
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        if touchInside {
            rawIntensity.append(touch.force)
            setBackgroundColorForIntensity()
            sendActionsForControlEvents(.ValueChanged)
        }
        return super.continueTrackingWithTouch(touch, withEvent: event)
    }
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if touchInside && touch != nil {
            rawIntensity.append(touch!.force)
            sendActionsForControlEvents(.ValueChanged)
        }
        resetBackground()
        super.endTrackingWithTouch(touch, withEvent: event)
        
    }
    override func cancelTrackingWithEvent(event: UIEvent?) {
        super.cancelTrackingWithEvent(event)
        resetBackground()
    }

}
