//
//  RangeValuePair.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/25/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation



///Functions similarly to an NSRange except this struct also contains a value(Any type) associated with the range. This also includes functions to convert to or from JSON ready arrays
struct RangeValuePair<Element:Equatable>: CustomStringConvertible {
    var value:Element
    var startIndex:Int
    var endIndex:Int
    
    
    var description:String {
        return "{\(self.startIndex)..<\(self.endIndex): value:\(self.value)}"
    }
    
    var nsRange:NSRange {
        get {return NSRange(location: startIndex, length: endIndex - startIndex)}
        set {self.startIndex = newValue.location; self.endIndex = newValue.location + newValue.length}
    }
    
    var range:CountableRange<Int>{
        get{return startIndex..<endIndex}
        set{startIndex = newValue.lowerBound; endIndex = newValue.upperBound}
    }
    
    init(value:Element, range:CountableRange<Int>){
        self.value = value
        self.startIndex = range.lowerBound
        self.endIndex = range.upperBound
    }
    
    init(value:Element, range:NSRange){
        self.value = value
        self.startIndex = range.location
        self.endIndex = range.location + range.length
    }
    
    init(value:Element, startIndex:Int, endIndex:Int){
        self.value = value
        self.startIndex = startIndex
        self.endIndex = endIndex
    }
    
    mutating func reindex(_ by:Int){
        self.startIndex += by
        self.endIndex += by
    }
}


extension RangeValuePair where Element:AnyObject {
    ///yields [startIndex, endIndex, value]. Used as an intermediate step to JSON
    var asArray:[AnyObject] {return [startIndex as AnyObject,endIndex as AnyObject,value]}
}
extension RangeValuePair where Element:Any {
    ///yields [startIndex, endIndex, value]. Used as an intermediate step to JSON
    var asArray:[Any] {return [startIndex, endIndex, value]}
}


