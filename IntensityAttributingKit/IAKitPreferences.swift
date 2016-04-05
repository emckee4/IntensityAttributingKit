//
//  IAKitPreferences.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 12/1/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation


/**
IAKitPreferences contains most persisted options that need to be exposed to the outside world, along with an internal NSCache for the IAKeyboard and accessory that dont have any other logical home
*/
public class IAKitPreferences:NSObject {
    
    static let bundle:NSBundle = NSBundle(forClass: IAKitPreferences.self)
    
    static let forceTouchAvailable = UIScreen.mainScreen().traitCollection.forceTouchCapability == .Available
    
    //MARK:- Keyboard and accessory caching
    private static let vcCache = NSCache()

    static var keyboard:IAKeyboard {
        if let kb = vcCache.objectForKey("iaKB") as? IAKeyboard {
            return kb
        } else {
            let kb = IAKeyboard(nibName:nil, bundle: nil)
            vcCache.setObject(kb, forKey: "iaKB")
            return kb
        }
    }
    
    static var accessory:IAAccessoryVC {
        if let acc = vcCache.objectForKey("iaAccessory") as? IAAccessoryVC {
            return acc
        } else {
            let acc = IAAccessoryVC(nibName:nil, bundle: nil)
            vcCache.setObject(acc, forKey: "iaAccessory")
            return acc
        }
    }
    
    
    ///flushes the cache containing the keyboard and accessory so that they'll be recreated on the next access request
    static func resetKBAndAccessory(){
        vcCache.removeAllObjects()
    }
    
    private static let iakPrefix = "com.McKeeMaKer.IntensityAttributingKit.IAKitPreferences."
    
    //// store retained options/defaults here
    private struct Keys {
        static let dIntensity = "IAKitPreferences.defaultIntensity"
        static let dTextSize = "IAKitPreferences.defaultTextSize"
        static let dTransformerName = "IAKitPreferences.defaultTransformerName"
        static let dTokenizerName = "IAKitPreferences.defaultTokenizerName"
        //static let maxSavedImageDimensions = "IAKitPreferences.maxSavedImageDimensions" //constant
        
        static let oTokenizerName = "IAKitPreferences.overridingTokenizerName"
        static let oTransformerName = "IAKitPreferences.overridingTransformerName"
        
        static let deviceResourcesLimited = "IAKitPreferences.deviceResourcesLimited"
        
        //static let fimName = "IAKitPreferences.forceIntensityMappingName"
        //need constants
        //how to store constants for mapping in performant accessable way?
        //static let fimParametersDictName = "IAKitPreferences.fimParametersDictName"
        
