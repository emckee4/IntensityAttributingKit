//
//  IAStringEditing.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/2/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit



///Extension providing IAString modification as well as subrange operations.
extension IAString {

    
    ///This provides a new IAString comprised of copies of the contents in the given range. This inherits its parent's options. It will reindex its attributes and it will discard links.
    public func iaSubstringFromRange(_ range:CountableRange<Int>)->IAString {
        let newIA = self.emptyCopy()
        
        //newIA.text = self.text.subStringFromRange(range)
        newIA.text = ((self.text as NSString).substring(with: range.nsRange)) as String
        newIA.intensities = Array(self.intensities[range])
        newIA.baseAttributes = self.baseAttributes.subRange(range)
        //links are ignored
        newIA.attachments = self.attachments.reindexedSubrange(range)
        newIA.baseOptions = self.baseOptions
        return newIA
    }
    
    
    ///Append a 0 based IAString
    public func appendIAString(_ iaString:IAString){
        let appendingFromIndex = self.length
        //let startingLength = self.text.length
        let appendLength = iaString.length
        self.text = self.text + (iaString.text as String)
        self.baseAttributes.append(contentsOf: iaString.baseAttributes) //should automatically rebase
        self.intensities.append(contentsOf: iaString.intensities)
        //adding links and attachments requires rebasing those arrays manually
        //self.links.appendWithReindexing(iaString.links, reindexBy: startingLength)
        self.attachments.replaceRange(iaString.attachments, ofLength: appendLength, replacedRange: appendingFromIndex..<appendingFromIndex)
        
    }
    
    
    public func insertIAString(_ iaString:IAString, atIndex:Int){
        let nsm = (self.text.mutableCopy()) as! NSMutableString
        nsm.insert(iaString.text, at: atIndex)
        self.text = nsm as String
        //text.insertContentsOf(iaString.text.characters, at: self.text.indexFromInt(atIndex)!)
        self.intensities.insert(contentsOf: iaString.intensities, at: atIndex)
        self.baseAttributes.insert(contentsOf: iaString.baseAttributes, at: atIndex)
        self.attachments.insertAttachments(iaString.attachments, ofLength: iaString.length, atIndex: atIndex)
        
    }
    
    public func removeRange(_ range:CountableRange<Int>){
        //do {try self.text.removeIntRange(range)} catch {fatalError("IAString.removeRange: indexing error")}
        self.text.removeNSRange(range.nsRange)
        self.intensities.removeSubrange(range)
        self.baseAttributes.removeSubrange(range)
        self.attachments.removeSubrange(range)
    }
    
    public func replaceRange(_ replacement:IAString, range:CountableRange<Int>){
        //try! self.text.removeIntRange(range)
        let nsm = (self.text as NSString).mutableCopy() as! NSMutableString
        nsm.replaceCharacters(in: range.nsRange, with: replacement.text)
        self.text = nsm as String
        self.intensities.replaceSubrange(range, with: replacement.intensities)
        self.baseAttributes.replaceSubrange(range, with: replacement.baseAttributes)
        self.attachments.replaceRange(replacement.attachments, ofLength: replacement.length, replacedRange: range)
        
    }
    
    //convenience editor
    public func insertAtPosition(_ text:String, position:Int, intensity:Int, attributes:IABaseAttributes){
        //self.text.insertContentsOf(text.characters, at: self.text.indexFromInt(position)!)
        let nsm = (self.text as NSString).mutableCopy() as! NSMutableString
        nsm.insert(text, at: position)
        self.text = nsm as String
        
        let insertLength = (text as String).utf16.count
        self.intensities.insert(contentsOf: Array<Int>(repeating: intensity, count: insertLength), at: position)
        self.baseAttributes.insert(contentsOf: Array<IABaseAttributes>(repeating: attributes, count: insertLength), at: position)
        self.attachments.insertAttachment(nil, atLoc: position)
    }
    
    public func insertAttachmentAtPosition(_ attachment:IATextAttachment, position:Int, intensity:Int ,attributes:IABaseAttributes){
        //self.text.insert(Character("\u{FFFC}"), atIndex: self.text.indexFromInt(position)!)
        let nsm = (self.text as NSString).mutableCopy() as! NSMutableString
        nsm.insert("\u{FFFC}", at: position)
        self.text = nsm as String
        self.intensities.insert(intensity, at: position)
        self.baseAttributes.insert(attributes, at: position)
        attachments.insertAttachment(attachment, atLoc: position)
    }
    
