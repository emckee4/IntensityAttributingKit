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
        case .Tiny: return CGSize(width: 32, height: 32)
        case .Small: return CGSize(width: 64, height: 64)
        case .Medium: return CGSize(width: 160, height: 160)
        }
    }
    
    init?(rawOptional:String?){
        if let raw = rawOptional {
            self.init(rawValue:raw)
        } else {
            return nil
        }
    }
}
