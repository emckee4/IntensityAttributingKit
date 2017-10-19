//
//  IATextPosition.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/17/17.
//  Copyright © 2017 McKeeMaKer. All rights reserved.
//

import UIKit

///IATextPosition is the UITextPosition subclass necessary for reimplementation of UITextInput. The position is integer is public in the unlike the superclass in which it is private and inaccessable.
open class IATextPosition:UITextPosition, ExpressibleByIntegerLiteral, Comparable {
    ///Character position
    let position:Int
    
    required public init(integerLiteral value: IntegerLiteralType) {
        self.position = value
        super.init()
    }
    
    public init(_ position:Int) {
        self.position = position
        super.init()
    }
    
    public init!(utf16Location loc:Int, string:String) {
        let index = String.Index(encodedOffset: loc)
        guard string.validate(index: index, allowEndIndex: true) else {return nil}
        self.position = string.distance(from: string.startIndex, to: index)
        super.init()
    }
    
    convenience public init!(utf16Location loc:Int, iaString:IAString) {
        self.init(utf16Location: loc, string: iaString.text)
    }
    
    open override var description: String {
        return position.description
    }
    
    open func withCharacterOffset(_ offset:Int, string:String)->IATextPosition!{
        guard position + offset >= 0 && position + offset <= string.count else {return nil}
        let offsetIndex = string.index(string.startIndex, offsetBy: position + offset)
        return IATextPosition(string.distance(from: string.startIndex, to: offsetIndex))
    }
    
    open func withCharacterOffset(_ offset:Int, iaString:IAString)->IATextPosition!{
        return withCharacterOffset(offset, string: iaString.text)
    }
    
    ///returns a new position with a validated UTF16 offset
    open func withUTF16Offset(_ offset:Int, string:String)->IATextPosition!{
        let newUTF16position = self.utf16Position(inIAString: string) + offset
        return IATextPosition(utf16Location: newUTF16position, string: string)
    }
    
    ///returns a new position with a validated UTF16 offset
    open func withUTF16Offset(_ offset:Int, iaString:IAString)->IATextPosition!{
        return withUTF16Offset(offset, string: iaString.text)
    }
    
    func utf16Position(inIAString string:String) -> Int {
        return string.index(string.startIndex, offsetBy: position).encodedOffset
    }
    
    func utf16Position(inIAString iaString:IAString) -> Int {
        return utf16Position(inIAString: iaString.text)
    }
    
    public static func ==(lhs:IATextPosition,rhs:IATextPosition)->Bool {
        return lhs.position == rhs.position
    }
    public static func !=(lhs:IATextPosition,rhs:IATextPosition)->Bool {
        return !(lhs == rhs)
    }
    public static func >=(lhs:IATextPosition,rhs:IATextPosition)->Bool {
        return lhs.position >= rhs.position
    }
    public static func <=(lhs:IATextPosition,rhs:IATextPosition)->Bool {
        return lhs.position <= rhs.position
    }
    public static func >(lhs:IATextPosition,rhs:IATextPosition)->Bool {
        return lhs.position > rhs.position
    }
    public static func <(lhs:IATextPosition,rhs:IATextPosition)->Bool {
        return lhs.position < rhs.position
    }
}


