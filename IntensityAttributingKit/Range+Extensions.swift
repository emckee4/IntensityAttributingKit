//
//  Range+Extensions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/23/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


extension Range where Element:Comparable {
    ///Returns true if there's any overlap between the two ranges, false otherwise.
    func intersects(range:Range<Element>)->Bool {
        //cases: contains, is contained in, bottom half overlaps, top half overlaps
        if self.startIndex >= range.endIndex || self.endIndex <= range.startIndex {
            return false
        }
        
        return true
    }
    ///Returns true if this range wholly contains the provided range, false otherwise. A range with zero length will not be contained in anything.
    func contains(range:Range<Element>)->Bool {
        return range.startIndex >= self.startIndex && range.endIndex <= self.endIndex
    }
    
}

extension Range where Element:SignedIntegerType {
    var nsRange:NSRange {
        let start = self.startIndex as! Int
        let end = self.endIndex as! Int
        return NSRange(location: start, length: end - start)
    }
}