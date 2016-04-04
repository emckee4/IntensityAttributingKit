//
//  ExpandingPressureKey.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/31/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit


/** Configurable dropdown-like button which provides intensity for touch selections using RawIntensity.
Uses PressureKeyActionDelegate to pass conforming class the actionName and intensity values for a touchUpInside.
This is now a subclass of ExpandingKeyBase.
 
*/
@IBDesignable public class ExpandingPressureKey: ExpandingKeyBase, PressureControl {
    
    public weak var delegate:PressureKeyActionDelegate?
    
    private var touchIntensity: RawIntensity = RawIntensity()
    
    
    //MARK:- Selection and highlighting effect helpers
    
    override func bgColorForSelection() -> UIColor {
        guard backgroundColor != nil && IAKitPreferences.forceTouchAvailable else {return selectionColor ?? UIColor.blackColor()}
        //TODO: add different blending methods for non-grayscale color options
        var white:CGFloat = 0.0
        var alpha:CGFloat = 1.0
        backgroundColor!.getWhite(&white, alpha: &alpha)
        let intensity = touchIntensity.currentIntensity ?? 0
        let newAlpha:CGFloat = max(alpha * CGFloat(1 + intensity), 1.0)
        let newWhite:CGFloat = white * CGFloat(1 - intensity)
        return UIColor(white: newWhite, alpha: newAlpha)
    }
    
    override func keySelectionWillUpdate(withTouch touch: UITouch!, previousSelection oldKey: EPKey?, nextSelection: EPKey?) {
        if oldKey == nil && nextSelection != nil{
            guard touch != nil else {return}
            //touchIntensity = RawIntensity(withFloatValue: Float(touch.force), maximumPossibleForce: Float(touch.maximumPossibleForce))
            touchIntensity.updateIntensity(withTouch: touch)
        } else if nextSelection == nil {
            //touchIntensity.reset()
            touchIntensity.cancelInteraction()
        } else if nextSelection! != oldKey! {
            guard touch != nil else {return}
            //touchIntensity.reset(touch.force)
            touchIntensity.cancelInteraction()
            touchIntensity.updateIntensity(withTouch: touch)
        } else {
            //touchIntensity.append(touch.force)
            touchIntensity.updateIntensity(withTouch: touch)
        }
    }
    
    override func handleKeySelection(selectedKey: EPKey) {
        self.delegate?.pressureKeyPressed(self, actionName: selectedKey.actionName, intensity: touchIntensity.endInteraction(withTouch: nil))
    }
    
    
}




