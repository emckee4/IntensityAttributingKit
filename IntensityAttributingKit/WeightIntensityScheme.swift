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
    
//    ///This is the mapping of intensity to weight which is the central element of the transformer
//    private class func weightForIntensity(intensity:Float, isBold:Bool?)->CGFloat{
//        var weightIndex = bound(Int(intensity * Float(weightArray.count)), min: 0, max: weightArray.count - 1)
//        if isBold  == true {
//            weightIndex = min(weightIndex + 1, weightArray.count - 1)
//        }
//        return weightArray[weightIndex]
//    }
    
//    public func nsAttributesForIAAttributes(iaAttributes:[String:AnyObject])->[String:AnyObject]{
//        let weight = weightForIntensity(iaAttributes[IATags.IAIntensity] as! Float, isBold: iaAttributes[IATags.IABold] as? Bool)
//        let size = iaAttributes[IATags.IASize] as! CGFloat
//        var baseFont = UIFont.systemFontOfSize(size, weight: weight)
//        if iaAttributes[IATags.IAItalic] as? Bool == true {
//            let newSymbolicTraits =  baseFont.fontDescriptor().symbolicTraits.union(.TraitItalic)
//            let newDescriptor = baseFont.fontDescriptor().fontDescriptorWithSymbolicTraits(newSymbolicTraits)
//            baseFont = UIFont(descriptor: newDescriptor, size: size)
//        }
//        
//        var nsAttributes:[String:AnyObject] = [NSFontAttributeName:baseFont]
//        
//        if iaAttributes[IATags.IAStrikethrough] as? Bool == true {
//            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
//        }
//        if iaAttributes[IATags.IAUnderline] as? Bool == true {
//            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
//        }
//        
//        //colors should return to default black and clear
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
//        let lastShouldBeBold = weightForIntensity(lastIA.intensity, isBold: lastIA.isBold) >= UIFontWeightSemibold
//        
//        var newIA = lastIA
//        if providedIsBold != lastShouldBeBold {
//            newIA.isBold = !newIA.isBold
//        }
//        if providedIsItalic != lastIA.isItalic {
//            newIA.isItalic = !newIA.isItalic
//        }
//        if providedIsUnderlined != lastIA.isUnderlined {
//            newIA.isUnderlined = !newIA.isUnderlined
//        }
//        if providedIsStrikethrough != lastIA.isStrikethrough {
//            newIA.isStrikethrough = !newIA.isStrikethrough
//        }
//        newIA.intensity = intensity
//        return newIA
//    }
    
//    ///change perword to withOptions, but first implement per character and per word options
//    public func renderIAString(iaString:IAIntermediate, perWord:Bool)->NSAttributedString!{
//        /*
//        let weight = weightForIntensity(iaAttributes[IATags.IAIntensity] as! Float, isBold: iaAttributes[IATags.IABold] as? Bool)
//        let size = iaAttributes[IATags.IASize] as! CGFloat
//        var baseFont = UIFont.systemFontOfSize(size, weight: weight)
//        if iaAttributes[IATags.IAItalic] as? Bool == true {
//            let newSymbolicTraits =  baseFont.fontDescriptor().symbolicTraits.union(.TraitItalic)
//            let newDescriptor = baseFont.fontDescriptor().fontDescriptorWithSymbolicTraits(newSymbolicTraits)
//            baseFont = UIFont(descriptor: newDescriptor, size: size)
//        }
//        
//        var nsAttributes:[String:AnyObject] = [NSFontAttributeName:baseFont]
//        
//        if iaAttributes[IATags.IAStrikethrough] as? Bool == true {
//            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
//        }
//        if iaAttributes[IATags.IAUnderline] as? Bool == true {
//            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
//        }
//        
//        //colors should return to default black and clear
//        
//        return nsAttributes
//        */
//        //create an array of weight steps, 0-8.
//        
//        //intensities will smoothed to the center of the bin level required for this rendered
//        
//        let smoothLevel:(Float)->(Float) = {(intensity) -> (Float) in
//            let oneNinth:Float = 1.0 / 9.0
//            
//            switch intensity {
//            case 0.0..<oneNinth: return 0.5
//            case oneNinth..<(2*oneNinth):  return oneNinth + 0.05
//            case (2*oneNinth)..<(3*oneNinth): return 2*oneNinth + 0.05
//            case (3*oneNinth)..<(4*oneNinth): return 3*oneNinth + 0.05
//            case (4*oneNinth)..<(5*oneNinth): return 4*oneNinth + 0.05
//            case (5*oneNinth)..<(6*oneNinth): return 5*oneNinth + 0.05
//            case (6*oneNinth)..<(7*oneNinth): return 6*oneNinth + 0.05
//            case (7*oneNinth)..<(8*oneNinth): return 7*oneNinth + 0.05
//            default: return 8*oneNinth + 0.05
//            }
//        }
//
//        var weightLevelArray:[Float] = perWord == true ? iaString.perWordIntensityArray().map(smoothLevel) : iaString.intensities.map(smoothLevel)
//        
//        //now with smoothed levels we can generate IntensityAttribute objects covering a range, then generate nsattributes directly from this, then just drop those into a new NSAttributedText object
//        
//        //instead of converting to IntensityAttribute we could just convert straight to the end result: this would let us work directly with levels
//        
//        //make sure to handle insertion of links and attachments: consider generating the base NSMutableAttributedString with those already inserted in IAIntermediate so the transformer only needs to worry about fonts
//    }
    
//    public class func nsAttributesForIntensityAttributes(intensity intensity:Int,baseAttributes:IABaseAttributes)->[String:AnyObject]{
//        //use existing code predominantly for this
//        let weightBin = min((binNumberForSteps(intensity, steps:stepCount) + (baseAttributes.bold ? 1 : 0)), stepCount)
//        return self.nsAttributesForBinsAndBaseAttributes(bin: weightBin, baseAttributes: baseAttributes)
//    }
    
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
