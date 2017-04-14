//
//  IAKitVisualPreferences.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 7/29/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


/**
 This struct stores the values for common visual theming traits of the IAKeyboard and IAAccessory. Using init:archive and convertToArchive() it can be saved and stored as it is in the IAKitPreferences.
 */
public struct IAKitVisualPreferences:Equatable {
    public var profileName:String
    
    public var accessoryBackgroundColor:UIColor
    public var accessoryButtonBackgroundColor:UIColor
    public var accessoryTintColor:UIColor
    public var accessoryButtonBorderColor:UIColor
    public var accessoryButtonCornerRadius:CGFloat
    public var accessoryButtonBorderWidth:CGFloat
    
    public var kbBackgroundColor:UIColor
    public var kbButtonColor:UIColor
    public var kbButtonTintColor:UIColor
    public var kbSuggestionsBackgroundColor:UIColor
    public var kbSuggestionsTextColor:UIColor
    ///The keyboard suggestion bar's   height = (this value) * (keyboard character key height)   when the bar is not hidden.
    public var kbSuggestionBarScaleFactor:CGFloat = 0.75
    
    ///Init yields default values.
    public init() {
        profileName = "Custom"
        accessoryBackgroundColor = UIColor(white: 0.85, alpha: 1)
        accessoryButtonBackgroundColor = UIColor.lightGray
        accessoryTintColor = UIColor(white: 0.2, alpha: 1)
        accessoryButtonBorderColor = UIColor.darkGray
        accessoryButtonCornerRadius = 5.0
        accessoryButtonBorderWidth = 1.0
        
        kbBackgroundColor = UIColor.lightGray
        kbButtonColor = UIColor(white: 0.85, alpha: 1)
        kbButtonTintColor = UIColor.black
        kbSuggestionsBackgroundColor = UIColor(white: 0.85, alpha: 1)
        kbSuggestionsTextColor = UIColor(white: 0.2, alpha: 1)
    }

    ///Inits from an NSData archive of a dict of values stored by the convertToArchive() function.
    init!(archive:Data!){
        guard let archive = archive else {return nil}
        guard let dict = NSKeyedUnarchiver.unarchiveObject(with: archive) as? [String:AnyObject] else {return nil}
        
        guard let profileName = dict[VisualPrefKeys.accessoryBackgroundColor] as? String,
            let accessoryBackgroundColor = dict[VisualPrefKeys.accessoryBackgroundColor] as? UIColor,
            let accessoryButtonBackgroundColor = dict[VisualPrefKeys.accessoryButtonBackgroundColor] as? UIColor,
            let accessoryTintColor = dict[VisualPrefKeys.accessoryTintColor] as? UIColor,
            let accessoryButtonBorderColor = dict[VisualPrefKeys.accessoryButtonBorderColor] as? UIColor,
            let accessoryButtonCornerRadius = dict[VisualPrefKeys.accessoryButtonCornerRadius] as? CGFloat,
            let accessoryButtonBorderWidth = dict[VisualPrefKeys.accessoryButtonBorderWidth] as? CGFloat,
            
            let kbBackgroundColor = dict[VisualPrefKeys.kbBackgroundColor] as? UIColor,
            let kbButtonColor = dict[VisualPrefKeys.kbButtonColor] as? UIColor,
            let kbButtonTintColor = dict[VisualPrefKeys.kbButtonTintColor] as? UIColor,
            let kbSuggestionsBackgroundColor = dict[VisualPrefKeys.kbSuggestionsBackgroundColor] as? UIColor,
            let kbSuggestionsTextColor = dict[VisualPrefKeys.kbSuggestionsTextColor] as? UIColor,
            let kbSuggestionBarScaleFactor = dict[VisualPrefKeys.kbSuggestionBarScaleFactor] as? CGFloat
            else {return nil}
        
        self.profileName = profileName
        self.accessoryBackgroundColor = accessoryBackgroundColor
        self.accessoryButtonBackgroundColor = accessoryButtonBackgroundColor
        self.accessoryTintColor = accessoryTintColor
        self.accessoryButtonBorderColor = accessoryButtonBorderColor
        self.accessoryButtonCornerRadius = accessoryButtonCornerRadius
        self.accessoryButtonBorderWidth = accessoryButtonBorderWidth
        
        self.kbBackgroundColor = kbBackgroundColor
        self.kbButtonColor = kbButtonColor
        self.kbButtonTintColor = kbButtonTintColor
        self.kbSuggestionsBackgroundColor = kbSuggestionsBackgroundColor
        self.kbSuggestionsTextColor = kbSuggestionsTextColor
        self.kbSuggestionBarScaleFactor = kbSuggestionBarScaleFactor
    }
    
