//
//  ValueWithRange.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/16/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation

/*
///Functions similarly to an NSRange except this struct also contains a value(Any type) associated with the range. This also includes functions to convert to or from JSON ready arrays
struct ValueWithRange: CustomStringConvertible, ValueWithRangeProtocol {
    var value:Any
    var location:Int
    var length:Int
    
    var description:String {
        return "value:\(self.value), location:\(self.location), length:\(self.length)"
    }
    
    var range:NSRange {
        get {return NSRange(location: location, length: length)}
        set {self.location = newValue.location; self.length = newValue.length}
    }
    
    ///Returns the ValueWithRange as a three element array suitable for converting to json for export. Format is [location, length, value]
    var asArray:[AnyObject]! {
        guard let val = value as? AnyObject else {return nil}
        return [location, length, val]
    }
    
    init!(arrayRepresentation:[AnyObject]){
        guard arrayRepresentation.count == 3 && arrayRepresentation[0] is Int && arrayRepresentation[1] is Int else {return nil}
        self.location = arrayRepresentation[0] as! Int
        self.length = arrayRepresentation[1] as! Int
        self.value = arrayRepresentation[2]
    }
    
    init(value:Any, location:Int, length:Int){
        self.value = value
        self.location = location
        self.length = length
    }
    
//    ///returns a new ValueWithRange object with the value copied (into a new object) if it's an NSObject class.
//    func copy() -> ValueWithRange {
//        if let copy = (self.value as? NSObject)?.copy() {
//            return ValueWithRange(value: copy, location: self.location, length: self.length)
//        }
//        return ValueWithRange(value: self.value, location: self.location, length: self.length)
//    }
}

protocol ValueWithRangeProtocol{
    var value:Any {get set}
    var location:Int {get set}
    var length:Int {get set}

}
*/
