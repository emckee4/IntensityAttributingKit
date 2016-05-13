//
//  IATextRange.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/4/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


public class IATextPosition:UITextPosition, IntegerLiteralConvertible, Comparable {
    let position:Int
    
    required public init(integerLiteral value: IntegerLiteralType) {
        self.position = value
        super.init()
    }
    
    public init(_ position:Int) {
        self.position = position
        super.init()
    }
    
    public override var description: String {
        return position.description
    }
    
    public func positionWithOffset(offset:Int)->IATextPosition{
        return IATextPosition(self.position + offset)
    }
}

@warn_unused_result public func ==(lhs:IATextPosition,rhs:IATextPosition)->Bool {
    return lhs.position == rhs.position
}
@warn_unused_result public func !=(lhs:IATextPosition,rhs:IATextPosition)->Bool {
    return !(lhs == rhs)
}
@warn_unused_result public func >=(lhs:IATextPosition,rhs:IATextPosition)->Bool {
    return lhs.position >= rhs.position
}
@warn_unused_result public func <=(lhs:IATextPosition,rhs:IATextPosition)->Bool {
    return lhs.position <= rhs.position
}
@warn_unused_result public func >(lhs:IATextPosition,rhs:IATextPosition)->Bool {
    return lhs.position > rhs.position
}
@warn_unused_result public func <(lhs:IATextPosition,rhs:IATextPosition)->Bool {
    return lhs.position < rhs.position
}


public class IATextRange:UITextRange {
    
    ///iaStart stores the IATextPosition object which is accessed by the start:UITextPosition computed property
    let iaStart:IATextPosition
    override public var start: UITextPosition {
        return iaStart
    }
    
    ///iaEnd stores the IATextPosition object which is accessed by the end:UITextPosition computed property
    let iaEnd:IATextPosition
    override public var end:UITextPosition {
        return iaEnd
    }
    
    override public var empty: Bool {
        return iaStart == iaEnd
    }
    
    init(start:IATextPosition,end:IATextPosition){
        self.iaStart = start
        self.iaEnd = end
        super.init()
    }
    
    init(range:Range<Int>){
        self.iaStart = IATextPosition(range.startIndex)
        self.iaEnd = IATextPosition(range.endIndex)
        super.init()
    }
    
    init(nsrange:NSRange){
        self.iaStart = IATextPosition(nsrange.location)
        self.iaEnd = IATextPosition(nsrange.location + nsrange.length)
        super.init()
    }
    
    func range()->Range<Int>{
        return iaStart.position..<iaEnd.position
    }
    func nsrange()->NSRange{
        return NSMakeRange(iaStart.position, iaEnd.position - iaStart.position)
    }

    public override var description: String {
        return "IATextRange(\(iaStart),\(iaEnd))"
    }
    
    func contains(position:IATextPosition)->Bool{
        return position >= iaStart && position < iaEnd
    }
}

//@warn_unused_result public func ==(lhs:IATextRange,rhs:IATextRange)->Bool {
//    return lhs.iaStart == rhs.iaStart && lhs.iaEnd == rhs.iaEnd
//}
//
//@warn_unused_result public func !=(lhs:IATextRange,rhs:IATextRange)->Bool {
//    return !(lhs == rhs)
//}


