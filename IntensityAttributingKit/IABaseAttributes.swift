//
//  IABaseAttributes.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/26/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//
import UIKit


///OptionSet containing the less often varying component attributes
public struct IABaseAttributes:OptionSetTypeWithIntegerRawValue{
    public var rawValue:Int
    public init(rawValue:Int){self.rawValue = rawValue}
    public init!(size:Int, options:IABaseAttributes) {
        guard size > 0 && size < 256 else {return nil}
        self.rawValue = size + options.rawValue
    }
    
    public static let Bold = IABaseAttributes(rawValue: 0x100)
    public static let Italic = IABaseAttributes(rawValue: 0x200)
    public static let Underline = IABaseAttributes(rawValue: 0x300)
    public static let Strikethrough = IABaseAttributes(rawValue: 0x400)
    
    public var size:Int {
        get{return rawValue & 0xFF}
        set{self.rawValue = rawValue - self.size + newValue}
    }
    ///Convenience getter/setter for size in terms of CGFloat units
    public var cSize:CGFloat {
        get{return CGFloat(rawValue & 0xFF)}
        set{self.rawValue = rawValue - self.size + Int(newValue)}
    }
    
    public var bold:Bool {
        get{return self.contains(.Bold)}
        set{self.insert(.Bold)}}
    public var italic:Bool {
        get{return self.contains(.Italic)}
        set{self.insert(.Italic)}}
    public var underline:Bool {
        get{return self.contains(.Underline)}
        set{self.insert(.Underline)}}
    public var strikethrough:Bool {
        get{return self.contains(.Strikethrough)}
        set{self.insert(.Strikethrough)}}
    
    
}


public protocol OptionSetTypeWithIntegerRawValue:OptionSetType, Hashable {
    typealias RawValue = Int
    var rawValue:Int {get set}
    var hashValue:Int {get}
    init(rawValue:Int)
}
extension OptionSetTypeWithIntegerRawValue {
    public var hashValue:Int {return rawValue}
}
