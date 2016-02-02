//
//  RangeValuePair.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/25/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation



///Functions similarly to an NSRange except this struct also contains a value(Any type) associated with the range. This also includes functions to convert to or from JSON ready arrays
struct RangeValuePair<Element:Equatable>: CustomStringConvertible, RVPProtocol {
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
    
    var range:Range<Int>{
        get{return startIndex..<endIndex}
        set{startIndex = newValue.startIndex; endIndex = newValue.endIndex}
    }
    
    init(value:Element, range:Range<Int>){
        self.value = value
        self.startIndex = range.startIndex
        self.endIndex = range.endIndex
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
    
    ///yields [startIndex, endIndex, value]. Used as an intermediate step to JSON
    //var asArray:[Any] {return [startIndex,endIndex,value]}
    
//    func hasEqualValue(other: RVPProtocol) -> Bool {
//        if let other = other as? RangeValuePair<Element> {
//            return other.value == self.value
//        } else {
//            return false
//        }
//    }
}


extension RangeValuePair where Element:AnyObject {
    ///yields [startIndex, endIndex, value]. Used as an intermediate step to JSON
    var asArray:[AnyObject] {return [startIndex,endIndex,value]}
}

protocol RVPProtocol {
    var startIndex:Int {get set}
    var endIndex:Int {get set}
    
    ///If both the container type and contained values are equal (and equatable) then this returns true, else false
    //func hasEqualValue(other:RVPProtocol)->Bool
}
extension RVPProtocol {
    mutating func reindex(by:Int){
        self.startIndex += by
        self.endIndex += by
    }
}

