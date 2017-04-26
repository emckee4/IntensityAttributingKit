//
//  IAKitPreferences.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 12/1/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation
import CoreLocation

/**
IAKitPreferences contains most persisted options that need to be exposed to the outside world along with some purely internal stuff. Putting as many of the configurable options as possible in one place seems preferable while the organization and features of this project is still in such flux. Preferences are stored in the NSUserDefaults.standardUserDefaults of the app.
*/
open class IAKitPreferences:NSObject {
    
    static let bundle:Bundle = Bundle(for: IAKitPreferences.self)
    
    static let forceTouchAvailable = (UIScreen.main.traitCollection.forceTouchCapability == .available) && (UIDevice.current.name.range(of: "Simulator") == nil)

    public static var imageDirectory:URL! = {
        return try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }()
    public static var videoDirectory:URL! = {
        return try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }()
    public static var videoPreviewDirectory:URL! = {
        return try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }()
    
    
    static var contentDownloadDelegate:IAAttachmentDownloadDelegate?
    
    ///Convenience accessory to the IAKeyboard.singleton
    static var keyboard:IAKeyboard {
        return IAKeyboard.singleton
    }
    
    ///Convenience accessory to the IAAccessoryVC.singleton
    static var accessory:IAAccessoryVC {
        return IAAccessoryVC.singleton
    }
    
    ///This is the locationManager used by the IALocationPicker. If the adopting app is planning to use a location manager then it should use this one or replace this before it's ever used. In order for location to work properly, NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription. If location services authorization is unknown when this framework first attempts to use location services, then the delegate of the locationManager (if it exists) will be replaced by IALocationManagerDelegateShim until the authorization dialog fails or succeeds.
    static open var locationManager:CLLocationManager = CLLocationManager()
    
    ///Reloads the keyboard and accessory singletons. This will cause any changes in global settings which affect the KB/accessory (like visual theming) to take effect. This will automatically call a global resignFirstResponder.
    open static func resetKBAndAccessory(){
        //Below don't work for custom input VCs so we use a hack below
        //IAAccessoryVC.singleton.dismissKeyboard()
        //IAKeyboard.singleton.dismissKeyboard()
        //Dismissal hack
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        IAKeyboard.singleton = IAKeyboard(nibName: nil, bundle: nil)
        IAAccessoryVC.singleton = IAAccessoryVC(nibName:nil, bundle: nil)
    }
    
    ///String keys for NSUserDefaults
    fileprivate struct Keys {
        static let iakPrefix = "com.McKeeMaKer.IntensityAttributingKit."
        
        static let dIntensity = "IAKitPreferences.defaultIntensity"
        static let dTextSize = "IAKitPreferences.defaultTextSize"
        static let dTransformerName = "IAKitPreferences.defaultTransformerName"
        static let dTokenizerName = "IAKitPreferences.defaultTokenizerName"
        //static let maxSavedImageDimensions = "IAKitPreferences.maxSavedImageDimensions" //constant
        
        static let oTokenizerName = "IAKitPreferences.overridingTokenizerName"
        static let oTransformerName = "IAKitPreferences.overridingTransformerName"
        
        static let deviceResourcesLimited = "IAKitPreferences.deviceResourcesLimited"
        
        static let touchInterpreterName = "IAKitPreferences.touchInterpreterName"
        static let rawIntensityMapperName = "IAKitPreferences.rawIntensityMapperName"
        static let spellingSuggestionsEnabled = "IAKitPreferences.spellingSuggestions"
        static let animationEnabled = "IAKitPreferences.animationEnabled"
        
        static let visualPreferences = "IAKitPreferences.visualPrefs"
        
    }
    
    
    fileprivate static var _defaultIntensity:Int = {return (UserDefaults.standard.object(forKey: Keys.dIntensity) as? Int) ?? 40}()
    open static var defaultIntensity:Int {
        get {return _defaultIntensity}
        set {_defaultIntensity = newValue; UserDefaults.standard.set(newValue, forKey: Keys.dIntensity)}
    }
    fileprivate static var _defaultTextSize:Int = {return (UserDefaults.standard.object(forKey: Keys.dTextSize) as? Int) ?? 20}()
    open static var defaultTextSize:Int {
        get {return _defaultTextSize}
        set {_defaultTextSize = newValue; UserDefaults.standard.set(newValue, forKey: Keys.dTextSize)}
    }
    
