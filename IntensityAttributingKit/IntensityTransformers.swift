
import UIKit




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
    
}






