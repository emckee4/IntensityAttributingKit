//
//  IAStringPresentationOptions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/1/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


public struct IAStringOptions:Equatable {
    
    
    public var renderScheme:IntensityTransformers!
    public var preferedSmoothing: IAStringTokenizing!
    
    
    public var animatesIfAvailable:Bool!
    
    ///Contains parameters like duration, animating layers, alpha levels, etc. If this is nil on an animating IAString then the transformers default parameters will be used
    public var animationOptions:IAAnimationParameters?
    
    init(renderScheme:IntensityTransformers! = IAKitPreferences.defaultTransformer, preferedSmoothing:IAStringTokenizing! = IAKitPreferences.defaultTokenizer, animates:Bool! = true, animationOptions:IAAnimationParameters? = nil){
        self.renderScheme = renderScheme
        self.preferedSmoothing = preferedSmoothing
        self.animatesIfAvailable = animates
        self.animationOptions = animationOptions
    }
    
    ///The non-nil values of the overridingOptions struct are applied to the values of a copy of the calling struct. If the overridingOptions struct itself is nil then this just returns a copy.
    func optionsWithOverridesApplied(overridingOptions:IAStringOptions!)->IAStringOptions{
        var result = self
        guard overridingOptions != nil else {return result}
        if let overScheme = overridingOptions.renderScheme {
            result.renderScheme = overScheme
        }
        if let overSmooth = overridingOptions.preferedSmoothing {
            result.preferedSmoothing = overSmooth
        }
        if let overAni = overridingOptions.animatesIfAvailable {
            result.animatesIfAvailable = overAni
        }
        if let overAO = overridingOptions.animationOptions {
            result.animationOptions = overAO
        }
        return result
    }
    
    
}




@warn_unused_result public func ==(lhs:IAStringOptions,rhs:IAStringOptions)->Bool{
//    guard lhs.animatesIfAvailable == rhs.animatesIfAvailable else {return false}  ///This needs to be determined separately due to a bug at the time of writing
//    guard lhs.renderScheme == rhs.renderScheme else {return false}
//    guard lhs.preferedSmoothing == rhs.preferedSmoothing else {return false}
//    guard lhs.animationOptions == rhs.animationOptions else {return false}
//    return true
    
    return lhs.animatesIfAvailable == rhs.animatesIfAvailable && lhs.renderScheme == rhs.renderScheme && lhs.preferedSmoothing == rhs.preferedSmoothing && lhs.animationOptions == rhs.animationOptions
}

//Extensions for converting to/from dictionaries to facilitate JSON conversion
extension IAStringOptions {
    init!(optionsDict:[String:AnyObject]!){
        guard optionsDict != nil else {return nil}
        self.renderScheme = IntensityTransformers(rawOptional: (optionsDict["renderScheme"] as? String))
        self.preferedSmoothing = IAStringTokenizing(shortLabel: (optionsDict["preferedSmoothing"] as? String))
        self.animatesIfAvailable = optionsDict["animates"] as? Bool
    }
    
    ///animationOptions are discarded by default
    func asOptionsDict()->[String:AnyObject]{
        var dict:[String:AnyObject] = [:]
        if self.renderScheme != nil {
            dict["renderScheme"] = self.renderScheme.rawValue
        }
        if self.preferedSmoothing != nil {
            dict["preferedSmoothing"] = self.preferedSmoothing.shortLabel
        }
        if self.animatesIfAvailable != nil {
            dict["animates"] = self.animatesIfAvailable
        }
        return dict
    }
    
}