    fileprivate static var _defaultTransformer:IntensityTransformers = {
        return IntensityTransformers(rawValue: (UserDefaults.standard.object(forKey: Keys.dTransformerName) as? String) ?? "") ?? IntensityTransformers.WeightScheme
    }()
    open static var defaultTransformer:IntensityTransformers {
        get {return _defaultTransformer}
        set {
            _defaultTransformer = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.dTransformerName)
        }
    }
    
    fileprivate static var _defaultTokenizer:IAStringTokenizing = {
        return IAStringTokenizing(shortLabel: (UserDefaults.standard.object(forKey: Keys.dTokenizerName) as? String) ?? "") ?? IAStringTokenizing.Char
    }()
    open static var defaultTokenizer:IAStringTokenizing{
        get {return _defaultTokenizer}
        set {_defaultTokenizer = newValue; UserDefaults.standard.set(newValue.shortLabel, forKey: Keys.dTokenizerName)}
    }
    
    
    static let maxSavedImageDimensions:CGSize = CGSize(width: 640, height: 640)
    

    fileprivate static var _overridesTransformer:IntensityTransformers? = {
        guard let transformerName = UserDefaults.standard.object(forKey: Keys.oTransformerName) as? String else {return nil}
        return IntensityTransformers(rawValue: transformerName)
    }()
    open static var overridesTransformer:IntensityTransformers? {
        get {return _overridesTransformer}
        set {_overridesTransformer = newValue; UserDefaults.standard.set(newValue?.rawValue, forKey: Keys.oTransformerName)}
    }
    
    fileprivate static var _overridesTokenizer:IAStringTokenizing? = {
        guard let tokenizerName = UserDefaults.standard.object(forKey: Keys.oTokenizerName) as? String else {return nil}
        return IAStringTokenizing(shortLabel: tokenizerName)
    }()
    open static var overridesTokenizer:IAStringTokenizing? {
        get {return _overridesTokenizer}
        set {_overridesTokenizer = newValue; UserDefaults.standard.set(newValue?.shortLabel, forKey: Keys.oTokenizerName)}
    }

    //static var forceIntensityMapping:ForceIntensityMappingFunctions.AvailableFunctions?
    
    ///caches instantiated touchInterpreter
    fileprivate static var _touchInterpreter:IATouchInterpreter = {
        if let tiName = UserDefaults.standard.object(forKey: Keys.touchInterpreterName) as? String {
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
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.touchInterpreterName)
            RawIntensity.touchInterpreter = newValue
        }
    }
    
    ///caches current value of rawIntensityMapper in instantiated form
    fileprivate static var _rawIntensityMapper:RawIntensityMapping = {
        if let rawName = UserDefaults.standard.object(forKey: Keys.rawIntensityMapperName) as? String {
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
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.rawIntensityMapperName)
            RawIntensity.rawIntensityMapping = newValue
        }
    }
    
    fileprivate static var _deviceResourcesLimited:Bool = (UserDefaults.standard.object(forKey: Keys.deviceResourcesLimited) as? Bool) ?? (MemoryLayout<Int>.size == 4)
    /// This flag determines if the kit should skimp on animations whereever possible. By default this will be true for 32bit devices (32 bit iPhones supporting iOS 9 include 4s,5,5c)
    static var deviceResourcesLimited:Bool {
        get {return _deviceResourcesLimited}
        set {
            _deviceResourcesLimited = newValue
            UserDefaults.standard.set(newValue, forKey: Keys.deviceResourcesLimited)
        }
    }
    
    fileprivate static var _spellingSuggestionsEnabled:Bool = (UserDefaults.standard.object(forKey: Keys.spellingSuggestionsEnabled) as? Bool) ?? true
    /// Determines if the IAKeyboard show the suggestions bar.
    static var spellingSuggestionsEnabled:Bool {
        get {return _spellingSuggestionsEnabled}
        set {
            _spellingSuggestionsEnabled = newValue
            UserDefaults.standard.set(newValue, forKey: Keys.spellingSuggestionsEnabled)
            keyboard.suggestionBarActive = newValue
        }
    }
    
    fileprivate static var _animationEnabled:Bool = (UserDefaults.standard.object(forKey: Keys.animationEnabled) as? Bool) ?? true
    /// Determines if the IAKeyboard show the suggestions bar.
    static var animationEnabled:Bool {
        get {return _animationEnabled}
        set {
            _animationEnabled = newValue
            UserDefaults.standard.set(newValue, forKey: Keys.animationEnabled)
            keyboard.suggestionBarActive = newValue
        }
    }
    
    
    static var iaStringDefaultBaseOptions:IAStringOptions {
        return IAStringOptions(renderScheme: defaultTransformer, preferedSmoothing: defaultTokenizer, animates: animationEnabled, animationOptions: nil)
    }
    
    static var iaStringOverridingOptions:IAStringOptions {
        return IAStringOptions(renderScheme: overridesTransformer, preferedSmoothing: overridesTokenizer, animates: animationEnabled, animationOptions: nil)
    }

    fileprivate static var _visualPreferences:IAKitVisualPreferences = IAKitVisualPreferences(archive: UserDefaults.standard.object(forKey: Keys.visualPreferences) as? Data) ?? IAKitVisualPreferences.Default
    ///Keyboard and accessory visual characteristics. Note: changes made after IAKeyboard/IAAccessory have been instantiated won't be reflected until IAKitPreferences.resetKBAndAccessory() is called.
    open static var visualPreferences:IAKitVisualPreferences {
        get{return _visualPreferences}
        set{
            _visualPreferences = newValue
            UserDefaults.standard.set(newValue.convertToArchive(), forKey: Keys.visualPreferences)
        }
    }
    
    open static var videoAttachmentQuality:UIImagePickerControllerQualityType = .typeMedium
    open static var videoAttachmentMaxDuration:TimeInterval = 10.0
}



