
import UIKit

public protocol IntensityTransforming {
    static var schemeName:String {get}
    ///stepCount indicates the number of divisions in intensity rendering which are actually rendered. This value allows longer stretches of similar attributes to be consolodated before being passed to the internal TextKit processors.
    static var stepCount:Int {get}

    static func generateSampleFromText(text:String, size:CGFloat)->NSAttributedString

    static func nsAttributesForIntensityAttributes(intensity intensity:Int,baseAttributes:IABaseAttributes)->[String:AnyObject]
    static func nsAttributesForBinsAndBaseAttributes(bin bin:Int,baseAttributes:IABaseAttributes)->[String:AnyObject]
    
}

///Default implementations for the mutable and immutable transformations. These each rely on nsAttributesForIAAttributes to do the scheme specific work.
public extension IntensityTransforming {

    ///transforms provided using the transformer while varying the intensity linearly over the length of the sample
    public static func generateSampleFromText(text:String, size:CGFloat)->NSAttributedString{
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
        //use existing code predominantly for this
        let weightBin = min((IAString.binNumberForSteps(intensity, steps:stepCount) + (baseAttributes.bold ? 1 : 0)), stepCount)
        return self.nsAttributesForBinsAndBaseAttributes(bin: weightBin, baseAttributes: baseAttributes)
    }
    
}

