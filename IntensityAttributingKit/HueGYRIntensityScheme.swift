//
//  HueGYRIntensityScheme.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/9/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit


open class HueGYRIntensityScheme:AnimatedIntensityTransforming {
    //MARK:- static IntensityTransforming properties
    open static let schemeName = "HueGYRScheme"
    open static let stepCount = 20
    
    
    //MARK:- AnimatedIntensityTransforming properties
    ///Top layer carries animating color attributed text
    open static let topLayerAnimates:Bool = true
    ///Bottom layer carries animating black text
    open static let bottomLayerAnimates:Bool = false
    open static let bottomLayerTimingOffset:Double = 0
    
    
    ///This tweakable mapping provides the primary color attribute which varies in response to intensity
    fileprivate static func colorForIntensityBin(_ intensityBin:Int)->UIColor{
        let hue = CGFloat(0.4 - ((Float(intensityBin) / 20.0) * 0.4))
        return UIColor(hue: hue, saturation: 1.0, brightness: 0.8, alpha: 1.0)
    }
    
    open static func nsAttributesForBinsAndBaseAttributes(bin:Int,baseAttributes:IABaseAttributes)->[String:AnyObject]{
        var baseFont:UIFont = UIFont.systemFont(ofSize: baseAttributes.cSize)
        
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
        var nsAttributes:[String:AnyObject] = [NSFontAttributeName:baseFont]
        
        if baseAttributes.strikethrough {
            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as AnyObject?
        }
        if baseAttributes.underline {
            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as AnyObject?
        }
        
        ///Do color text stuff here
        
        nsAttributes[NSForegroundColorAttributeName] = colorForIntensityBin(bin)
        
        return nsAttributes
    }

    
    //MARK:- AnimatedIntensityTransforming functions:
    
    open static func layeredNSAttributesForBinsAndBaseAttributes(bin:Int,baseAttributes:IABaseAttributes)->(top:[String:AnyObject], bottom:[String:AnyObject]) {
        
        var baseFont:UIFont = UIFont.systemFont(ofSize: baseAttributes.cSize)
        
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
        var nsAttributes:[String:AnyObject] = [NSFontAttributeName:baseFont]
        
        if baseAttributes.strikethrough {
            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as AnyObject?
        }
        if baseAttributes.underline {
            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as AnyObject?
        }
        
        ///Do color text stuff here
        var topLayerAtts = nsAttributes
        topLayerAtts[NSForegroundColorAttributeName] = UIColor.black
        
        nsAttributes[NSForegroundColorAttributeName] = colorForIntensityBin(bin)
        return (top:topLayerAtts, bottom:nsAttributes)
        
    }

    open static var defaultAnimationParameters:IAAnimationParameters {
        return IAAnimationParameters(duration: 1, topFrom: 0.0, topTo: 0.5, bottomFrom: 0, bottomTo: 1)
    }
    
}



