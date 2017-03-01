//
//  AlphaIntensityScheme.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/25/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

/// Varies font opacity as a function of intensity
open class AlphaIntensityScheme:AnimatedIntensityTransforming {
    
    //MARK:- static IntensityTransforming properties
    open static let schemeName = "AlphaScheme"
    open static let stepCount = 8
    
    //MARK:- AnimatedIntensityTransforming properties
    ///Top layer carries non-animating alpha attributed text
    open static let topLayerAnimates:Bool = false
    ///Bottom layer carries animating opaque text
    open static let bottomLayerAnimates:Bool = true
    open static let bottomLayerTimingOffset:Double = 0
    
    
    //MARK:- IntensityTransforming functions:
    open static func nsAttributesForBinsAndBaseAttributes(bin:Int,baseAttributes:IABaseAttributes)->[String:AnyObject]{
        var baseFont:UIFont = UIFont.systemFont(ofSize: baseAttributes.cSize, weight: UIFontWeightMedium)
        
        let alphaValue:CGFloat = clamp(CGFloat(bin + 1) / CGFloat(stepCount - 1), lowerBound: 0, upperBound: 1)
        
        if baseAttributes.bold || baseAttributes.italic {
            var symbolicsToMerge = UIFontDescriptorSymbolicTraits()
            if baseAttributes.bold {
                symbolicsToMerge.formUnion(.traitBold)
            }
            if baseAttributes.italic {
                symbolicsToMerge.formUnion(.traitItalic)
            }
            let newSymbolicTraits =  baseFont.fontDescriptor.symbolicTraits.union(symbolicsToMerge)
            let newDescriptor = baseFont.fontDescriptor.withSymbolicTraits(newSymbolicTraits)
            baseFont = UIFont(descriptor: newDescriptor!, size: baseAttributes.cSize)
        }
        var nsAttributes:[String:AnyObject] = [
            NSFontAttributeName:baseFont,
            NSForegroundColorAttributeName:UIColor.black.withAlphaComponent(alphaValue)
        ]
        
        if baseAttributes.strikethrough {
            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as AnyObject?
        }
        if baseAttributes.underline {
            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as AnyObject?
        }        
        
        return nsAttributes
    }
    
    
    //MARK:- AnimatedIntensityTransforming functions:
    
    ///NSAttributes for top and bottom layers for animating schemes
    open static func layeredNSAttributesForBinsAndBaseAttributes(bin:Int,baseAttributes:IABaseAttributes)->(top:[String:AnyObject], bottom:[String:AnyObject]) {
        
        var baseFont:UIFont = UIFont.systemFont(ofSize: baseAttributes.cSize, weight: UIFontWeightMedium)
        
        let alphaValue:CGFloat = clamp(CGFloat(bin + 1) / CGFloat(stepCount - 1), lowerBound: 0, upperBound: 1)
        
        if baseAttributes.bold || baseAttributes.italic {
            var symbolicsToMerge = UIFontDescriptorSymbolicTraits()
            if baseAttributes.bold {
                symbolicsToMerge.formUnion(.traitBold)
            }
            if baseAttributes.italic {
                symbolicsToMerge.formUnion(.traitItalic)
            }
            let newSymbolicTraits =  baseFont.fontDescriptor.symbolicTraits.union(symbolicsToMerge)
            let newDescriptor = baseFont.fontDescriptor.withSymbolicTraits(newSymbolicTraits)
            baseFont = UIFont(descriptor: newDescriptor!, size: baseAttributes.cSize)
        }
        var nsAttributes:[String:AnyObject] = [
            NSFontAttributeName:baseFont
        ]
        
        if baseAttributes.strikethrough {
            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as AnyObject?
        }
        if baseAttributes.underline {
            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as AnyObject?
        }
    
        var topLayerAtts = nsAttributes
        topLayerAtts[NSForegroundColorAttributeName] = UIColor.black.withAlphaComponent(alphaValue)
        
        return (top:topLayerAtts, bottom:nsAttributes)
        
    }
    
    
    
}