    ///Stores values in a dictionary, then returns an NSData archive of that which can be reconstitued by the init:archive function.
    func convertToArchive()->Data{
        var dict:[String:AnyObject] = [:]
        dict[VisualPrefKeys.profileName] = profileName as AnyObject?
        dict[VisualPrefKeys.accessoryBackgroundColor] = accessoryBackgroundColor
        dict[VisualPrefKeys.accessoryButtonBackgroundColor] = accessoryButtonBackgroundColor
        dict[VisualPrefKeys.accessoryTintColor] = accessoryTintColor
        dict[VisualPrefKeys.accessoryButtonBorderColor] = accessoryButtonBorderColor
        dict[VisualPrefKeys.accessoryButtonCornerRadius] = accessoryButtonCornerRadius as AnyObject?
        dict[VisualPrefKeys.accessoryButtonBorderWidth] = accessoryButtonBorderWidth as AnyObject?
        
        dict[VisualPrefKeys.kbBackgroundColor] = kbBackgroundColor
        dict[VisualPrefKeys.kbButtonColor] = kbButtonColor
        dict[VisualPrefKeys.kbButtonTintColor] = kbButtonTintColor
        dict[VisualPrefKeys.kbSuggestionsBackgroundColor] = kbSuggestionsBackgroundColor
        dict[VisualPrefKeys.kbSuggestionsTextColor] = kbSuggestionsTextColor
        dict[VisualPrefKeys.kbSuggestionBarScaleFactor] = kbSuggestionBarScaleFactor as AnyObject?
        return NSKeyedArchiver.archivedData(withRootObject: dict)
    }
    
    ///Dictionary keys used by the archiver
    fileprivate struct VisualPrefKeys {
        static let profileName = "IAKitVisualPreferences.profileName"
        
        static let accessoryBackgroundColor = "IAKitVisualPreferences.accessoryBackgroundColor"
        static let accessoryButtonBackgroundColor = "IAKitVisualPreferences.accessoryButtonBackgroundColor"
        static let accessoryTintColor = "IAKitVisualPreferences.accessoryTintColor"
        static let accessoryButtonCornerRadius = "IAKitVisualPreferences.accessoryButtonCornerRadius"
        static let accessoryButtonBorderWidth = "IAKitVisualPreferences.accessoryButtonBorderWidth"
        static let accessoryButtonBorderColor = "IAKitVisualPreferences.accessoryButtonBorderColor"
        
        static let kbBackgroundColor = "IAKitVisualPreferences.kbBackgroundColor"
        static let kbButtonColor = "IAKitVisualPreferences.kbButtonColor"
        static let kbButtonTintColor = "IAKitVisualPreferences.kbButtonTintColor"
        static let kbSuggestionsBackgroundColor = "IAKitVisualPreferences.kbSuggestionsBackgroundColor"
        static let kbSuggestionsTextColor = "IAKitVisualPreferences.kbSuggestionsTextColor"
        static let kbSuggestionBarScaleFactor = "IAKitVisualPreferences.kbSuggestionBarScaleFactor"
    }
    
    /// A basic, tasteful(ish) scheme that omits borders and other elements. Note that this is the product of the default initializer.
    public static let Default:IAKitVisualPreferences = {
        var v = IAKitVisualPreferences()
        v.profileName = "Default"
        return v
    }()
    