    ///Returns an empty IAString with the same baseOptions as the receiver
    public func emptyCopy()->IAString {
        let newIA = IAString()
        newIA.baseOptions = self.baseOptions
        return newIA
    }
    ///Note: does not create new instances of IATextAttachment unless deepCopy option is true
    public func copy(_ deepCopy:Bool = false)->IAString{
        let newIA = self.emptyCopy()
        newIA.text = self.text
        assert(newIA.length == self.length)
        newIA.baseAttributes = self.baseAttributes
        newIA.intensities = self.intensities
        newIA.links = self.links
        newIA.attachments = deepCopy ? self.attachments.deepCopy() : self.attachments
        newIA.baseOptions = self.baseOptions
        return newIA
    }
    
}


extension IAString {
    //set bold/ital/under/strike/size/inten for range
    func setAttributeValueForRange(_ value:AnyObject,attrName:IAAttributeName,range:CountableRange<Int>){
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
    
    
    ///Returns the value for the range if it's constant over that range, or nil if otherwise. Size always returns an average.
    func getAttributeValueForRange(_ attrName:IAAttributeName,range:CountableRange<Int>)->AnyObject?{
        switch attrName {
        case .Intensity:
            let startVal = self.intensities[range.lowerBound]
            for item in self.intensities[range]{
                guard startVal == item else {return nil}
            }
            return startVal as AnyObject?
        case .Size:
            //let value = self.baseAttributes[range.startIndex].size
            var sum:Int = 0
            for (range, rvpVal) in self.baseAttributes.rvpsCoveringRange(range) {
                //guard rvpVal.size == value else {return nil}
                sum += range.count * rvpVal.size
            }
            return (sum / range.count) as AnyObject
        case .Bold:
            let value = self.baseAttributes[range.lowerBound].bold
            for (_, rvpVal) in self.baseAttributes.rvpsCoveringRange(range) {
                if rvpVal.bold != value {return nil}
            }
            return value as AnyObject?
        case .Italic:
            let value = self.baseAttributes[range.lowerBound].italic
            for (_, rvpVal) in self.baseAttributes.rvpsCoveringRange(range) {
                if rvpVal.italic != value {return nil}
            }
            return value as AnyObject?
        case .Underline:
            let value = self.baseAttributes[range.lowerBound].underline
            for (_, rvpVal) in self.baseAttributes.rvpsCoveringRange(range) {
                if rvpVal.underline != value {return nil}
            }
            return value as AnyObject?
        case .Strikethrough:
            let value = self.baseAttributes[range.lowerBound].strikethrough
            for (_, rvpVal) in self.baseAttributes.rvpsCoveringRange(range) {
                if rvpVal.strikethrough != value {return nil}
            }
            return value as AnyObject?
        }
        
    }
    
    ///Changes the intensity values of all content in the range
    func setIntensityValueForRange(_ range:CountableRange<Int>, toValue:Int){
        let newVal = clamp(toValue, lowerBound: 0, upperBound: 100)
        for i in range {
            intensities[i] = newVal
        }
    }
    
    func getAverageIntensityForRange(_ range:CountableRange<Int>)->Int!{
        guard !range.isEmpty else {return nil}
        return intensities[range].reduce(0, +) / range.count
    }
    
    ///Returns an ~average baseAttributes value for the range.
    func getBaseAttributesForRange(_ range:CountableRange<Int>)->IABaseAttributes!{
        guard !range.isEmpty else {return nil}
        let rvpsForRange = baseAttributes.rvpsCoveringRange(range)
        if rvpsForRange.count == 1 {
            return rvpsForRange.first!.value
        } else {
            var newAtts = IABaseAttributes(size:(self.getAttributeValueForRange(.Size, range: range) as! Int))
            newAtts?.bold = (getAttributeValueForRange(.Bold, range: range) as? Bool) ?? false
            newAtts?.italic = (getAttributeValueForRange(.Italic, range: range) as? Bool) ?? false
            newAtts?.underline = (getAttributeValueForRange(.Underline, range: range) as? Bool) ?? false
            newAtts?.strikethrough = (getAttributeValueForRange(.Strikethrough, range: range) as? Bool) ?? false
            return newAtts
        }
        
    }
    
}




