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
    required public init(){}
    public static let schemeName = "FontSizeScheme"
    
    private var fontCache:[CGFloat:UIFont] = [:]
    
    ///This tweakable mapping provides the font size which varies in response to intensity
    private func fontSizeForIntensity(baseSize:CGFloat,intensity:Float)->CGFloat{
        let size = CGFloat(round(intensity * 10) - 5.0) + baseSize
        return size
    }
    
    
    public func nsAttributesForIAAttributes(iaAttributes: [String : AnyObject]) -> [String : AnyObject] {
        let baseSize = iaAttributes[IATags.IASize] as! CGFloat
        let size = fontSizeForIntensity(baseSize, intensity: iaAttributes[IATags.IAIntensity] as! Float)
        var baseFont:UIFont = UIFont.systemFontOfSize(size)
        
        
        let bold = iaAttributes[IATags.IABold] as? Bool ?? false
        let italic = iaAttributes[IATags.IAItalic] as? Bool ?? false
        if bold || italic {
            var symbolicsToMerge = UIFontDescriptorSymbolicTraits()
            if bold {
                symbolicsToMerge.unionInPlace(.TraitBold)
            }
            if italic {
                symbolicsToMerge.unionInPlace(.TraitItalic)
            }
            let newSymbolicTraits =  baseFont.fontDescriptor().symbolicTraits.union(symbolicsToMerge)
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
        //TODO:- this should adjust kerning (using NSKernAttributeName) to lessen the variations in space requried due to a transform
        
        return nsAttributes
    }
    
    public func updateIntensityAttributesInScheme(lastIntensityAttributes lastIA:IntensityAttributes, providedAttributes:[String:AnyObject], intensity:Float)->IntensityAttributes{
        
        let sym = (providedAttributes[NSFontAttributeName] as! UIFont).fontDescriptor().symbolicTraits
        let providedIsBold = sym.contains(.TraitBold)
        let providedIsItalic = sym.contains(.TraitItalic)
        let providedIsUnderlined = providedAttributes[NSUnderlineStyleAttributeName] as? Int > 0
        let providedIsStrikethrough = providedAttributes[NSStrikethroughStyleAttributeName] as? Int > 0
        
        var newIA = lastIA
        if providedIsBold != newIA.isBold {
            newIA.isBold = !newIA.isBold
        }
        if providedIsItalic != newIA.isItalic {
            newIA.isItalic = !newIA.isItalic
        }
        if providedIsUnderlined != newIA.isUnderlined {
            newIA.isUnderlined = !newIA.isUnderlined
        }
        if providedIsStrikethrough != newIA.isStrikethrough {
            newIA.isStrikethrough = !newIA.isStrikethrough
        }
        newIA.intensity = intensity
        return newIA
    }
    
    
}

