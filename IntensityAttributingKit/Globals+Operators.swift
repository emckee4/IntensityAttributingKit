

import UIKit


public func clamp<T : Comparable>(_ value: T, lowerBound lower: T, upperBound upper: T) -> T{
    return min(max(value, lower),upper)
}


func ==(lhs:NSRange,rhs:NSRange)->Bool {
    return NSEqualRanges(lhs, rhs)
}
func !=(lhs:NSRange,rhs:NSRange)->Bool {
    return !NSEqualRanges(lhs, rhs)
}



struct UTITypes {
    static let PlainText = "public.utf8-plain-text"
    static let RTFD = "com.apple.flat-rtfd"
    static let IAStringArchive = "com.mckeemaker.IAStringArchive"
}



