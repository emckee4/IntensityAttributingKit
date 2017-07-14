//
//  Range+Extensions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/23/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


//extension Range {
////    ///Returns true if there's any overlap between the two ranges, false otherwise.
////    func intersects(_ range:Range<Element>)->Bool {
////        //cases: contains, is contained in, bottom half overlaps, top half overlaps
////        if self.lowerBound >= range.upperBound || self.upperBound <= range.lowerBound {
////            return false
////        }
////        return true
////    }
//    
//    ///Returns true if this range wholly contains the provided range, false otherwise. A range with zero length will not be contained in anything.
//    func whollyContains(_ range:Range<Element>)->Bool {
//        return range.lowerBound >= self.lowerBound && range.upperBound <= self.upperBound
//    }
//    
//}
//
//extension ClosedRange {
//    ///Returns true if this range wholly contains the provided range, false otherwise. A range with zero length will not be contained in anything.
//    func whollyContains(_ range:Range<Element>)->Bool {
//        return range.lowerBound >= self.lowerBound && range.upperBound <= self.upperBound
//    }
//}

extension CountableRange {
    var nsRange:NSRange {
        let start = self.lowerBound as! Int
        let end = self.upperBound as! Int
        return NSRange(location: start, length: end - start)
    }
    
    ///Returns true if this range wholly contains the provided range, false otherwise. A range with zero length will not be contained in anything.
    func whollyContains(_ range:CountableRange<Element>)->Bool {
        return range.lowerBound >= self.lowerBound && range.upperBound <= self.upperBound
    }
}

//extension CountableClosedRange {
//    var nsRange:NSRange {
//        let start = self.lowerBound as! Int
//        let end = self.upperBound as! Int
//        return NSRange(location: start, length: end + 1 - start)
//    }
//    
//    ///Returns true if this range wholly contains the provided range, false otherwise. A range with zero length will not be contained in anything.
//    func whollyContains(_ range:Range<Element>)->Bool {
//        return range.lowerBound >= self.lowerBound && range.upperBound <= self.upperBound
//    }
//}

extension NSRange {
    func toCountableRange() -> CountableRange<Int>!{
        guard length >= 0 else {return nil}
        return (self.location)..<(self.location + self.length)
    }
}
