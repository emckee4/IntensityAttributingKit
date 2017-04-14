//
//  IAStringPresentationOptions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/1/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation

///IAStringOptions holds IntensityTransformer and smoothing/tokenizer options of an IAString. These values hold for the entirety of an IAString. These can be overriden by the displayer without modifying the underlying values using the optionsWithOverridesApplied function.
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
    func optionsWithOverridesApplied(_ overridingOptions:IAStringOptions!)->IAStringOptions{
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



public func ==(lhs:IAStringOptions,rhs:IAStringOptions)->Bool{
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
            dict["renderScheme"] = self.renderScheme.rawValue as AnyObject?
        }
        if self.preferedSmoothing != nil {
            dict["preferedSmoothing"] = self.preferedSmoothing.shortLabel as AnyObject?
        }
        if self.animatesIfAvailable != nil {
            dict["animates"] = self.animatesIfAvailable as AnyObject?
        }
        return dict
    }
    
}



