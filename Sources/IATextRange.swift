//
//  IATextRange.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/4/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///IATextPosition is the UITextPosition subclass necessary for reimplementation of UITextInput. The position is integer is public in the unlike the superclass in which it is private and inaccessable.
open class IATextPosition:UITextPosition, ExpressibleByIntegerLiteral, Comparable {
    let position:Int
    
    required public init(integerLiteral value: IntegerLiteralType) {
        self.position = value
        super.init()
    }
    
    public init(_ position:Int) {
        self.position = position
        super.init()
    }
    
    open override var description: String {
        return position.description
    }
    
    open func positionWithOffset(_ offset:Int)->IATextPosition{
        return IATextPosition(self.position + offset)
    }
}

public func ==(lhs:IATextPosition,rhs:IATextPosition)->Bool {
    return lhs.position == rhs.position
}
public func !=(lhs:IATextPosition,rhs:IATextPosition)->Bool {
    return !(lhs == rhs)
}
public func >=(lhs:IATextPosition,rhs:IATextPosition)->Bool {
    return lhs.position >= rhs.position
}
public func <=(lhs:IATextPosition,rhs:IATextPosition)->Bool {
    return lhs.position <= rhs.position
}
public func >(lhs:IATextPosition,rhs:IATextPosition)->Bool {
    return lhs.position > rhs.position
}
public func <(lhs:IATextPosition,rhs:IATextPosition)->Bool {
    return lhs.position < rhs.position
}

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
    
    init(start:IATextPosition,end:IATextPosition){
        self.iaStart = start
        self.iaEnd = end
        super.init()
    }
    
    init(range:CountableRange<Int>){
        self.iaStart = IATextPosition(range.lowerBound)
        self.iaEnd = IATextPosition(range.upperBound)
        super.init()
    }
    
    init(nsrange:NSRange){
        self.iaStart = IATextPosition(nsrange.location)
        self.iaEnd = IATextPosition(nsrange.location + nsrange.length)
        super.init()
    }
    
    func range()->CountableRange<Int>{
        return iaStart.position..<iaEnd.position
    }
    func nsrange()->NSRange{
        return NSMakeRange(iaStart.position, iaEnd.position - iaStart.position)
    }

    open override var description: String {
        return "IATextRange(\(iaStart),\(iaEnd))"
    }
    
    func contains(_ position:IATextPosition)->Bool{
        return position >= iaStart && position < iaEnd
    }
}

public func ==(lhs:IATextRange,rhs:IATextRange)->Bool {
    return lhs.iaStart == rhs.iaStart && lhs.iaEnd == rhs.iaEnd
}

public func !=(lhs:IATextRange,rhs:IATextRange)->Bool {
    return !(lhs == rhs)
}


