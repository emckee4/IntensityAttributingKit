//
//  IAIntermediate.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/10/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation





public class IAIntermediate {
    
    var text:NSString
    var intensities:[Float] = []
    
    var textSizes:[ValueWithRange] = []
    
    //binary attributes omit false values
    var bolds:[NSRange] = []
    var italics:[NSRange] = []
    var underlines:[NSRange] = []
    var strikethroughs:[NSRange] = []
    
    
    var links:[ValueWithRange] = []
    var attachmentSizes: [ValueWithRange] = []
    var attachments: [ValueWithRange] = []
    
    var renderScheme:IntensityTransformers!
    
    public init!(iaString:NSAttributedString){
        guard iaString.length > 0 else {text = "";return nil}
        //[IAIntensity, IASize, IABold, IAItalic, IAUnderline, IAStrikethrough, IACurrentRendering, IAAttachmentSize]
        
        
        let fullRange = NSRange(location: 0, length: iaString.length)
        var tempIAAtts:[[String:AnyObject]] = []
        
        self.text = iaString.string
        
        iaString.enumerateAttribute(NSLinkAttributeName, inRange: fullRange, options: []) { (link, linkRange, stop) -> Void in
            if let thisLink = link {
                self.links.append(ValueWithRange(value: thisLink, location: linkRange.location, length: linkRange.length))
            }
        }
        
        
        iaString.enumerateAttributesInRange(fullRange, options: []) { (atts, blockRange, stop) -> Void in
            guard let thisIAAtts = atts[IATags.IAKeys] as? [String:AnyObject] else {fatalError("non ia string")}
            
            if let textAttach = atts[NSAttachmentAttributeName] as? NSTextAttachment, attachSize = thisIAAtts[IATags.IAAttachmentSize] as? [String:AnyObject]{
                self.attachments.append(ValueWithRange(value: textAttach, location: blockRange.location, length: 1))
                self.attachmentSizes.append(ValueWithRange(value: attachSize, location: blockRange.location, length: 1))
            }
            for _ in 0..<(blockRange.length){
                tempIAAtts.append(thisIAAtts)
            }
        }
        
        if tempIAAtts.count != text.length {
            print("tempIAAtts.count != text.length")
            return nil
        }
        
        self.renderScheme = IntensityTransformers(rawValue: tempIAAtts[0][IATags.IACurrentRendering] as! String)
        
        self.intensities = tempIAAtts.map({$0[IATags.IAIntensity] as! Float})
        guard intensities.count == text.length else {fatalError()}
        
        self.textSizes = extractValueStreaks(tempIAAtts.map({$0[IATags.IASize]! as! CGFloat}))
        
        self.bolds = extractTrueRanges(tempIAAtts.map({($0[IATags.IABold] as? Bool) ?? false}))
        self.italics = extractTrueRanges(tempIAAtts.map({($0[IATags.IAItalic] as? Bool) ?? false}))
        self.underlines = extractTrueRanges(tempIAAtts.map({($0[IATags.IAUnderline] as? Bool) ?? false}))
        self.strikethroughs = extractTrueRanges(tempIAAtts.map({($0[IATags.IAStrikethrough] as? Bool) ?? false}))
        
    }
    
    
    public func toIAAttributedString(performRender:Bool = false)->NSAttributedString{
        let attString = NSMutableAttributedString(string: self.text as String)
        
        for linkVWR in links {
            var linkURL:NSURL? = linkVWR.value as? NSURL
            if linkURL == nil {
                let linkPath = linkVWR.value as? String
                if linkPath != nil {
                    linkURL = NSURL(string: linkPath!)
                }
            }
            if linkURL != nil {
                attString.addAttribute(NSLinkAttributeName, value: linkURL!, range: linkVWR.range)
            }
        }
        
        for attach in attachments {
            print("attachment in toIAAttributedString: \(attach)")
            //also insert attachSize
        }
        
        var iaAttributes:[IntensityAttributes] = []
        
        
        for sizeVWR in textSizes {
            for index in (sizeVWR.location)..<(sizeVWR.length){
                var ia = IntensityAttributes(intensity: self.intensities[index], size: sizeVWR.value as! CGFloat)
                if self.renderScheme != nil {
                    ia.currentScheme = renderScheme.rawValue
                }
                iaAttributes.append(ia)
            }
        }
        
        for boldRange in bolds {
            for i in (boldRange.location)..<(boldRange.length) {
                iaAttributes[i].isBold = true
            }
        }
        for italRange in italics {
            for i in (italRange.location)..<(italRange.length) {
                iaAttributes[i].isItalic = true
            }
        }
        for undRange in underlines {
            for i in (undRange.location)..<(undRange.length) {
                iaAttributes[i].isUnderlined = true
            }
        }
        for strikeRange in strikethroughs {
            for i in (strikeRange.location)..<(strikeRange.length) {
                iaAttributes[i].isStrikethrough = true
            }
        }

        guard iaAttributes.count == attString.length else {fatalError("IAIntermediate:toIAAttributedString: iaAttributes.count != attString.length")}
        
        for (i,attStruct) in iaAttributes.enumerate(){
            attString.addAttribute(IATags.IAKeys, value: attStruct.asAttributeDict, range: NSRange(location: i, length: 1))
        }
        
        if performRender {
            attString.transformWithRenderSchemeInPlace(renderScheme.rawValue)
        }
        return NSAttributedString(attributedString: attString)
    }
    
    
    
    
}

private func extractTrueRanges(array:[Bool])->[NSRange]{
    var trueRanges:[NSRange] = []
    var currentStart:Int!
    var currentLength:Int = 0
    
    for (i,val) in array.enumerate(){
        if val {
            if currentStart == nil {
                currentStart = i
                currentLength = 1
            } else {
                currentLength++
            }
        } else {
            if currentStart != nil {
                trueRanges.append(NSRange(location: currentStart, length: currentLength))
                currentStart = nil
                currentLength = 0
            }
        }
    }
    if currentStart != nil {
        trueRanges.append(NSRange(location: currentStart, length: currentLength))
    }
    return trueRanges
}


///returns an array of ValueWithRange objects
private func extractValueStreaks(array:[NSObject])->[ValueWithRange]{
    var vwr:[ValueWithRange] = []
    var currentVWR:ValueWithRange!
    for (i,val) in array.enumerate(){
        if i == 0 {
            currentVWR = ValueWithRange(value: val, location: 0, length: 1)
        } else {
            if val == currentVWR.value as! NSObject{
                currentVWR.length++
            } else {
                vwr.append(currentVWR)
                currentVWR = ValueWithRange(value: val, location: i, length: 1)
            }
        }
    }
    vwr.append(currentVWR)
    return vwr
}



struct ValueWithRange: CustomStringConvertible {
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
}
