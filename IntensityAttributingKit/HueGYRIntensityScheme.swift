//
//  HueGYRIntensityScheme.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/9/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit


public class HueGYRIntensityScheme:IntensityTransforming {
    public static let schemeName = "HueGYRScheme"
    public static let stepCount = 20
    
    ///This tweakable mapping provides the primary color attribute which varies in response to intensity
    private static func colorForIntensityBin(intensityBin:Int)->UIColor{
        let hue = CGFloat(0.4 - ((Float(intensityBin) / 20.0) * 0.4))
        return UIColor(hue: hue, saturation: 1.0, brightness: 0.8, alpha: 1.0)
    }
    
//    
//    public func nsAttributesForIAAttributes(iaAttributes: [String : AnyObject]) -> [String : AnyObject] {
//        let size = iaAttributes[IATags.IASize] as! CGFloat
//        var baseFont:UIFont = UIFont.systemFontOfSize(size)
//        
//        
//        let bold = iaAttributes[IATags.IABold] as? Bool ?? false
//        let italic = iaAttributes[IATags.IAItalic] as? Bool ?? false
//        if bold || italic {
//            var symbolicsToMerge = UIFontDescriptorSymbolicTraits()
//            if bold {
//                symbolicsToMerge.unionInPlace(.TraitBold)
//            }
//            if italic {
//                symbolicsToMerge.unionInPlace(.TraitItalic)
//            }
//            let newSymbolicTraits =  baseFont.fontDescriptor().symbolicTraits.union(symbolicsToMerge)
//            let newDescriptor = baseFont.fontDescriptor().fontDescriptorWithSymbolicTraits(newSymbolicTraits)
//            baseFont = UIFont(descriptor: newDescriptor, size: size)
//        }
//        var nsAttributes:[String:AnyObject] = [NSFontAttributeName:baseFont]
//        
//        if iaAttributes[IATags.IAStrikethrough] as? Bool == true {
//            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
//        }
//        if iaAttributes[IATags.IAUnderline] as? Bool == true {
//            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
//        }
//        
//        ///Do color text stuff here
//        nsAttributes[NSForegroundColorAttributeName] = colorForIntensity(iaAttributes[IATags.IAIntensity] as! Float)
//        
//        //set currentScheme here
//        
//        return nsAttributes
//    }
//    
//    public func updateIntensityAttributesInScheme(lastIntensityAttributes lastIA:IntensityAttributes, providedAttributes:[String:AnyObject], intensity:Float)->IntensityAttributes{
//        
//        let sym = (providedAttributes[NSFontAttributeName] as! UIFont).fontDescriptor().symbolicTraits
//        let providedIsBold = sym.contains(.TraitBold)
//        let providedIsItalic = sym.contains(.TraitItalic)
//        let providedIsUnderlined = providedAttributes[NSUnderlineStyleAttributeName] as? Int > 0
//        let providedIsStrikethrough = providedAttributes[NSStrikethroughStyleAttributeName] as? Int > 0
//        
//        var newIA = lastIA
//        if providedIsBold != newIA.isBold {
//            newIA.isBold = !newIA.isBold
//        }
//        if providedIsItalic != newIA.isItalic {
//            newIA.isItalic = !newIA.isItalic
//        }
//        if providedIsUnderlined != newIA.isUnderlined {
//            newIA.isUnderlined = !newIA.isUnderlined
//        }
//        if providedIsStrikethrough != newIA.isStrikethrough {
//            newIA.isStrikethrough = !newIA.isStrikethrough
//        }
//        newIA.intensity = intensity
//        return newIA
//    }
//    
//    
//    public class func nsAttributesForIntensityAttributes(intensity:Int,baseAttributes:IABaseAttributes)->[String:AnyObject]{
//
//        var baseFont:UIFont = UIFont.systemFontOfSize(baseAttributes.cSize)
//
//        if baseAttributes.bold || baseAttributes.italic {
//            var symbolicsToMerge = UIFontDescriptorSymbolicTraits()
//            if baseAttributes.bold {
//                symbolicsToMerge.unionInPlace(.TraitBold)
//            }
//            if baseAttributes.italic {
//                symbolicsToMerge.unionInPlace(.TraitItalic)
//            }
//            let newSymbolicTraits =  baseFont.fontDescriptor().symbolicTraits.union(symbolicsToMerge)
//            let newDescriptor = baseFont.fontDescriptor().fontDescriptorWithSymbolicTraits(newSymbolicTraits)
//            baseFont = UIFont(descriptor: newDescriptor, size: baseAttributes.cSize)
//        }
//        var nsAttributes:[String:AnyObject] = [NSFontAttributeName:baseFont]
//        
//        if baseAttributes.strikethrough {
//            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
//        }
//        if baseAttributes.underline {
//            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
//        }
//    
//        ///Do color text stuff here
//        
//        nsAttributes[NSForegroundColorAttributeName] = colorForIntensityBin(binNumberForSteps(intensity, steps: stepCount))
//        
//        return nsAttributes
//    }
    
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


}



