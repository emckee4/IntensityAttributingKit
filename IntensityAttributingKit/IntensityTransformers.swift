
import UIKit




public enum IntensityTransformers:String {
    case HueGYRScheme = "HueGYRScheme", WeightScheme = "WeightScheme"
    
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
    private static var transformerTypes:[IntensityTransformers:IntensityTransforming.Type] = [.HueGYRScheme:HueGYRIntensityScheme.self, .WeightScheme:WeightIntensityScheme.self]
    ///Instances of transformers are lazily added to this array as they're requested and instantiated using transformerTypes
    private static var storedTransformers:[IntensityTransformers:IntensityTransforming] = [:]
    
}






