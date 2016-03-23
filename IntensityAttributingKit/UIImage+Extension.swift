//
//  UIImage+Extension.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/26/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit


extension UIImage {
    ///Resizes the image such that it will fit within the maxSize provided. This will not expand the images bounds. By default this will maintain the aspect ratio of the image.
    func resizeImageToFit(maxSize maxSize:CGSize, maintainAspectRatio:Bool = true)->UIImage{
        var finalSize:CGSize!
        if maintainAspectRatio == false {
            finalSize = CGSize(width: min(self.size.width , maxSize.width ), height: min(self.size.height , maxSize.height ))
        } else {
            finalSize = self.size.sizeThatFitsMaintainingAspect(containerSize: maxSize)
        }
        let hasAlpha = false
        let scale: CGFloat = 1.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(finalSize, !hasAlpha, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: finalSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
}