
import UIKit




public enum IntensityTransformers:String {
    case HueGYRScheme = "HueGYRScheme", WeightScheme = "WeightScheme", FontSizeScheme = "FontSizeScheme"
    
    var transformer:IntensityTransforming {
        if let thisTransformer = IntensityTransformers.storedTransformers[self] {
            return thisTransformer
        } else {
            ///this isn't really a threadsafe way of initializing the transformers but it shouldn't crash or create a real memory issue either
            let trans = IntensityTransformers.transformerTypes[self]!.init()
            IntensityTransformers.storedTransformers[self] = trans
            return trans
        }
    }
    ///
    private static let transformerTypes:[IntensityTransformers:IntensityTransforming.Type] = [.HueGYRScheme:HueGYRIntensityScheme.self, .WeightScheme:WeightIntensityScheme.self, FontSizeScheme:FontSizeIntensityScheme.self]
    ///Instances of transformers are lazily added to this array as they're requested and instantiated using transformerTypes
    private static var storedTransformers:[IntensityTransformers:IntensityTransforming] = [:]
    
}






