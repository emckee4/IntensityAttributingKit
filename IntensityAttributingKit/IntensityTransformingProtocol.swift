
import UIKit

///The IntensityTransforming protocol contains components for expressing intensity attributed text with a scheme. AnimatedIntensityTransforming adopts and extends this to provide the option of animating. IntensityTransformers is an enum which contains names and references to the types of all concrete transformers. Since this protocol leans heavily on static typed values, it's imperitive that adopters pay attention to type safety.
public protocol IntensityTransforming {
    static var schemeName:String {get}
    ///stepCount indicates the number of divisions in intensity rendering which are actually rendered. This value allows longer stretches of similar attributes to be consolodated before being passed to the internal TextKit processors.
    static var stepCount:Int {get}

    static var schemeIsAnimatable:Bool {get}
    
    static func generateStaticSampleFromText(_ text:String, size:CGFloat)->NSAttributedString
    
    static func nsAttributesForIntensityAttributes(intensity:Int,baseAttributes:IABaseAttributes)->[String:Any]
    static func nsAttributesForBinsAndBaseAttributes(bin:Int,baseAttributes:IABaseAttributes)->[String:Any]
    
}

///Default implementations for the mutable and immutable transformations. These each rely on nsAttributesForIAAttributes to do the scheme specific work.
public extension IntensityTransforming {
    ///This is automatically overridden with a true value for types adopting AnimatedIntensityAttributing
    static var schemeIsAnimatable:Bool {return false}

    ///transforms provided using the transformer while varying the intensity linearly over the length of the sample
    public static func generateStaticSampleFromText(_ text:String, size:CGFloat)->NSAttributedString{
        let charCount:Int = text.characters.count
        guard charCount > 0 else {return NSAttributedString()}
        let baseAttributes = IABaseAttributes(size:Int(size),options: [])
        guard charCount > 1 else {
            let atts = self.nsAttributesForIntensityAttributes(intensity:100, baseAttributes: baseAttributes!)
            return NSAttributedString(string: text, attributes: atts)
        }
        let mutableAS = NSMutableAttributedString()
        for (i,char) in text.characters.enumerated() {
            let thisIntensity:Int = Int((Float(i) / Float(charCount - 1) + 0.001) * 100)
            let nsAttributes = self.nsAttributesForIntensityAttributes(intensity:thisIntensity, baseAttributes: baseAttributes!)
            mutableAS.append(NSAttributedString(string: String(char), attributes: nsAttributes))
        }
        return mutableAS
    }
    
    public static func nsAttributesForIntensityAttributes(intensity:Int,baseAttributes:IABaseAttributes)->[String:Any]{
        let weightBin = min((IAString.binNumberForSteps(intensity, steps:stepCount) + (baseAttributes.bold ? 1 : 0)), stepCount)
        return self.nsAttributesForBinsAndBaseAttributes(bin: weightBin, baseAttributes: baseAttributes)
    }
    
    
    
}

///AnimatedIntensityTransforming protocol adopts and extends the IntensityTransforming protocol to provide options for two layer opacity animations.
public protocol AnimatedIntensityTransforming:IntensityTransforming{
    ///NSAttributes for top and bottom layers for animating schemes
    static func layeredNSAttributesForIntensityAttributes(intensity:Int,baseAttributes:IABaseAttributes)->(top:[String:Any], bottom:[String:Any])
    static func layeredNSAttributesForBinsAndBaseAttributes(bin:Int,baseAttributes:IABaseAttributes)->(top:[String:Any], bottom:[String:Any])

    static var topLayerAnimates:Bool {get}
    static var bottomLayerAnimates:Bool {get}
    ///bottomLayerTimingOffset * duration yields the offset value for the bottom layer of the CAAnimation. If the bottom layer is non animating then this valaue is meaningless. A value of 1 is a 180 degree offset.
    static var bottomLayerTimingOffset:Double {get}
    
    static var defaultAnimationParameters:IAAnimationParameters {get}
}

public extension AnimatedIntensityTransforming {
    final static var schemeIsAnimatable:Bool {return true}
    
    static func layeredNSAttributesForIntensityAttributes(intensity:Int,baseAttributes:IABaseAttributes)->(top:[String:Any], bottom:[String:Any]){
        let weightBin = min((IAString.binNumberForSteps(intensity, steps:stepCount) + (baseAttributes.bold ? 1 : 0)), stepCount)
        return self.layeredNSAttributesForBinsAndBaseAttributes(bin: weightBin, baseAttributes: baseAttributes)
    }
    
    
    static var defaultAnimationParameters:IAAnimationParameters {
        return IAAnimationParameters(duration: 1, topFrom: 0, topTo: 1, bottomFrom: 0, bottomTo: 1)
    }
}







