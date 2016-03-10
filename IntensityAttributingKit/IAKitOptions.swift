//
//  IAKitOptions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 12/1/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation


/**
IAKitOptions is the internal singleton for the text kit which caches keyboard and stores settings which need to be persisted across sessions
*/
class IAKitOptions:NSObject {
    
    static let bundle:NSBundle = NSBundle(forClass: IAKitOptions.self)
    
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
    
    private static let iakPrefix = "com.McKeeMaKer.IntensityAttributingKit.IAKitOptions."
    
    //// store retained options/defaults here
    private struct Keys {
        static let dIntensity = "IAKitOptions.defaultIntensity"
        static let dTextSize = "IAKitOptions.defaultTextSize"
        static let dTransformerName = "IAKitOptions.defaultTransformerName"
        static let dTokenizerName = "IAKitOptions.defaultTokenizerName"
        //static let maxSavedImageDimensions = "IAKitOptions.maxSavedImageDimensions" //constant
        
        static let oTokenizerName = "IAKitOptions.overridingTokenizerName"
        static let oTransformerName = "IAKitOptions.overridingTransformerName"
        
        //static let fimName = "IAKitOptions.forceIntensityMappingName"
        //need constants
        //how to store constants for mapping in performant accessable way?
        //static let fimParametersDictName = "IAKitOptions.fimParametersDictName"
        
        static let touchInterpreterName = "IAKitOptions.touchInterpreterName"
        static let rawIntensityMapperDict = "IAKitOptions.rawIntensityMapperDict"
        
        static let deviceResourcesLimited = "IAKitOptions.deviceResourcesLimited"
    }
    
    
    private static var _defaultIntensity:Int = {return (NSUserDefaults.standardUserDefaults().objectForKey(Keys.dIntensity) as? Int) ?? 40}()
    static var defaultIntensity:Int {
        get {return _defaultIntensity}
        set {_defaultIntensity = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Keys.dIntensity)}
    }
    private static var _defaultTextSize:Int = {return (NSUserDefaults.standardUserDefaults().objectForKey(Keys.dTextSize) as? Int) ?? 20}()
    static var defaultTextSize:Int {
        get {return _defaultTextSize}
        set {_defaultTextSize = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Keys.dTextSize)}
    }
    
    private static var _defaultTransformer:IntensityTransformers = {
        return IntensityTransformers(rawValue: (NSUserDefaults.standardUserDefaults().objectForKey(Keys.dTransformerName) as? String) ?? "") ?? IntensityTransformers.WeightScheme
    }()
    static var defaultTransformer:IntensityTransformers {
        get {return _defaultTransformer}
        set {
            _defaultTransformer = newValue
            NSUserDefaults.standardUserDefaults().setObject(newValue.rawValue, forKey: Keys.dTransformerName)
        }
    }
    
    private static var _defaultTokenizer:IAStringTokenizing = {
        return IAStringTokenizing(shortLabel: (NSUserDefaults.standardUserDefaults().objectForKey(Keys.dTokenizerName) as? String) ?? "") ?? IAStringTokenizing.Char
    }()
    static var defaultTokenizer:IAStringTokenizing{
        get {return _defaultTokenizer}
        set {_defaultTokenizer = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue.shortLabel, forKey: Keys.dTokenizerName)}
    }
    
    
    static let maxSavedImageDimensions:CGSize = CGSize(width: 640, height: 640)
    

    private static var _overridesTransformer:IntensityTransformers? = {
        guard let transformerName = NSUserDefaults.standardUserDefaults().objectForKey(Keys.oTransformerName) as? String else {return nil}
        return IntensityTransformers(rawValue: transformerName)
    }()
    static var overridesTransformer:IntensityTransformers? {
        get {return _overridesTransformer}
        set {_overridesTransformer = newValue; NSUserDefaults.standardUserDefaults().setObject(newValue?.rawValue, forKey: Keys.oTransformerName)}
    }
    
    private static var _overridesTokenizer:IAStringTokenizing? = {
        guard let tokenizerName = NSUserDefaults.standardUserDefaults().objectForKey(Keys.oTokenizerName) as? String else {return nil}
        return IAStringTokenizing(shortLabel: tokenizerName)
    }()
    static var overridesTokenizer:IAStringTokenizing? {
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
        if IAKitOptions.forceTouchAvailable {
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
        if let rawDict = NSUserDefaults.standardUserDefaults().objectForKey(Keys.rawIntensityMapperDict) as? [String:AnyObject] {
            if let rim = RawIntensityMapping(dictDescription: rawDict) {
                return rim
            }
        }
            return RawIntensityMapping.Linear(threshold: 0, ceiling: 1.0)
        }()
    static var rawIntensityMapper:RawIntensityMapping {
        get{ return _rawIntensityMapper}
        set {
            _rawIntensityMapper = newValue
            NSUserDefaults.standardUserDefaults().setObject(newValue.dictDescription, forKey: Keys.rawIntensityMapperDict)
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
    
}