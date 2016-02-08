//
//  ExpandingPressureKey.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/31/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit


/** Configurable dropdown-like button which can provide intensity and forceTouch data when available.
Supports both delegate based actions (required if intensity data is desired) and selector based actions.
 
Future changes: 
Add animation by animating frame expansion prior to expanding constraints to match.
Consider giving leway on out of bounds presses
-Expand in two directions: L shaped expansion like multi keys on the ios system keyboard.

*/
@IBDesignable public class ExpandingPressureKey: ExpandingKeyBase, PressureControl {
    
    public weak var delegate:PressureKeyActionDelegate?
    
    lazy var forceTouchAvailable:Bool = {
        return self.traitCollection.forceTouchCapability == UIForceTouchCapability.Available
    }()
    
    private var touchIntensity: RawIntensity = RawIntensity()
    
    
    //MARK:- Selection and highlighting effect helpers
    
    override func bgColorForSelection() -> UIColor {
        guard backgroundColor != nil && forceTouchAvailable else {return selectionColor ?? UIColor.blackColor()}
        //TODO: add different blending methods for non-grayscale color options
        var white:CGFloat = 0.0
        var alpha:CGFloat = 1.0
        backgroundColor!.getWhite(&white, alpha: &alpha)
        let intensity = touchIntensity.intensity
        let newAlpha:CGFloat = max(alpha * CGFloat(1 + intensity), 1.0)
        let newWhite:CGFloat = white * CGFloat(1 - intensity)
        return UIColor(white: newWhite, alpha: newAlpha)
    }
    
    override func keySelectionWillUpdate(withTouch touch: UITouch!, previousSelection oldKey: EPKey?, nextSelection: EPKey?) {
        if oldKey == nil && nextSelection != nil{
            guard touch != nil else {return}
            touchIntensity = RawIntensity(withFloatValue: Float(touch.force), maximumPossibleForce: Float(touch.maximumPossibleForce))
        } else if nextSelection == nil {
            touchIntensity.reset()
        } else if nextSelection! != oldKey! {
            guard touch != nil else {return}
            touchIntensity.reset(touch.force)
        } else {
            touchIntensity.append(touch.force)
        }
    }
    
    override func handleKeySelection(selectedKey: EPKey) {
        self.delegate?.pressureKeyPressed(self, actionName: selectedKey.actionName, intensity: touchIntensity.intensity)
    }
    
    
}




