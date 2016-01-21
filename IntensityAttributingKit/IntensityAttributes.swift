import UIKit



typealias IAAttributeTupple = (UInt8,UInt8,UInt8,UInt8)

extension Bool {
    var byteValue:UInt8 {return self ? 0b1 : 0}
}

public struct IntensityAttributes:CustomStringConvertible, Hashable {
    public var intensity:Float
    public var size:CGFloat
    
    public var isBold:Bool = false
    public var isItalic:Bool = false
    public var isUnderlined:Bool = false
    public var isStrikethrough:Bool = false
    
    public var currentScheme:String!
    
    public init(intensity:Float,size:CGFloat){
        self.intensity = intensity
        self.size = size
    }
    
    
    ///ommits non-mandetory attributes if false
    public var asAttributeDict:[String:AnyObject]{
        var dict:[String:AnyObject] = [
            IATags.IAIntensity: intensity,
            IATags.IASize: size
        ]
        if isBold {
            dict[IATags.IABold] = true
        }
        if isItalic {
            dict[IATags.IAItalic] = true
        }
        if isUnderlined {
            dict[IATags.IAUnderline] = true
        }
        if isStrikethrough {
            dict[IATags.IAStrikethrough] = true
        }
        if let scheme = currentScheme {
            dict[IATags.IACurrentRendering] = scheme
        }
        return dict
    }
    
    public init!(iaAttributeDictionary dict:[String:AnyObject]){
        guard let newIntensity = dict[IATags.IAIntensity] as? Float, let newSize = dict[IATags.IASize] as? CGFloat else {return nil}
        //guard let newSize = dict[IATags.IASize] as? CGFloat else {return nil}
        self.init(intensity:newIntensity,size:newSize)
        self.isBold = dict[IATags.IABold] as? Bool ?? false
        self.isItalic = dict[IATags.IAItalic] as? Bool ?? false
        self.isUnderlined = dict[IATags.IAUnderline] as? Bool ?? false
        self.isStrikethrough = dict[IATags.IAStrikethrough] as? Bool ?? false
        
        self.currentScheme = dict[IATags.IACurrentRendering] as? String
    }
    
    
    
    public var description:String {
        return "Intensity: \(intensity), size: \(size)" + (isBold ? ", bold" : "") + (isItalic ? ", italic" : "") + (isUnderlined ? ", underlined" : "") + (isStrikethrough ? ", strikethrough" : "") + (currentScheme != nil ? ", currentScheme: " + currentScheme : "")
    }
    
    public var hashValue:Int {
        return (self.size.hashValue << 8) ^ self.intensity.hashValue ^ (isBold.hashValue << 42) ^ (isItalic.hashValue << 43) ^ (isStrikethrough.hashValue << 44) ^ (isUnderlined.hashValue << 45) ^ (currentScheme?.hashValue ?? 0)
    }
    
    ///Possibly deprecated:
    
    init(bitfield:UInt32){
        let intensityByte = bitfield & 0xFF
        let sizeByte = (bitfield & 0xFF00) >> 8
        let attributesByte = (bitfield & 0xFF0000) >> 16
        self.intensity = Float(intensityByte) / 100
        self.size = CGFloat(sizeByte)
        self.isBold = (attributesByte & 0b1) != 0
        self.isItalic = (attributesByte & 0b10) != 0
        self.isUnderlined = (attributesByte & 0b100) != 0
        self.isStrikethrough = (attributesByte & 0b1000) != 0
    }
    
    func toBitfield()->UInt32{
        let firstByte = UInt32(max(min(intensity, 2.55),0.0) * 100)
        let secondByte:UInt32 = UInt32(max(min(size, 255.0),0.0))
        let thirdByte:UInt32 = UInt32((isBold.byteValue << 0) | (isItalic.byteValue << 1) | (isUnderlined.byteValue << 2) | (isStrikethrough.byteValue << 3) )
        
        return (thirdByte << 16) | (secondByte << 8) | firstByte
    }
    
    func toByteTupple()->IAAttributeTupple{
        let fourthByte = UInt8(max(min(intensity, 2.55),0.0) * 100)
        let thirdByte = UInt8(max(min(size, 255.0),0.0))
        let secondByte = UInt8((isBold.byteValue << 0) | (isItalic.byteValue << 1) | (isUnderlined.byteValue << 2) | (isStrikethrough.byteValue << 3) )
        return (UInt8(0),secondByte,thirdByte,fourthByte)
    }
    
    init(byteTupple:IAAttributeTupple){
        let (_, attributesByte, sizeByte, intensityByte) = byteTupple
        self.intensity = Float(intensityByte) / 100
        self.size = CGFloat(sizeByte)
        self.isBold = (attributesByte & 0b1) != 0
        self.isItalic = (attributesByte & 0b10) != 0
        self.isUnderlined = (attributesByte & 0b100) != 0
        self.isStrikethrough = (attributesByte & 0b1000) != 0
    }
    
    ///Returns which bin the IntensityAttributes belongs in given its own intensity and a provided number of equal width divisions (steps)
    public func binNumberForSteps(steps:Int)->Int{
        return bound(Int(intensity * Float(steps)), min: 0, max: steps - 1)
    }
    
    
}

@warn_unused_result public func ==(lhs: IntensityAttributes, rhs: IntensityAttributes) -> Bool{
    return lhs.hashValue == rhs.hashValue
    
}

