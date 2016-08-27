//
//  AlphaIntensityScheme.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/25/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

/// Varies font opacity as a function of intensity
public class AlphaIntensityScheme:AnimatedIntensityTransforming {
    
    //MARK:- static IntensityTransforming properties
    public static let schemeName = "AlphaScheme"
    public static let stepCount = 8
    
    //MARK:- AnimatedIntensityTransforming properties
    ///Top layer carries non-animating alpha attributed text
    public static let topLayerAnimates:Bool = false
    ///Bottom layer carries animating opaque text
    public static let bottomLayerAnimates:Bool = true
    public static let bottomLayerTimingOffset:Double = 0
    
    
    //MARK:- IntensityTransforming functions:
    public static func nsAttributesForBinsAndBaseAttributes(bin bin:Int,baseAttributes:IABaseAttributes)->[String:AnyObject]{
        var baseFont:UIFont = UIFont.systemFontOfSize(baseAttributes.cSize, weight: UIFontWeightMedium)
        
        let alphaValue:CGFloat = clamp(CGFloat(bin + 1) / CGFloat(stepCount - 1), lowerBound: 0, upperBound: 1)
        
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
            baseFont = UIFont(descriptor: newDescriptor, size: baseAttributes.cSize)
        }
        var nsAttributes:[String:AnyObject] = [
            NSFontAttributeName:baseFont,
            NSForegroundColorAttributeName:UIColor.blackColor().colorWithAlphaComponent(alphaValue)
        ]
        
        if baseAttributes.strikethrough {
            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }
        if baseAttributes.underline {
            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }        
        
        return nsAttributes
    }
    
    
    //MARK:- AnimatedIntensityTransforming functions:
    
    ///NSAttributes for top and bottom layers for animating schemes
    public static func layeredNSAttributesForBinsAndBaseAttributes(bin bin:Int,baseAttributes:IABaseAttributes)->(top:[String:AnyObject], bottom:[String:AnyObject]) {
        
        var baseFont:UIFont = UIFont.systemFontOfSize(baseAttributes.cSize, weight: UIFontWeightMedium)
        
        let alphaValue:CGFloat = clamp(CGFloat(bin + 1) / CGFloat(stepCount - 1), lowerBound: 0, upperBound: 1)
        
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
            baseFont = UIFont(descriptor: newDescriptor, size: baseAttributes.cSize)
        }
        var nsAttributes:[String:AnyObject] = [
            NSFontAttributeName:baseFont
        ]
        
        if baseAttributes.strikethrough {
            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }
        if baseAttributes.underline {
            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }
    
        var topLayerAtts = nsAttributes
        topLayerAtts[NSForegroundColorAttributeName] = UIColor.blackColor().colorWithAlphaComponent(alphaValue)
        
        return (top:topLayerAtts, bottom:nsAttributes)
        
    }
    
    
    
}








