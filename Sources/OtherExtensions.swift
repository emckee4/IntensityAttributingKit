//
//  OtherExtensions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/26/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit



extension NSLayoutConstraint {
    @discardableResult func activateWithPriority(_ priority:Float, identifier:String? = nil)->NSLayoutConstraint{
        self.priority = priority
        self.isActive = true
        if identifier != nil {
            self.identifier = identifier
        }
        return self
    }
}


extension CGSize {
    ///Returns the largest CGSize that will fit in the provided container size without changing the aspect ratio
    func sizeThatFitsMaintainingAspect(containerSize:CGSize, expandIfRoom:Bool = false)->CGSize{
        let widthScaleFactor =  containerSize.width / self.width
        let heightScaleFactor = containerSize.height / self.height
        if widthScaleFactor >= 1.0 && heightScaleFactor >= 1.0 {
            if expandIfRoom == false {
                return self
            }else {
                let newScale = min(widthScaleFactor,heightScaleFactor)
                return self.applying(CGAffineTransform(scaleX: newScale, y: newScale))
            }
        } else {
            let newScale = min(widthScaleFactor,heightScaleFactor)
            return self.applying(CGAffineTransform(scaleX: newScale, y: newScale))
        }
    }
}

extension UIGestureRecognizerState: CustomDebugStringConvertible{
    public var debugDescription:String {
        switch self {
        case .possible: return "Possible"
        case .began: return "Began"
        case .changed: return "Changed"
        case .ended: return "Ended"
        case .cancelled: return "Cancelled"
        case .failed: return "Failed"
        }
    }
}

extension CGRect {
    ///calculates the distance of a point to the closest edge of the calling rect if it's outside the rect, or 0 if inside.
    func distanceToPoint(_ point:CGPoint)->CGFloat{
        if point.x < self.origin.x {
            if point.y < self.origin.y {
                return sqrt(pow(point.x - self.origin.x, 2) + pow(point.y - self.origin.y, 2))
            } else if point.y > self.origin.y + self.height {
                return sqrt(pow(point.x - self.origin.x, 2) + pow(point.y - (self.origin.y + self.height), 2))
            } else {
                return abs(point.x - self.origin.x)
            }
        } else if point.x > self.origin.x + self.width{
            if point.y < self.origin.y {
                return sqrt(pow(point.x - (self.origin.x + self.width), 2) + pow(point.y - self.origin.y, 2))
            } else if point.y > self.origin.y + self.height {
                return sqrt(pow(point.x - (self.origin.x + self.width), 2) + pow(point.y - (self.origin.y + self.height), 2))
            } else {
                return abs(point.x - (self.origin.x + self.width))
            }
        } else {
            //point.x within the horizonal range of x
            if point.y < self.origin.y {
                return abs(point.y - self.origin.y)
            } else if point.y > self.origin.y + self.height {
                return abs(point.y - (self.origin.y + self.height))
            } else {
                return 0
            }
        }
    }
}
