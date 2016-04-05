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
}

@warn_unused_result public func ==(lhs:IATextPosition,rhs:IATextPosition)->Bool {
    return lhs.position == rhs.position
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


public class IATextRange:UITextRange{
    
    let _start:IATextPosition
    override public var start: UITextPosition {
        return _start
    }
    
    let _end:IATextPosition
    override public var end:UITextPosition {
        return _end
    }
    
    override public var empty: Bool {
        return _start == _end
    }
    
    init(start:IATextPosition,end:IATextPosition){
        self._start = start
        self._end = end
        super.init()
    }
    
    init(range:Range<Int>){
        self._start = IATextPosition(range.startIndex)
        self._end = IATextPosition(range.endIndex)
        super.init()
    }
    
    init(nsrange:NSRange){
        self._start = IATextPosition(nsrange.location)
        self._end = IATextPosition(nsrange.location + nsrange.length)
        super.init()
    }
    
    func range()->Range<Int>{
        return _start.position..<_end.position
    }
    func nsrange()->NSRange{
        return NSMakeRange(_start.position, _end.position - _start.position)
    }

    public override var description: String {
        return "IATextRange(\(_start),\(_end))"
    }
}





