

import UIKit


@warn_unused_result public func bound<T : Comparable>(value: T, min minimum: T, max maximum: T) -> T{
    return min(max(value, minimum),maximum)
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

public func binNumberForSteps(intensity:Int, steps:Int)->Int{
    return bound((intensity * 10 / steps * 10), min: 0, max: steps - 1)
}


func == <T:Equatable> (tuple1:(T,T),tuple2:(T,T)) -> Bool
{
    return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
}

//let ReplacementChar:String = "\u{FFFC}"
//let ReplacementCodeUnit:UInt16 = "\u{FFFC}".utf16.first!


//public let fontWeightArray = [
//    UIFontWeightUltraLight,
//    UIFontWeightThin,
//    UIFontWeightLight,
//    UIFontWeightRegular,
//    UIFontWeightMedium,
//    UIFontWeightSemibold,
//    UIFontWeightBold,
//    UIFontWeightHeavy,
//    UIFontWeightBlack
//]


//func







