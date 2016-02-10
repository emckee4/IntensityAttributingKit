//
//  WeightIntensityScheme.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/9/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit


public class WeightIntensityScheme:IntensityTransforming {
    
    public static let schemeName = "WeightScheme"
    public static let stepCount = 9
    
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

    public static func nsAttributesForBinsAndBaseAttributes(bin bin:Int,baseAttributes:IABaseAttributes)->[String:AnyObject]{
        var weight = weightArray[bin]
        if baseAttributes.bold && bin < stepCount - 1 {
            weight++
        }
        var font = UIFont.systemFontOfSize(baseAttributes.cSize, weight: weight)
        if baseAttributes.italic {
            let newSymbolicTraits = font.fontDescriptor().symbolicTraits.union(.TraitItalic)
            let newDescriptor = font.fontDescriptor().fontDescriptorWithSymbolicTraits(newSymbolicTraits)
            font = UIFont(descriptor: newDescriptor, size: baseAttributes.cSize)
        }
        
        var nsAttributes:[String:AnyObject] = [NSFontAttributeName:font]
        
        if baseAttributes.strikethrough {
            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }
        if baseAttributes.underline {
            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }
        
        return nsAttributes
        
    }
    
}