    /// A basic flat scheme with all grayscale features.
    public static let FlatBasicGray:IAKitVisualPreferences = {
        var v = IAKitVisualPreferences()
        v.profileName = "FlatBasicGray"
        v.accessoryBackgroundColor = UIColor(white: 0.85, alpha: 1)
        v.accessoryButtonBackgroundColor = UIColor(white: 0.85, alpha: 1)
        v.accessoryTintColor = UIColor(white: 0.2, alpha: 1)
        v.accessoryButtonBorderColor = UIColor.darkGray
        v.accessoryButtonCornerRadius = 5.0
        v.accessoryButtonBorderWidth = 0.0
        
        v.kbBackgroundColor = UIColor.lightGray
        v.kbButtonColor = UIColor(white: 0.85, alpha: 1)
        v.kbButtonTintColor = UIColor.black
        v.kbSuggestionsBackgroundColor = UIColor(white: 0.85, alpha: 1)
        v.kbSuggestionsTextColor = UIColor(white: 0.2, alpha: 1)
        return v
    }()
    
    ///Helpful for testing as everything is different, but not pleasant to look at.
    public static let Vomit:IAKitVisualPreferences = {
        var v = IAKitVisualPreferences()
        v.profileName = "Vomit"
        v.accessoryBackgroundColor = UIColor.lightGray
        v.accessoryButtonBackgroundColor = UIColor.darkGray
        v.accessoryTintColor = UIColor.red
        v.accessoryButtonBorderColor = UIColor.brown
        v.accessoryButtonCornerRadius = 5.0
        v.accessoryButtonBorderWidth = 1.0
        
        v.kbBackgroundColor = UIColor.purple
        v.kbButtonColor = UIColor.green
        v.kbButtonTintColor = UIColor.orange
        v.kbSuggestionsBackgroundColor = UIColor.brown
        v.kbSuggestionsTextColor = UIColor.yellow
        return v
    }()
    
    ///Classic windows 3.1 hotdog stand them. Clearly the best theme in here.
    public static let HotdogStand:IAKitVisualPreferences = {
        var v = IAKitVisualPreferences()
        v.profileName = "Hotdog Stand"
        v.accessoryBackgroundColor = UIColor.yellow
        v.accessoryButtonBackgroundColor = UIColor.yellow
        v.accessoryTintColor = UIColor.black
        v.accessoryButtonBorderColor = UIColor.darkGray
        v.accessoryButtonCornerRadius = 0.0
        v.accessoryButtonBorderWidth = 2.0
        
        v.kbBackgroundColor = UIColor.red
        v.kbButtonColor = UIColor.red
        v.kbButtonTintColor = UIColor.white
        v.kbSuggestionsBackgroundColor = UIColor.yellow
        v.kbSuggestionsTextColor = UIColor.black
        return v
    }()
    
}

public func ==(lhs:IAKitVisualPreferences, rhs:IAKitVisualPreferences)->Bool{
    return lhs.profileName == rhs.profileName &&
    
    lhs.accessoryBackgroundColor == rhs.accessoryBackgroundColor &&
    lhs.accessoryButtonBackgroundColor  == rhs.accessoryButtonBackgroundColor  &&
    lhs.accessoryTintColor  == rhs.accessoryTintColor  &&
    lhs.accessoryButtonBorderColor  == rhs.accessoryButtonBorderColor  &&
    lhs.accessoryButtonCornerRadius  == rhs.accessoryButtonCornerRadius  &&
    lhs.accessoryButtonBorderWidth  == rhs.accessoryButtonBorderWidth  &&
    
    lhs.kbBackgroundColor  == rhs.kbBackgroundColor  &&
    lhs.kbButtonColor  == rhs.kbButtonColor  &&
    lhs.kbButtonTintColor  == rhs.kbButtonTintColor  &&
    lhs.kbSuggestionsBackgroundColor  == rhs.kbSuggestionsBackgroundColor  &&
    lhs.kbSuggestionsTextColor  == rhs.kbSuggestionsTextColor  &&
        
    lhs.kbSuggestionBarScaleFactor  == rhs.kbSuggestionBarScaleFactor
}

public func !=(lhs:IAKitVisualPreferences, rhs:IAKitVisualPreferences)->Bool{
    return !(lhs == rhs)
}

