//
//  IAThumbSize.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/24/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation

///This typealias for IAThumbSize should be eventually removed; Use IAThumbSize instead.
public typealias ThumbSize = IAThumbSize

///The IAThumbSize enum contains the rects for thumbnail sizes in the IAComposite views as well as accessors for the placeholders of each size.
public enum IAThumbSize:String {
    case Tiny = "Tiny",
    Small = "Small",
    Medium = "Medium"
    
    public var size: CGSize {
        switch self {
        case .Tiny: return CGSizeMake(32, 32)
        case .Small: return CGSizeMake(64, 64)
        case .Medium: return CGSizeMake(160, 160)
        }
    }
    
    
    
    var imagePlaceholder:UIImage!{
        guard NSThread.isMainThread() else {return nil}
        switch self {
        case .Tiny: return IAThumbSize.Placeholders.ImageBoxedTiny
        case .Small: return IAThumbSize.Placeholders.ImageBoxedSmall
        case .Medium: return IAThumbSize.Placeholders.ImageBoxedMedium
        }
    }
    
    
    struct Placeholders {
        static let ImageBoxedTiny = {
            return UIImage(named: "imagePlaceholderBoxedTiny", inBundle: IAKitPreferences.bundle, compatibleWithTraitCollection: UIScreen.mainScreen().traitCollection)!
        }()
        static let ImageBoxedSmall = {
            return UIImage(named: "imagePlaceholderBoxedSmall", inBundle: IAKitPreferences.bundle, compatibleWithTraitCollection: UIScreen.mainScreen().traitCollection)!
        }()
        static let ImageBoxedMedium = {
            return UIImage(named: "imagePlaceholderBoxedMedium", inBundle: IAKitPreferences.bundle, compatibleWithTraitCollection: UIScreen.mainScreen().traitCollection)!
        }()
    }
    
    
    init?(rawOptional:String?){
        if let raw = rawOptional {
            self.init(rawValue:raw)
        } else {
            return nil
        }
    }
    
}
