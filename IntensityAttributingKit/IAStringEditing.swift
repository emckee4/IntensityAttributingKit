//
//  IAStringEditing.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/2/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit



///Extension providing subrange from range
extension IAString {
    
    
    
    
    
    ///This provides a new IAString comprised of copies of the contents in the given range. This inherits its parent's options. It will reindex its attributes and it will discard links.
    public func iaSubstringFromRange(range:Range<Int>)->IAString {
        let substring = self.text.subStringFromRange(range)
        let intensities = Array(self.intensities[range])
        let baseAttsSub = self.baseAttributes.subRange(range)
        //links are ignored
        let attachSubs = self.attachments.reindexedSubrange(range)
        let newIA = IAString(withText: substring, intensities: intensities,baseAtts: baseAttsSub, attachments: attachSubs)
        
        newIA.renderScheme = self.renderScheme
        newIA.renderOptions = self.renderOptions
        newIA.preferedSmoothing = self.preferedSmoothing
        return newIA
    }
    
    
    
    
    ///Append a 0 based IAString
    public func appendIAString(iaString:IAString){
        let appendingFromIndex = self.length
        //let startingLength = self.text.length
        let appendLength = iaString.length
        self.text = self.text.stringByAppendingString(iaString.text as String)
        self.baseAttributes.appendContentsOf(iaString.baseAttributes) //should automatically rebase
        self.intensities.appendContentsOf(iaString.intensities)
        //adding links and attachments requires rebasing those arrays manually
        //self.links.appendWithReindexing(iaString.links, reindexBy: startingLength)
        self.attachments.replaceRange(iaString.attachments, ofLength: appendLength, replacedRange: appendingFromIndex..<appendingFromIndex)
        
    }
    
    
    public func insertIAString(iaString:IAString, atIndex:Int){
        //        let mutableString = self.text.mutableCopy() as! NSMutableString
        //        mutableString.insertString(iaString.text as String, atIndex: atIndex)
        //        self.text = mutableString
        //        let utf16Index = self.text.utf16.startIndex.advancedBy(atIndex)
        //        let stringIndex = String.Index
        text.insertContentsOf(iaString.text.characters, at: self.text.indexFromInt(atIndex)!)
        self.intensities.insertContentsOf(iaString.intensities, at: atIndex)
        self.baseAttributes.insertContentsOf(iaString.baseAttributes, at: atIndex)
        self.attachments.insertAttachments(iaString.attachments, ofLength: iaString.length, atIndex: atIndex)
        
    }
    
    public func removeRange(range:Range<Int>){
        do {try self.text.removeIntRange(range)} catch {fatalError("IAString.removeRange: indexing error")}
        self.intensities.removeRange(range)
        self.baseAttributes.removeRange(range)
        self.attachments.removeSubrange(range)
    }
    
    public func replaceRange(replacement:IAString, range:Range<Int>){
        try! self.text.removeIntRange(range)
        self.text.insertContentsOf(replacement.text.characters, at: self.text.indexFromInt(range.startIndex)!)
        self.intensities.replaceRange(range, with: replacement.intensities)
        self.baseAttributes.replaceRange(range, with: replacement.baseAttributes)
        self.attachments.replaceRange(replacement.attachments, ofLength: replacement.length, replacedRange: range)
        
    }
    
    
    //convenience editor
    public func insertAtPosition(text:String, position:Int, intensity:Int, attributes:IABaseAttributes){
        self.text.insertContentsOf(text.characters, at: self.text.indexFromInt(position)!)
        let insertLength = (text as String).utf16.count
        self.intensities.insertContentsOf(Array<Int>(count: insertLength, repeatedValue: intensity), at: position)
        self.baseAttributes.insertContentsOf(Array<IABaseAttributes>(count: insertLength, repeatedValue: attributes), at: position)
        self.attachments.insertAttachment(nil, atLoc: position)
    }
    
    public func insertAttachmentAtPosition(attachment:IATextAttachment, position:Int, intensity:Int ,attributes:IABaseAttributes){
        //        let mutableString = self.text.mutableCopy() as! NSMutableString
        //        mutableString.insertString("\u{FFFC}", atIndex: position)
        //        self.text = mutableString
        self.text.insert(Character("\u{FFFC}"), atIndex: self.text.indexFromInt(position)!)
        self.intensities.insert(intensity, atIndex: position)
        self.baseAttributes.insert(attributes, atIndex: position)
        attachments.insertAttachment(attachment, atLoc: position)
    }
    
    ///Returns an empty IAString with the same general parameters as the receiver
    public func emptyCopy()->IAString {
        let newIA = IAString()
        newIA.renderScheme = self.renderScheme
        newIA.renderOptions = self.renderOptions
        newIA.thumbSize = self.thumbSize
        newIA.preferedSmoothing = self.preferedSmoothing
        return newIA
    }
    ///Note: does not create new instances of IATextAttachment unless deepCopy option is true
    public func copy(deepCopy:Bool = false)->IAString{
        let newIA = self.emptyCopy()
        newIA.text = self.text
        assert(newIA.length == self.length)
        newIA.baseAttributes = self.baseAttributes
        newIA.intensities = self.intensities
        newIA.links = self.links
        newIA.attachments = deepCopy ? self.attachments.deepCopy() : self.attachments
        return newIA
    }
    
}


extension IAString {
    //set bold/ital/under/strike/size/inten for range
    func setAttributeValueForRange(value:AnyObject,attrName:IAAttributeName,range:Range<Int>){
        switch attrName {
        case .Size:
            for i in range { self.baseAttributes[i].size = value as! Int}
        case .Intensity:
            for i in range { self.intensities[i] = value as! Int}
        case .Bold:
            for i in range { self.baseAttributes[i].bold = value as! Bool}
        case .Italic:
            for i in range { self.baseAttributes[i].italic = value as! Bool}
        case .Underline:
            for i in range { self.baseAttributes[i].underline = value as! Bool}
        case .Strikethrough:
            for i in range { self.baseAttributes[i].strikethrough = value as! Bool}
        }
    }
    
    
    ///Returns the value for the range if it's constant over that range, or nil if otherwise
    func getAttributeValueForRange(attrName:IAAttributeName,range:Range<Int>)->AnyObject?{
        switch attrName {
        case .Intensity:
            let startVal = self.intensities[range.startIndex]
            for item in self.intensities[range]{
                guard startVal == item else {return nil}
            }
            return startVal
        case .Size:
            let value = self.baseAttributes[range.startIndex].size
            for (_, rvpVal) in self.baseAttributes.rvpsCoveringRange(range) {
                guard rvpVal.size == value else {return nil}
            }
            return value
        case .Bold:
            let value = self.baseAttributes[range.startIndex].bold
            for (_, rvpVal) in self.baseAttributes.rvpsCoveringRange(range) {
                if rvpVal.bold != value {return nil}
            }
            return value
        case .Italic:
            let value = self.baseAttributes[range.startIndex].italic
            for (_, rvpVal) in self.baseAttributes.rvpsCoveringRange(range) {
                if rvpVal.italic != value {return nil}
            }
            return value
        case .Underline:
            let value = self.baseAttributes[range.startIndex].underline
            for (_, rvpVal) in self.baseAttributes.rvpsCoveringRange(range) {
                if rvpVal.underline != value {return nil}
            }
            return value
        case .Strikethrough:
            let value = self.baseAttributes[range.startIndex].strikethrough
            for (_, rvpVal) in self.baseAttributes.rvpsCoveringRange(range) {
                if rvpVal.strikethrough != value {return nil}
            }
            return value
        }
        
    }
    
    
}




