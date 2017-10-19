//
//  String+Extensions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/23/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation

extension String {
    
    static var kReplacementChar:String {return "\u{FFFC}"}
    
    ///This takes a CountableRange<Int> and returns a substring corresponding to this. If the start or end indeces bisect a grapheme cluster then the start or end will show as substitution characters. To check for this, use subStringFromRangeValidated instead.
    func subStringFromRange(_ range:CountableRange<Int>)->String{
        let nsRange = NSRange(location: range.lowerBound, length: range.upperBound - range.lowerBound)
        return (self as NSString).substring(with: nsRange)
    }
    ///This takes a CountableRange<Int> and returns a substring corresponding to this. If the start or end indeces bisect a grapheme cluster then this may return nil.
    func subStringFromRangeValidated(_ range:CountableRange<Int>)->String?{
        let nsRange = NSRange(location: range.lowerBound, length: range.upperBound - range.lowerBound)
        let sub = (self as NSString).substring(with: nsRange)
        if sub.unicodeScalars.first?.value == 0xfffd || sub.unicodeScalars.last?.value == 0xFFFD {return nil}
        return sub
    }
    
    ///Attempts to convert an Int valued index into a CharacterView Index
    func indexFromInt(_ intIndex:Int)->String.Index?{
        //let utf16Start = self.utf16.startIndex.advancedBy(intIndex) //swift 2.3, below is prospective replacement
        let utf16Start = self.utf16.index(self.utf16.startIndex, offsetBy: intIndex)
        return String.Index.init(utf16Start, within: self)
    }
    
    
    mutating func removeIntRange(_ range:CountableRange<Int>) throws{
        guard let start = indexFromInt(range.lowerBound), let end = indexFromInt(range.upperBound) else {throw NSError(domain: "String.removeIntRange", code: -2, userInfo: [NSLocalizedDescriptionKey: "Bad indeces"])}
        self.removeSubrange(start..<end)
    }
    
    mutating func removeNSRange(_ range:NSRange) {
        let nsm = (self as NSString).mutableCopy() as! NSMutableString
        nsm.deleteCharacters(in: range)
        self = nsm as String
    }
    
    ///Random upper/lowercase letters with length
    public static func randomAlphaString(_ length:Int)->String{
        let baseString:NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var outputString = ""
        
        for _ in 0..<length {
            let rand = Int(arc4random_uniform(UInt32(baseString.length)))
            outputString += baseString.substring(with: NSMakeRange(rand, 1))
        }
        return outputString
    }
    
    ///Validates an index as existing in this string
    func validate(index:String.Index, allowEndIndex:Bool = false) -> Bool {
        return self.indices.contains(index) || (allowEndIndex && self.endIndex == index)
    }
    
}

