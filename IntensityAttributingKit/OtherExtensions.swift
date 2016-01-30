//
//  OtherExtensions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/26/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit



extension NSLayoutConstraint {
    func activateWithPriority(priority:Float)->NSLayoutConstraint{
        self.priority = priority
        self.active = true
        return self
    }
}


extension CGSize {
    ///Returns the largest CGSize that will fit in the provided container size without changing the aspect ratio
    func sizeThatFitsMaintainingAspect(containerSize containerSize:CGSize, expandIfRoom:Bool = false)->CGSize{
        let widthScaleFactor =  containerSize.width / self.width
        let heightScaleFactor = containerSize.height / self.height
        if widthScaleFactor >= 1.0 && heightScaleFactor >= 1.0 {
            if expandIfRoom == false {
                return self
            }else {
                let newScale = min(widthScaleFactor,heightScaleFactor)
                return CGSizeApplyAffineTransform(self, CGAffineTransformMakeScale(newScale, newScale))
            }
        } else {
            let newScale = min(widthScaleFactor,heightScaleFactor)
            return CGSizeApplyAffineTransform(self, CGAffineTransformMakeScale(newScale, newScale))
        }
    }
}


extension String {
    ///This takes a Range<Int> and returns a substring corresponding to this. If the start or end indeces bisect a grapheme cluster then the start or end will show as substitution characters. To check for this, use subStringFromRangeValidated instead.
    func subStringFromRange(range:Range<Int>)->String{
        let nsRange = NSRange(location: range.startIndex, length: range.endIndex - range.startIndex)
        return (self as NSString).substringWithRange(nsRange)
    }
    ///This takes a Range<Int> and returns a substring corresponding to this. If the start or end indeces bisect a grapheme cluster then this may return nil.
    func subStringFromRangeValidated(range:Range<Int>)->String?{
        let nsRange = NSRange(location: range.startIndex, length: range.endIndex - range.startIndex)
        let sub = (self as NSString).substringWithRange(nsRange)
        if sub.unicodeScalars.first?.value == 0xfffd || sub.unicodeScalars.last?.value == 0xFFFD {return nil}
        return sub
    }
    
    ///Attempts to convert an Int valued index into a CharacterView Index
    func indexFromInt(intIndex:Int)->String.Index?{
        let utf16Start = self.utf16.startIndex.advancedBy(intIndex)
        return String.Index.init(utf16Start, within: self)
    }
    
    
    mutating func removeIntRange(range:Range<Int>) throws{
        guard let start = indexFromInt(range.startIndex), end = indexFromInt(range.endIndex) else {throw NSError(domain: "String.removeIntRange", code: -2, userInfo: [NSLocalizedDescriptionKey: "Bad indeces"])}
        self.removeRange(Range<Index>(start:start,end:end))
    }
}

//extension String {
//    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
//        let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
//        let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
//        if let from = String.Index(from16, within: self),
//            let to = String.Index(to16, within: self) {
//                return from ..< to
//        }
//        return nil
//    }
//}