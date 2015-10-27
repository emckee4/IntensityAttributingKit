//
//  UIImage+Extension.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/26/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit


extension UIImage {
    ///returns a scaled version of the image such that both the width and height are within the provided parameters while maintaining the aspect ratio
    //    func resizeWithMaxWidthAndHeight(maxWidth maxWidth:CGFloat,maxHeight:CGFloat)->UIImage{
    //        let widthScaleFactor = maxWidth / self.size.width
    //        let heightScaleFactor = maxHeight / self.size.height
    //        if widthScaleFactor >= 1.0 && heightScaleFactor >= 1.0 {
    //            return self
    //        } else {
    //            let newScale = min(widthScaleFactor,heightScaleFactor)
    //
    //            let size = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(newScale, newScale))
    //            let hasAlpha = false
    //            let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
    //
    //            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
    //            self.drawInRect(CGRect(origin: CGPointZero, size: size))
    //
    //            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    //            UIGraphicsEndImageContext()
    //            return scaledImage
    //        }
    //
    //    }
    
    ///returns a scaled version of the image such that both the width and height are within the provided parameters while maintaining the aspect ratio.
    func constrainImageBounds(maxWidth maxWidth:CGFloat, maxHeight:CGFloat)->UIImage {
        let widthScaleFactor = maxWidth / self.size.width
        let heightScaleFactor = maxHeight / self.size.height
        if widthScaleFactor >= 1.0 && heightScaleFactor >= 1.0 {
            return self
        } else {
            let newScale = min(widthScaleFactor,heightScaleFactor)
            
            let size = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(newScale, newScale))
            let hasAlpha = false
            let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
            
            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
            self.drawInRect(CGRect(origin: CGPointZero, size: size))
            
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return scaledImage
        }
    }
    
}