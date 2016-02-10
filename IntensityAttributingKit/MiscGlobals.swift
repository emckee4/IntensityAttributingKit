

import UIKit


@warn_unused_result public func bound<T : Comparable>(value: T, lowerBound lower: T, upperBound upper: T) -> T{
    return min(max(value, lower),upper)
}


extension NSRange {
    var intRange:Range<Int> {
        return self.location..<(self.location + self.length)
    }
}

extension Range where Element:SignedIntegerType {
    var nsRange:NSRange {
        let start = self.startIndex as! Int
        let end = self.endIndex as! Int
        return NSRange(location: start, length: end - start)
    }
}

func binNumberForSteps(intensity:Int, steps:Int)->Int{
    return bound((steps * intensity) / 100, lowerBound: 0, upperBound: steps - 1)
}


func ==<T:Equatable>(tuple1:(T,T),tuple2:(T,T))->Bool{
    return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
}

func ==(lhs:NSRange,rhs:NSRange)->Bool {
    return NSEqualRanges(lhs, rhs)
}
func !=(lhs:NSRange,rhs:NSRange)->Bool {
    return !NSEqualRanges(lhs, rhs)
}


//let ReplacementChar:String = "\u{FFFC}"
//let ReplacementCodeUnit:UInt16 = "\u{FFFC}".utf16.first!

//internal extension String {
//    static var ReplacementChar:String {return "\u{FFFC}"}
//}




