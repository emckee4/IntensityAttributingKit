

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



struct UTITypes {
    static let PlainText = "public.utf8-plain-text"
    static let RTFD = "com.apple.flat-rtfd"
    static let IAStringArchive = "com.mckeemaker.IAStringArchive"
}



