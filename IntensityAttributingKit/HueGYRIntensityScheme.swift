//
//  HueGYRIntensityScheme.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/9/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit


public class HueGYRIntensityScheme:AnimatedIntensityTransforming {
    //MARK:- static IntensityTransforming properties
    public static let schemeName = "HueGYRScheme"
    public static let stepCount = 20
    
    
    //MARK:- AnimatedIntensityTransforming properties
    ///Top layer carries animating color attributed text
    public static let topLayerAnimates:Bool = true
    ///Bottom layer carries animating black text
    public static let bottomLayerAnimates:Bool = false
    public static let bottomLayerTimingOffset:Double = 0
    
    
    ///This tweakable mapping provides the primary color attribute which varies in response to intensity
    private static func colorForIntensityBin(intensityBin:Int)->UIColor{
        let hue = CGFloat(0.4 - ((Float(intensityBin) / 20.0) * 0.4))
        return UIColor(hue: hue, saturation: 1.0, brightness: 0.8, alpha: 1.0)
    }
    
    public static func nsAttributesForBinsAndBaseAttributes(bin bin:Int,baseAttributes:IABaseAttributes)->[String:AnyObject]{
        var baseFont:UIFont = UIFont.systemFontOfSize(baseAttributes.cSize)
        
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
        var nsAttributes:[String:AnyObject] = [NSFontAttributeName:baseFont]
        
        if baseAttributes.strikethrough {
            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }
        if baseAttributes.underline {
            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }
        
        ///Do color text stuff here
        
        nsAttributes[NSForegroundColorAttributeName] = colorForIntensityBin(bin)
        
        return nsAttributes
    }

    
    //MARK:- AnimatedIntensityTransforming functions:
    
    public static func layeredNSAttributesForBinsAndBaseAttributes(bin bin:Int,baseAttributes:IABaseAttributes)->(top:[String:AnyObject], bottom:[String:AnyObject]) {
        
        var baseFont:UIFont = UIFont.systemFontOfSize(baseAttributes.cSize)
        
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
        var nsAttributes:[String:AnyObject] = [NSFontAttributeName:baseFont]
        
        if baseAttributes.strikethrough {
            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }
        if baseAttributes.underline {
            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }
        
        ///Do color text stuff here
        var topLayerAtts = nsAttributes
        topLayerAtts[NSForegroundColorAttributeName] = UIColor.blackColor()
        
        nsAttributes[NSForegroundColorAttributeName] = colorForIntensityBin(bin)
        return (top:topLayerAtts, bottom:nsAttributes)
        
    }

}