        static let touchInterpreterName = "IAKitPreferences.touchInterpreterName"
        static let rawIntensityMapperName = "IAKitPreferences.rawIntensityMapperName"
        static let spellingSuggestionsEnabled = "IAKitPreferences.spellingSuggestions"
        static let animationEnabled = "IAKitPreferences.animationEnabled"
    }
    
    
    private static var _defaultIntensity:Int = {return (NSUserDefaults.standardUserDefaults().objectForKey(Keys.dIntensity) as? Int) ?? 40}()
    public static var defaultIntensity:Int {
        get {return _defaultIntensity}
        set {_defaultIntensity = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Keys.dIntensity)}
    }
    private static var _defaultTextSize:Int = {return (NSUserDefaults.standardUserDefaults().objectForKey(Keys.dTextSize) as? Int) ?? 20}()
    public static var defaultTextSize:Int {
        get {return _defaultTextSize}
        set {_defaultTextSize = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Keys.dTextSize)}
    }
    
    private static var _defaultTransformer:IntensityTransformers = {
        return IntensityTransformers(rawValue: (NSUserDefaults.standardUserDefaults().objectForKey(Keys.dTransformerName) as? String) ?? "") ?? IntensityTransformers.WeightScheme
    }()
    public static var defaultTransformer:IntensityTransformers {
        get {return _defaultTransformer}
        set {
            _defaultTransformer = newValue
            NSUserDefaults.standardUserDefaults().setObject(newValue.rawValue, forKey: Keys.dTransformerName)
        }
    }
    
    private static var _defaultTokenizer:IAStringTokenizing = {
        return IAStringTokenizing(shortLabel: (NSUserDefaults.standardUserDefaults().objectForKey(Keys.dTokenizerName) as? String) ?? "") ?? IAStringTokenizing.Char
    }()
    public static var defaultTokenizer:IAStringTokenizing{
        get {return _defaultTokenizer}
        set {_defaultTokenizer = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue.shortLabel, forKey: Keys.dTokenizerName)}
    }
    
    
    static let maxSavedImageDimensions:CGSize = CGSize(width: 640, height: 640)
    

    private static var _overridesTransformer:IntensityTransformers? = {
        guard let transformerName = NSUserDefaults.standardUserDefaults().objectForKey(Keys.oTransformerName) as? String else {return nil}
        return IntensityTransformers(rawValue: transformerName)
    }()
    public static var overridesTransformer:IntensityTransformers? {
        get {return _overridesTransformer}
        set {_overridesTransformer = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue?.rawValue, forKey: Keys.oTransformerName)}
    }
    
    private static var _overridesTokenizer:IAStringTokenizing? = {
        guard let tokenizerName = NSUserDefaults.standardUserDefaults().objectForKey(Keys.oTokenizerName) as? String else {return nil}
        return IAStringTokenizing(shortLabel: tokenizerName)
    }()
    public static var overridesTokenizer:IAStringTokenizing? {
        get {return _overridesTokenizer}
        set {_overridesTokenizer = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue?.shortLabel, forKey: Keys.oTokenizerName)}
    }

    //static var forceIntensityMapping:ForceIntensityMappingFunctions.AvailableFunctions?
    
    ///caches instantiated touchInterpreter
    private static var _touchInterpreter:IATouchInterpreter = {
        if let tiName = NSUserDefaults.standardUserDefaults().objectForKey(Keys.touchInterpreterName) as? String {
            if let interpreter = IATouchInterpreter(rawValue: tiName) {
                return interpreter
            }
        }
        if IAKitPreferences.forceTouchAvailable {
            return IATouchInterpreter.Force
        } else {
            return IATouchInterpreter.Duration
        }
    }()
    static var touchInterpreter:IATouchInterpreter {
        get {return _touchInterpreter}
        set {
            _touchInterpreter = newValue
            NSUserDefaults.standardUserDefaults().setObject(newValue.rawValue, forKey: Keys.touchInterpreterName)
            RawIntensity.touchInterpreter = newValue
        }
    }
    
    ///caches current value of rawIntensityMapper in instantiated form
    private static var _rawIntensityMapper:RawIntensityMapping = {
        if let rawName = NSUserDefaults.standardUserDefaults().objectForKey(Keys.rawIntensityMapperName) as? String {
            if let rim = RawIntensityMapping(rawValue:rawName) {
                return rim
            }
        }
            return RawIntensityMapping.Linear  //default
        }()
    static var rawIntensityMapper:RawIntensityMapping {
        get{ return _rawIntensityMapper}
        set {
            _rawIntensityMapper = newValue
            NSUserDefaults.standardUserDefaults().setObject(newValue.rawValue, forKey: Keys.rawIntensityMapperName)
            RawIntensity.rawIntensityMapping = newValue
        }
    }
    
    private static var _deviceResourcesLimited:Bool = (NSUserDefaults.standardUserDefaults().objectForKey(Keys.deviceResourcesLimited) as? Bool) ?? (sizeof(Int) == 4)
    /// This flag determines if the kit should skimp on animations whereever possible. By default this will be true for 32bit devices (32 bit iPhones supporting iOS 9 include 4s,5,5c)
    static var deviceResourcesLimited:Bool {
        get {return _deviceResourcesLimited}
        set {
            _deviceResourcesLimited = newValue
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Keys.deviceResourcesLimited)
        }
    }
    
    private static var _spellingSuggestionsEnabled:Bool = (NSUserDefaults.standardUserDefaults().objectForKey(Keys.spellingSuggestionsEnabled) as? Bool) ?? true
    /// Determines if the IAKeyboard show the suggestions bar.
    static var spellingSuggestionsEnabled:Bool {
        get {return _spellingSuggestionsEnabled}
        set {
            _spellingSuggestionsEnabled = newValue
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Keys.spellingSuggestionsEnabled)
            keyboard.suggestionBarActive = newValue
        }
    }
    
    private static var _animationEnabled:Bool = (NSUserDefaults.standardUserDefaults().objectForKey(Keys.animationEnabled) as? Bool) ?? true
    /// Determines if the IAKeyboard show the suggestions bar.
    static var animationEnabled:Bool {
        get {return _animationEnabled}
        set {
            _animationEnabled = newValue
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Keys.animationEnabled)
            keyboard.suggestionBarActive = newValue
        }
    }
    
    
    static var iaStringDefaultBaseOptions:IAStringOptions {
        return IAStringOptions(renderScheme: defaultTransformer, preferedSmoothing: defaultTokenizer, animates: animationEnabled, animationOptions: nil)
    }
    
    static var iaStringOverridingOptions:IAStringOptions {
        return IAStringOptions(renderScheme: overridesTransformer, preferedSmoothing: overridesTokenizer, animates: animationEnabled, animationOptions: nil)
    }
    
}