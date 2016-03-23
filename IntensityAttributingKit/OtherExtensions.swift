//
//  OtherExtensions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/26/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit



extension NSLayoutConstraint {
    func activateWithPriority(priority:Float, identifier:String? = nil)->NSLayoutConstraint{
        self.priority = priority
        self.active = true
        if identifier != nil {
            self.identifier = identifier
        }
        return self
    }
}


extension CGSize {
    ///Returns the largest CGSize that will fit in the provided container size without changing the aspect ratio
    func sizeThatFitsMaintainingAspect(containerSize containerSize:CGSize, expandIfRoom:Bool = false)->CGSize{
        let widthScaleFactor =  containerSize.width / self.width
        let heightScaleFactor = containerSize.height / self.height
        if widthScaleFactor >= 1.0 && heightScaleFactor >= 1.0 {
            if expandIfRoom == false {
                return self
            }else {
                let newScale = min(widthScaleFactor,heightScaleFactor)
                return CGSizeApplyAffineTransform(self, CGAffineTransformMakeScale(newScale, newScale))
            }
        } else {
            let newScale = min(widthScaleFactor,heightScaleFactor)
            return CGSizeApplyAffineTransform(self, CGAffineTransformMakeScale(newScale, newScale))
        }
    }
}

