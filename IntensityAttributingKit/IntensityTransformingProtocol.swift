
import UIKit

public protocol IntensityTransforming {
    static var schemeName:String {get}
    ///stepCount indicates the number of divisions in intensity rendering which are actually rendered. This value allows longer stretches of similar attributes to be consolodated before being passed to the internal TextKit processors.
    static var stepCount:Int {get}

    static var schemeIsAnimatable:Bool {get}
    
    static func generateStaticSampleFromText(text:String, size:CGFloat)->NSAttributedString
    
    static func nsAttributesForIntensityAttributes(intensity intensity:Int,baseAttributes:IABaseAttributes)->[String:AnyObject]
    static func nsAttributesForBinsAndBaseAttributes(bin bin:Int,baseAttributes:IABaseAttributes)->[String:AnyObject]
    
}

///Default implementations for the mutable and immutable transformations. These each rely on nsAttributesForIAAttributes to do the scheme specific work.
public extension IntensityTransforming {
    ///This is automatically overridden with a true value for types adopting AnimatedIntensityAttributing
    static var schemeIsAnimatable:Bool {return false}

    ///transforms provided using the transformer while varying the intensity linearly over the length of the sample
    public static func generateStaticSampleFromText(text:String, size:CGFloat)->NSAttributedString{
        let charCount:Int = text.characters.count
        guard charCount > 0 else {return NSAttributedString()}
        let baseAttributes = IABaseAttributes(size:Int(size),options: [])
        guard charCount > 1 else {
            let atts = self.nsAttributesForIntensityAttributes(intensity:100, baseAttributes: baseAttributes)
            return NSAttributedString(string: text, attributes: atts)
        }
        let mutableAS = NSMutableAttributedString()
        for (i,char) in text.characters.enumerate() {
            let thisIntensity:Int = Int((Float(i) / Float(charCount - 1) + 0.001) * 100)
            let nsAttributes = self.nsAttributesForIntensityAttributes(intensity:thisIntensity, baseAttributes: baseAttributes)
            mutableAS.appendAttributedString(NSAttributedString(string: String(char), attributes: nsAttributes))
        }
        return mutableAS
    }
    
    public static func nsAttributesForIntensityAttributes(intensity intensity:Int,baseAttributes:IABaseAttributes)->[String:AnyObject]{
        let weightBin = min((IAString.binNumberForSteps(intensity, steps:stepCount) + (baseAttributes.bold ? 1 : 0)), stepCount)
        return self.nsAttributesForBinsAndBaseAttributes(bin: weightBin, baseAttributes: baseAttributes)
    }
    
    
    
}
// need animation offset

public protocol AnimatedIntensityTransforming:IntensityTransforming{
    ///NSAttributes for top and bottom layers for animating schemes
    static func layeredNSAttributesForIntensityAttributes(intensity intensity:Int,baseAttributes:IABaseAttributes)->(top:[String:AnyObject], bottom:[String:AnyObject])
    static func layeredNSAttributesForBinsAndBaseAttributes(bin bin:Int,baseAttributes:IABaseAttributes)->(top:[String:AnyObject], bottom:[String:AnyObject])

    static var topLayerAnimates:Bool {get}
    static var bottomLayerAnimates:Bool {get}
    ///bottomLayerTimingOffset * duration yields the offset value for the bottom layer of the CAAnimation. If the bottom layer is non animating then this valaue is meaningless. A value of 1 is a 180 degree offset.
    static var bottomLayerTimingOffset:Double {get}
    
    static var defaultAnimationParameters:IAAnimationParameters {get}
}

public extension AnimatedIntensityTransforming {
    final static var schemeIsAnimatable:Bool {return true}
    
    static func layeredNSAttributesForIntensityAttributes(intensity intensity:Int,baseAttributes:IABaseAttributes)->(top:[String:AnyObject], bottom:[String:AnyObject]){
        let weightBin = min((IAString.binNumberForSteps(intensity, steps:stepCount) + (baseAttributes.bold ? 1 : 0)), stepCount)
        return self.layeredNSAttributesForBinsAndBaseAttributes(bin: weightBin, baseAttributes: baseAttributes)
    }
    
    
    static var defaultAnimationParameters:IAAnimationParameters {
        return IAAnimationParameters(duration: 1, topFrom: 0, topTo: 1, bottomFrom: 0, bottomTo: 1)
    }
}







