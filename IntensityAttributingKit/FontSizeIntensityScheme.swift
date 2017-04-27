//
//  FontSizeIntensityScheme.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/9/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

/// Varies font size relative to the base IASize as a function of intensity
open class FontSizeIntensityScheme:IntensityTransforming {

    open static let schemeName = "FontSizeScheme"
    open static let stepCount = 10
    
    open static func nsAttributesForBinsAndBaseAttributes(bin:Int,baseAttributes:IABaseAttributes)->[String:Any]{
        let size = CGFloat(baseAttributes.size - 5 + bin)
        var baseFont:UIFont = UIFont.systemFont(ofSize: size)
        
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
            baseFont = UIFont(descriptor: newDescriptor!, size: size)
        }
        var nsAttributes:[String:Any] = [NSFontAttributeName:baseFont]
        
        if baseAttributes.strikethrough {
            nsAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as Any?
        }
        if baseAttributes.underline {
            nsAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as Any?
        }
        //TODO:- this should adjust kerning (using NSKernAttributeName) to lessen the variations in space requried due to a transform
        
        
        return nsAttributes
    }

    
    
}

