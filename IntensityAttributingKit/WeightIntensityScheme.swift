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
    
    required public init(){}
    
    let weightArray = [
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
    
    ///This is the mapping of intensity to weight which is the central element of the transformer
    private func weightForIntensity(intensity:Float, isBold:Bool?)->CGFloat{
        var weightIndex = bound(Int(intensity * Float(weightArray.count)), min: 0, max: weightArray.count - 1)
        if isBold  == true {
            weightIndex = min(weightIndex + 1, weightArray.count - 1)
        }
        return weightArray[weightIndex]
    }
    
    public func nsAttributesForIAAttributes(iaAttributes:[String:AnyObject])->[String:AnyObject]{
        let weight = weightForIntensity(iaAttributes[IATags.IAIntensity] as! Float, isBold: iaAttributes[IATags.IABold] as? Bool)
        let size = iaAttributes[IATags.IASize] as! CGFloat
        var baseFont = UIFont.systemFontOfSize(size, weight: weight)
        if iaAttributes[IATags.IAItalic] as? Bool == true {
            let newSymbolicTraits =  baseFont.fontDescriptor().symbolicTraits.union(.TraitItalic)
            let newDescriptor = baseFont.fontDescriptor().fontDescriptorWithSymbolicTraits(newSymbolicTraits)
            baseFont = UIFont(descriptor: newDescriptor, size: size)
        }
        
        var nsAttributes:[String:AnyObject] = [NSFontAttributeName:baseFont]
        
        if iaAttributes[IATags.IAStrikethrough] as? Bool == true {
            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }
        if iaAttributes[IATags.IAUnderline] as? Bool == true {
            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        }
        
        //colors should return to default black and clear
        
        return nsAttributes
    }
    
    
    public func updateIntensityAttributesInScheme(lastIntensityAttributes lastIA:IntensityAttributes, providedAttributes:[String:AnyObject], intensity:Float)->IntensityAttributes{
        
        let sym = (providedAttributes[NSFontAttributeName] as! UIFont).fontDescriptor().symbolicTraits
        let providedIsBold = sym.contains(.TraitBold)
        let providedIsItalic = sym.contains(.TraitItalic)
        let providedIsUnderlined = providedAttributes[NSUnderlineStyleAttributeName] as? Int > 0
        let providedIsStrikethrough = providedAttributes[NSStrikethroughStyleAttributeName] as? Int > 0
        
        let lastShouldBeBold = weightForIntensity(lastIA.intensity, isBold: lastIA.isBold) >= UIFontWeightSemibold
        
        var newIA = lastIA
        if providedIsBold != lastShouldBeBold {
            newIA.isBold = !newIA.isBold
        }
        if providedIsItalic != lastIA.isItalic {
            newIA.isItalic = !newIA.isItalic
        }
        if providedIsUnderlined != lastIA.isUnderlined {
            newIA.isUnderlined = !newIA.isUnderlined
        }
        if providedIsStrikethrough != lastIA.isStrikethrough {
            newIA.isStrikethrough = !newIA.isStrikethrough
        }
        newIA.intensity = intensity
        return newIA
    }
}
