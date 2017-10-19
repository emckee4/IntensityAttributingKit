//
//  IATextRange.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/4/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///IATextRange is the UITextRange subclass necessary for reimplementation of UITextInput. It provides convenience functions for converting to/from CountableRange<Int> and NSRange types.
open class IATextRange:UITextRange {
    
    ///iaStart stores the IATextPosition object which is accessed by the start:UITextPosition computed property
    let iaStart:IATextPosition
    override open var start: UITextPosition {
        return iaStart
    }
    
    ///iaEnd stores the IATextPosition object which is accessed by the end:UITextPosition computed property
    let iaEnd:IATextPosition
    override open var end:UITextPosition {
        return iaEnd
    }
    
    override open var isEmpty: Bool {
        return iaStart == iaEnd
    }
    
    open var count:Int {
        return iaEnd.position - iaStart.position
    }
    
    init(start:IATextPosition,end:IATextPosition){
        self.iaStart = start
        self.iaEnd = end
        super.init()
    }
    
    init!(range:CountableRange<Int>, string:String){
        let start = String.Index(encodedOffset: range.startIndex)
        let end = String.Index(encodedOffset: range.endIndex)
        guard string.validate(index: start, allowEndIndex: true) && string.validate(index: end, allowEndIndex: true) else {return nil}
        self.iaStart = IATextPosition(string.distance(from: string.startIndex, to: start))
        self.iaEnd = IATextPosition(string.distance(from: string.startIndex, to: end))
        super.init()
    }
    
    init!(nsrange:NSRange, string:String){
        let start = String.Index(encodedOffset: nsrange.location)
        let end = String.Index(encodedOffset: nsrange.location + nsrange.length)
        guard string.validate(index: start, allowEndIndex: true) && string.validate(index: end, allowEndIndex: true) else {return nil}
        self.iaStart = IATextPosition(string.distance(from: string.startIndex, to: start))
        self.iaEnd = IATextPosition(string.distance(from: string.startIndex, to: end))
        super.init()
    }
    
    ///UTF16 index based countable range
    func range(inString string:String)->CountableRange<Int>{
        let startOffset = string.index(string.startIndex, offsetBy: self.iaStart.position).encodedOffset
        let endOffset = string.index(string.startIndex, offsetBy: self.iaEnd.position).encodedOffset
        return startOffset..<endOffset
    }
    
    func nsrange(inString string:String)->NSRange{
        let startOffset = string.index(string.startIndex, offsetBy: self.iaStart.position).encodedOffset
        let endOffset = string.index(string.startIndex, offsetBy: self.iaEnd.position).encodedOffset
        return NSRange(location: startOffset, length: endOffset - startOffset)
    }
    
    //MARK:- IAString variants
    
    convenience init!(range:CountableRange<Int>, iaString:IAString){
        self.init(range: range, string: iaString.text)
    }
    
    convenience init!(nsrange:NSRange, iaString:IAString){
        self.init(nsrange:nsrange, string:iaString.text)
    }
    
    ///UTF16 index based countable range
    func range(inIAString iaString:IAString)->CountableRange<Int>{
        return range(inString: iaString.text)
    }
    
    func nsrange(inIAString iaString:IAString)->NSRange{
        return nsrange(inString: iaString.text)
    }
    
    func stringRange(string:String) -> Range<String.Index>? {
        let start = string.index(string.startIndex, offsetBy: iaStart.position)
        guard let end = string.index(string.startIndex, offsetBy: iaEnd.position, limitedBy: string.endIndex) else {
            return nil
        }
        return start..<end
    }
    
    open override var description: String {
        return "IATextRange(\(iaStart),\(iaEnd))"
    }
    
    func contains(_ position:IATextPosition)->Bool{
        return position >= iaStart && position < iaEnd
    }

    public static func ==(lhs:IATextRange,rhs:IATextRange)->Bool {
        return lhs.iaStart == rhs.iaStart && lhs.iaEnd == rhs.iaEnd
    }
    
    public static func !=(lhs:IATextRange,rhs:IATextRange)->Bool {
        return !(lhs == rhs)
    }
}




