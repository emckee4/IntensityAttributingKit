//
//  Extensions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/10/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    func stringByReplacingFirstOccurrenceOfString(target: String, withString replaceString: String) -> String {
        if let range = self.rangeOfString(target) {
            return self.stringByReplacingCharactersInRange(range, withString: replaceString)
        }
        return self
    }
    
}



extension NSLayoutConstraint {
    ///Modifies priority of self inplace and returns self. Useful for one-liner init and config.
    func withPriority(priority:Float)->NSLayoutConstraint{
        self.priority = priority
        return self
    }
}


extension UIView {
    public func imageFromView()->UIImage!{
        let imageSize = self.bounds.size
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        
        self.layer.renderInContext(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
}
