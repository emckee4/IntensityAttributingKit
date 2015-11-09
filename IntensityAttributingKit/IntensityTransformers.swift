
import UIKit




public enum IntensityTransformers:String {
    case TextColorScheme = "TextColorScheme", WeightScheme = "WeightScheme"
    
    var transformer:IntensityTransforming {
        if let thisTransformer = IntensityTransformers.storedTransformers[self] {
            return thisTransformer
        } else {
            let trans = IntensityTransformers.transformerTypes[self]!.init()
            IntensityTransformers.storedTransformers[self] = trans
            return trans
        }
    }
    ///
    private static var transformerTypes:[IntensityTransformers:IntensityTransforming.Type] = [.TextColorScheme:TextColorIntensityScheme.self, .WeightScheme:WeightIntensityScheme.self]
    ///Instances of transformers are lazily added to this array as they're requested and instantiated using transformerTypes
    private static var storedTransformers:[IntensityTransformers:IntensityTransforming] = [:]
    
}



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


public class TextColorIntensityScheme:IntensityTransforming {
    required public init(){}
    public static let schemeName = "TextColorScheme"
    
    private var fontCache:[CGFloat:UIFont] = [:]
    
    ///This tweakable mapping provides the primary color attribute which varies in response to intensity
    private func colorForIntensity(intensity:Float)->UIColor{
        let hue = CGFloat(0.4 - (intensity * 0.4))
        return UIColor(hue: hue, saturation: 1.0, brightness: 0.8, alpha: 1.0)
    }
    
    
    public func nsAttributesForIAAttributes(iaAttributes: [String : AnyObject]) -> [String : AnyObject] {
        let size = iaAttributes[IATags.IASize] as! CGFloat
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
        
        ///Do color text stuff here
        nsAttributes[NSForegroundColorAttributeName] = colorForIntensity(iaAttributes[IATags.IAIntensity] as! Float)
        
        //set currentScheme here

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




