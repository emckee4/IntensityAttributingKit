

import UIKit


@warn_unused_result public func bound<T : Comparable>(value: T, min minimum: T, max maximum: T) -> T{
    return min(max(value, minimum),maximum)
}


extension NSRange {
    var intRange:Range<Int> {
        return self.location..<(self.location + self.length)
    }
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







