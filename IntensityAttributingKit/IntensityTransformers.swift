
import UIKit


///IntensityTransformers is an enum which contains names and references to the types of all concrete IntensityTransforming types. 
public enum IntensityTransformers:String {
    case HueGYRScheme = "HueGYRScheme", WeightScheme = "WeightScheme", FontSizeScheme = "FontSizeScheme", AlphaScheme = "AlphaScheme"
    
    var transformer:IntensityTransforming.Type {
        switch self {
        case .HueGYRScheme: return HueGYRIntensityScheme.self
        case .WeightScheme: return WeightIntensityScheme.self
        case .FontSizeScheme: return FontSizeIntensityScheme.self
        case .AlphaScheme: return AlphaIntensityScheme.self
        }
    }
    
    var isAnimatable:Bool {
        return transformer.schemeIsAnimatable
    }
    
    static func animatableTransformers()->[IntensityTransformers]{
        return [.AlphaScheme,.HueGYRScheme]
    }
    
    var defaultAnimationParameters:IAAnimationParameters? {
        return (transformer as? AnimatedIntensityTransforming.Type)?.defaultAnimationParameters
    }
    
    init?(rawOptional:String?){
        if let raw = rawOptional {
            self.init(rawValue: raw)
        } else {
            return nil
        }
    }
}




///Specifies the duration and the from/to values of the top and bottom layers. If the layer doesn't animate in the given scheme then the values for that layer are ignored.
public struct IAAnimationParameters:Equatable {
    
    var duration:TimeInterval
    
    var topLayerFromValue:Float
    var topLayerToValue:Float
    
    var bottomLayerFromValue:Float
    var bottomLayerToValue:Float
    
    init(duration:TimeInterval, topLayerFromValue:Float,topLayerToValue:Float){
        self.duration = duration
        self.topLayerFromValue = topLayerFromValue
        self.topLayerToValue = topLayerToValue
        self.bottomLayerFromValue = 0
        self.bottomLayerToValue = 1
    }
    
    init(duration:TimeInterval, bottomLayerFromValue:Float,bottomLayerToValue:Float){
        self.duration = duration
        self.topLayerFromValue = 0
        self.topLayerToValue = 1
        self.bottomLayerFromValue = bottomLayerFromValue
        self.bottomLayerToValue = bottomLayerToValue
        
    }
    
    init(duration:TimeInterval, topFrom:Float,topTo:Float,bottomFrom:Float,bottomTo:Float){
        self.duration = duration
        self.topLayerFromValue = topFrom
        self.topLayerToValue = topTo
        self.bottomLayerFromValue = bottomFrom
        self.bottomLayerToValue = bottomTo
    }
    
}

public func ==(lhs:IAAnimationParameters,rhs:IAAnimationParameters)->Bool{
    return lhs.duration == rhs.duration  && lhs.topLayerFromValue == rhs.topLayerFromValue  && lhs.topLayerToValue == rhs.topLayerToValue  && lhs.bottomLayerFromValue == rhs.bottomLayerFromValue  && lhs.bottomLayerToValue == rhs.bottomLayerToValue
}
