//
//  WeightIntensityScheme.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/9/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit


open class WeightIntensityScheme:IntensityTransforming {
    
    open static let schemeName = "WeightScheme"
    open static let stepCount = 9
    
    static let weightArray = [
        UIFontWeightUltraLight,
        UIFontWeightThin,
        UIFontWeightLight,
        UIFontWeightRegular,
        UIFontWeightMedium,
        UIFontWeightSemibold,
        UIFontWeightBold,
        UIFontWeightHeavy,
        UIFontWeightBlack
    ]

    open static func nsAttributesForBinsAndBaseAttributes(bin:Int,baseAttributes:IABaseAttributes)->[String:Any]{
        var weight = weightArray[bin]
        if baseAttributes.bold && bin < stepCount - 1 {
            weight += 1
        }
        var font = UIFont.systemFont(ofSize: baseAttributes.cSize, weight: weight)
        if baseAttributes.italic {
            let newSymbolicTraits = font.fontDescriptor.symbolicTraits.union(.traitItalic)
            let newDescriptor = font.fontDescriptor.withSymbolicTraits(newSymbolicTraits)
            font = UIFont(descriptor: newDescriptor!, size: baseAttributes.cSize)
        }
        
        var nsAttributes:[String:Any] = [NSFontAttributeName:font]
        
        if baseAttributes.strikethrough {
            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as Any?
        }
        if baseAttributes.underline {
            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as Any?
        }
        
        return nsAttributes
        
    }
    
}
