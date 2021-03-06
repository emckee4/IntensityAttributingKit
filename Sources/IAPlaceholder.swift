//
//  IAPlaceholder.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/24/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation

struct IAPlaceholder {
    
    static func forSize(_ thumbsize:IAThumbSize, attachType:IAAttachmentType!)->UIImage!{
        guard let attachType = attachType else {return unknownPlaceholder(forSize: thumbsize)}
        switch attachType {
        case .image:
            return imagePlaceholder(forSize: thumbsize)
        case .video:
            return videoPlaceholder(forSize: thumbsize)
        case .location:
            return locationPlaceholder(forSize: thumbsize)
        case .unknown:
            return unknownPlaceholder(forSize: thumbsize)
        }
    }
    
    ///Yields the image placeholder for self.size
    static func imagePlaceholder(forSize size:ThumbSize)->UIImage!{
        guard Thread.isMainThread else {return nil}
        switch size {
        case .Tiny: return imageBoxedTiny
        case .Small: return imageBoxedSmall
        case .Medium: return imageBoxedMedium
        }
    }
    
    ///Yields the video placeholder for self.size
    static func videoPlaceholder(forSize size:ThumbSize)->UIImage!{
        guard Thread.isMainThread else {return nil}
        switch size {
        case .Tiny: return videoBoxedTiny
        case .Small: return videoBoxedSmall
        case .Medium: return videoBoxedMedium
        }
    }
    
    
    ///Yields the location placeholder for self.size
    static func locationPlaceholder(forSize size:ThumbSize)->UIImage!{
        guard Thread.isMainThread else {return nil}
        switch size {
        case .Tiny: return locationBoxedTiny
        case .Small: return locationBoxedSmall
        case .Medium: return locationBoxedMedium
        }
    }
    
    ///Yields the unknown attachment placeholder for self.size
    static func unknownPlaceholder(forSize size:ThumbSize)->UIImage!{
        guard Thread.isMainThread else {return nil}
        switch size {
        case .Tiny: return unknownBoxedTiny
        case .Small: return unknownBoxedSmall
        case .Medium: return unknownBoxedMedium
        }
    }
    
    
    //FIXME: Using image placeholders until new placeholders added.
    
    static let imageBoxedTiny = {
        return UIImage(named: "imagePlaceholderBoxedTiny", in: IAKitPreferences.bundle, compatibleWith: UIScreen.main.traitCollection)!
    }()
    static let imageBoxedSmall = {
        return UIImage(named: "imagePlaceholderBoxedSmall", in: IAKitPreferences.bundle, compatibleWith: UIScreen.main.traitCollection)!
    }()
    static let imageBoxedMedium = {
        return UIImage(named: "imagePlaceholderBoxedMedium", in: IAKitPreferences.bundle, compatibleWith: UIScreen.main.traitCollection)!
    }()
    
    static let videoBoxedTiny = {
        return UIImage(named: "videoPlaceholderTiny", in: IAKitPreferences.bundle, compatibleWith: UIScreen.main.traitCollection)!
    }()
    static let videoBoxedSmall = {
        return UIImage(named: "videoPlaceholderSmall", in: IAKitPreferences.bundle, compatibleWith: UIScreen.main.traitCollection)!
    }()
    static let videoBoxedMedium = {
        return UIImage(named: "videoPlaceholderMedium", in: IAKitPreferences.bundle, compatibleWith: UIScreen.main.traitCollection)!
    }()
    
    static let locationBoxedTiny = {
        return UIImage(named: "locationPlaceholderTiny", in: IAKitPreferences.bundle, compatibleWith: UIScreen.main.traitCollection)!
    }()
    static let locationBoxedSmall = {
        return UIImage(named: "locationPlaceholderSmall", in: IAKitPreferences.bundle, compatibleWith: UIScreen.main.traitCollection)!
    }()
    static let locationBoxedMedium = {
        return UIImage(named: "locationPlaceholderMedium", in: IAKitPreferences.bundle, compatibleWith: UIScreen.main.traitCollection)!
    }()
    
    static let unknownBoxedTiny = {
        return UIImage(named: "imagePlaceholderBoxedTiny", in: IAKitPreferences.bundle, compatibleWith: UIScreen.main.traitCollection)!
    }()
    static let unknownBoxedSmall = {
        return UIImage(named: "imagePlaceholderBoxedSmall", in: IAKitPreferences.bundle, compatibleWith: UIScreen.main.traitCollection)!
    }()
    static let unknownBoxedMedium = {
        return UIImage(named: "imagePlaceholderBoxedMedium", in: IAKitPreferences.bundle, compatibleWith: UIScreen.main.traitCollection)!
    }()
}

