//
//  FontSizeIntensityScheme.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/9/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

/// Varies font size relative to the base IASize as a function of intensity
public class FontSizeIntensityScheme:IntensityTransforming {

    public static let schemeName = "FontSizeScheme"
    public static let stepCount = 10
    
    public static func nsAttributesForBinsAndBaseAttributes(bin bin:Int,baseAttributes:IABaseAttributes)->[String:AnyObject]{
        let size = CGFloat(baseAttributes.size - 5 + bin)
        var baseFont:UIFont = UIFont.systemFontOfSize(size)
        
        if baseAttributes.bold || baseAttributes.italic {
            var symbolicsToMerge = UIFontDescriptorSymbolicTraits()
            if baseAttributes.bold {
                symbolicsToMerge.unionInPlace(.TraitBold)
            }
            if baseAttributes.italic {
                symbolicsToMerge.unionInPlace(.TraitItalic)
            }
            let newSymbolicTraits =  baseFont.fontDescriptor().symbolicTraits.union(symbolicsToMerge)
            let newDescriptor = baseFont.fontDescriptor().fontDescriptorWithSymbolicTraits(newSymbolicTraits)
            baseFont = UIFont(descriptor: newDescriptor!, size: size)
        }
        var nsAttributes:[String:AnyObject] = [NSFontAttributeName:baseFont]
        
        if baseAttributes.strikethrough {
            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }
        if baseAttributes.underline {
            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }
        //TODO:- this should adjust kerning (using NSKernAttributeName) to lessen the variations in space requried due to a transform
        
        
        return nsAttributes
    }

    
    
}

