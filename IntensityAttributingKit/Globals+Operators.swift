

import UIKit


@warn_unused_result public func clamp<T : Comparable>(value: T, lowerBound lower: T, upperBound upper: T) -> T{
    return min(max(value, lower),upper)
}


@warn_unused_result func ==(lhs:NSRange,rhs:NSRange)->Bool {
    return NSEqualRanges(lhs, rhs)
}
@warn_unused_result func !=(lhs:NSRange,rhs:NSRange)->Bool {
    return !NSEqualRanges(lhs, rhs)
}


//let ReplacementChar:String = "\u{FFFC}"
//let ReplacementCodeUnit:UInt16 = "\u{FFFC}".utf16.first!

//internal extension String {
//    static var ReplacementChar:String {return "\u{FFFC}"}
//}




