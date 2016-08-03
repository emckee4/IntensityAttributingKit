//
//  KeysetComponents.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/5/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

/**
The current version of IAKeyset and its associatated types is built for the simplest layout of the IAKeyboard in which we only worry about changing the keys of the q, a, and z rows, and we only use single character keys (no expanding keys) throughout.
 Later I'd like to expand the capabilities of this by allowing:
 loading of keysets from plists and other external files,
 multi-keys (i.e. expanding) in all positions,
 and some ability to vary some of the keys on the spacebar row, possibly based on size classes.
*/
class IAKeyset {
    var keysetName:String
    var currentKeyPage:Int = 0
    var totalKeyPages:Int {return keyPages.count}
    var keyPages:[IAKeyPage]
    
    init(name:String, keyPages:[IAKeyPage]){
        self.keysetName = name
        self.keyPages = keyPages
    }
    
}

class IAKeyPage {
    var pageName:String?
    var qRow:[IAKeyType]
    var aRow:[IAKeyType]
    var zRow:[IAKeyType]
    //var spaceRow:[IAKeyType]  //to be added later
    
    init(pageName:String? = nil, qRow:[IAKeyType],aRow:[IAKeyType],zRow:[IAKeyType]){
        self.qRow = qRow
        self.aRow = aRow
        self.zRow = zRow
        self.pageName = pageName
    }
    
    init(pageName:String? = nil, qRow:[String],aRow:[String],zRow:[String]){
        self.qRow = qRow.map({IASingleCharKey(keyChar: $0)})
        self.aRow = aRow.map({IASingleCharKey(keyChar: $0)})
        self.zRow = zRow.map({IASingleCharKey(keyChar: $0)})
        self.pageName = pageName
    }
}


protocol IAKeyType {
    //var availableInSizeClasses:[(vert:UIUserInterfaceSizeClass, horiz:UIUserInterfaceSizeClass)]
}

///This indicates a key with a single value should be presented (of type PressureKeyActionType.CharInsert)
struct IASingleCharKey:IAKeyType, StringLiteralConvertible, CustomStringConvertible {
    var value:String
    
    init(keyChar:String){
        self.value = keyChar
    }
    
    init(unicodeScalarLiteral value: String.UnicodeScalarLiteralType) {
        self.value = "\(value)"
    }

    init(extendedGraphemeClusterLiteral value: String.ExtendedGraphemeClusterLiteralType) {
        self.value = value
    }

    init(stringLiteral value: StringLiteralType) {
        self.value = value
    }

    
    var description:String {
        return "IASingleCharKey: \"" + value + "\""
    }
}

/////Used for representing an expanding key carrying multiple values
//struct IAMultiKey:IAKeyType {
//    
//
//    
//}
//
//struct IAReservedKey {
//    //don't change/touch these-- maybe make some indication in the keys themselves? could make tag values over 1000 for instance
//}















