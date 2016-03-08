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
    
    
//    ///singleton for IAKitOptions. Attempts to recover a saved instance of itself from NSUserDefaults on init, initializing with default values otherwise.
//    static let singleton:IAKitOptions = {
//        if let existingValue = NSUserDefaults.standardUserDefaults().objectForKey("iaKitOptions") as? IAKitOptions {
//            return IAKitOptions()
//        }
//        return IAKitOptions()
//    }()
        ///setter/getter for retrieving from storage
    
    //static let bundle:NSBundle = { return NSBundle(forClass: IAKitOptions.singleton.dynamicType) }()
    
    static let bundle:NSBundle = NSBundle(forClass: IAKitOptions.self)
    
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
    }
    
    
    
    static var defaultIntensity:Int {
        get {return (NSUserDefaults.standardUserDefaults().objectForKey(Keys.dIntensity) as? Int) ?? 40}
        set {NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Keys.dIntensity)}
    }
    static var defaultTextSize:Int {
        get {return (NSUserDefaults.standardUserDefaults().objectForKey(Keys.dTextSize) as? Int) ?? 20}
        set {NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Keys.dTextSize)}
    }
    
    static var defaultTransformer:IntensityTransformers {
        get {return IntensityTransformers(rawValue: (NSUserDefaults.standardUserDefaults().objectForKey(Keys.dTransformerName) as? String) ?? "") ?? IntensityTransformers.WeightScheme}
        set {NSUserDefaults.standardUserDefaults().setObject(newValue.rawValue, forKey: Keys.dTransformerName)}
    }

    static var defaultTokenizer:IAStringTokenizing{
        get {return IAStringTokenizing(shortLabel: (NSUserDefaults.standardUserDefaults().objectForKey(Keys.dTokenizerName) as? String) ?? "") ?? IAStringTokenizing.Char}
        set {NSUserDefaults.standardUserDefaults().setObject(newValue.shortLabel, forKey: Keys.dTokenizerName)}
    }
    
    
    static let maxSavedImageDimensions:CGSize = CGSize(width: 640, height: 640)
    


    static var overridesTransformer:IntensityTransformers? {
        get {
            guard let transformerName = NSUserDefaults.standardUserDefaults().objectForKey(Keys.oTransformerName) as? String else {return nil}
            return IntensityTransformers(rawValue: transformerName)
        }
        set {NSUserDefaults.standardUserDefaults().setObject(newValue?.rawValue, forKey: Keys.oTransformerName)}
    }
    
    static var overridesTokenizer:IAStringTokenizing? {
        get {
            guard let tokenizerName = NSUserDefaults.standardUserDefaults().objectForKey(Keys.oTokenizerName) as? String else {return nil}
            return IAStringTokenizing(shortLabel: tokenizerName)
        }
        set {NSUserDefaults.standardUserDefaults().setObject(newValue?.shortLabel, forKey: Keys.oTokenizerName)}
    }

    //static var forceIntensityMapping:ForceIntensityMappingFunctions.AvailableFunctions?
    
    static var touchInterpreter:IATouchInterpreter {
        get {
            if let tiName = NSUserDefaults.standardUserDefaults().objectForKey(Keys.touchInterpreterName) as? String {
                if let interpreter = IATouchInterpreter(rawValue: tiName) {
                    return interpreter
                }
            }
            if UIScreen.mainScreen().traitCollection.forceTouchCapability == .Available {
                let interpreter = IATouchInterpreter.Force
                NSUserDefaults.standardUserDefaults().setObject(interpreter.rawValue, forKey: Keys.touchInterpreterName)
                return interpreter
            } else {
                let interpreter = IATouchInterpreter.Duration
                NSUserDefaults.standardUserDefaults().setObject(interpreter.rawValue, forKey: Keys.touchInterpreterName)
                return interpreter
            }
        }
        set {NSUserDefaults.standardUserDefaults().setObject(newValue.rawValue, forKey: Keys.touchInterpreterName)}
    }
    
    static var rawIntensityMapper:RawIntensityMapping {
        get{
            if let rawDict = NSUserDefaults.standardUserDefaults().objectForKey(Keys.rawIntensityMapperDict) as? [String:AnyObject]{
                if let rim = RawIntensityMapping(dictDescription: rawDict) {
                    return rim
                }
            }
            // no RIM exists so we set and return the default
            let defaultRIM = RawIntensityMapping.Linear(threshold: 0, ceiling: 1.0)
            NSUserDefaults.standardUserDefaults().setObject(defaultRIM.dictDescription, forKey: Keys.rawIntensityMapperDict)
            return defaultRIM
        }
        set {NSUserDefaults.standardUserDefaults().setObject(newValue.dictDescription, forKey: Keys.rawIntensityMapperDict)}
    }
    
    //static var fimParametersDict
    
    ////
    
//    private override init(){
//        vcCache = NSCache()
//    }
    
    
//    //add nscoding stuff
//    
//    required init?(coder aDecoder: NSCoder) {
//        vcCache = NSCache()
//        if let fim = aDecoder.decodeObjectForKey("forceIntensityMappingName") as? String {
//            forceIntensityMapping = ForceIntensityMappingFunctions.AvailableFunctions(rawValue: fim)
//        }
//        
//        if let overridesSmoothingShortName = aDecoder.decodeObjectForKey("overridesSmoothing") as? String {
//            overridesSmoothing = IAStringTokenizing(shortLabel: overridesSmoothingShortName)
//        }
//        if let overridesSchemeRaw = aDecoder.decodeObjectForKey("overridesScheme") as? String {
//            overridesScheme = IntensityTransformers(rawValue: overridesSchemeRaw)
//        }
//        
//    }
//    
//    func encodeWithCoder(aCoder: NSCoder) {
//        if let fim = forceIntensityMapping{
//            aCoder.encodeObject(fim.rawValue, forKey: "forceIntensityMappingName")
//        }
//        
//
//        aCoder.encodeObject(overridesSmoothing?.shortLabel, forKey: "overridesSmoothing")
//        aCoder.encodeObject(overridesScheme?.rawValue, forKey: "overridesScheme")
//    }
//    
//    func saveOptions(){
//        let saveBlock = {
//            let data = NSKeyedArchiver.archivedDataWithRootObject(self)
//            NSUserDefaults.standardUserDefaults().setObject(data, forKey: "iaKitOptions")
//        }
//        if NSThread.isMainThread() {
//            saveBlock()
//        } else {
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                saveBlock()
//            })
//        }
//    }
    
    
    
}