//
//  String+Extensions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/23/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation

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
        self.removeRange(start..<end)
    }
    
    mutating func removeNSRange(range:NSRange) {
        let nsm = (self as NSString).mutableCopy() as! NSMutableString
        nsm.deleteCharactersInRange(range)
        self = nsm as String
    }
    
    ///Random upper/lowercase letters with length
    static func randomAlphaString(length:Int)->String{
        let baseString:NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var outputString = ""
        
        for _ in 0..<length {
            let rand = Int(arc4random_uniform(UInt32(baseString.length)))
            outputString += baseString.substringWithRange(NSMakeRange(rand, 1))
        }
        return outputString
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