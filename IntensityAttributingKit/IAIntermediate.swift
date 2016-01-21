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
    //var attachmentSizes: [ValueWithRange] = []
    var attachments: [ValueWithRange] = []
    public var attachmentCount:Int {
        return attachments.count
    }
    
    var renderScheme:IntensityTransformers!
    var renderOptions:[String:AnyObject] = [:]
//    
//    public init!(iaString:NSAttributedString){
//        guard iaString.length > 0 else {text = "";return nil}
//        //[IAIntensity, IASize, IABold, IAItalic, IAUnderline, IAStrikethrough, IACurrentRendering, IAAttachmentSize]
//        
//        
//        let fullRange = NSRange(location: 0, length: iaString.length)
//        var tempIAAtts:[[String:AnyObject]] = []
//        
//        self.text = iaString.string
//        
//        iaString.enumerateAttribute(NSLinkAttributeName, inRange: fullRange, options: []) { (link, linkRange, stop) -> Void in
//            if let thisLink = link {
//                self.links.append(ValueWithRange(value: thisLink, location: linkRange.location, length: linkRange.length))
//            }
//        }
//        
//        
//        iaString.enumerateAttributesInRange(fullRange, options: []) { (atts, blockRange, stop) -> Void in
//            guard let thisIAAtts = atts[IATags.IAKeys] as? [String:AnyObject] else {fatalError("non ia string: \(iaString)")}
//            
//            if let textAttach = atts[NSAttachmentAttributeName] as? IATextAttachment {
//                self.attachments.append(ValueWithRange(value: textAttach, location: blockRange.location, length: 1))
//               // self.attachmentSizes.append(ValueWithRange(value: attachSize, location: blockRange.location, length: 1))
//            }
//            for _ in 0..<(blockRange.length){
//                tempIAAtts.append(thisIAAtts)
//            }
//        }
//        
//        if tempIAAtts.count != text.length {
//            print("tempIAAtts.count != text.length")
//            return nil
//        }
//        
//        self.renderScheme = IntensityTransformers(rawValue: tempIAAtts[0][IATags.IACurrentRendering] as! String)
//        
//        self.intensities = tempIAAtts.map({$0[IATags.IAIntensity] as! Float})
//        guard intensities.count == text.length else {fatalError()}
//        
//        self.textSizes = extractValueStreaks(tempIAAtts.map({$0[IATags.IASize]! as! CGFloat}))
//        
//        self.bolds = extractTrueRanges(tempIAAtts.map({($0[IATags.IABold] as? Bool) ?? false}))
//        self.italics = extractTrueRanges(tempIAAtts.map({($0[IATags.IAItalic] as? Bool) ?? false}))
//        self.underlines = extractTrueRanges(tempIAAtts.map({($0[IATags.IAUnderline] as? Bool) ?? false}))
//        self.strikethroughs = extractTrueRanges(tempIAAtts.map({($0[IATags.IAStrikethrough] as? Bool) ?? false}))
//        
//    }
    

    
//    ///Converts the IAIntermediate object to an IA NSAttributedString. performRender defaults to false.
//    public func toIAAttributedString(performRender:Bool = false)->NSAttributedString{
//        let attString = NSMutableAttributedString(string: self.text as String)
//        
//        for linkVWR in links {
//            var linkURL:NSURL? = linkVWR.value as? NSURL
//            if linkURL == nil {
//                let linkPath = linkVWR.value as? String
//                if linkPath != nil {
//                    linkURL = NSURL(string: linkPath!)
//                }
//            }
//            if linkURL != nil {
//                attString.addAttribute(NSLinkAttributeName, value: linkURL!, range: linkVWR.range)
//            }
//        }
//        
//        ///attachment and attachSize should always exist together
//        for attachVWR in attachments {
//            attString.addAttribute(NSAttachmentAttributeName, value: attachVWR.value as! IATextAttachment, range: attachVWR.range)
//        }
////        for attachSizeVWR in attachmentSizes {
////            attString.addAttribute(IATags.IAAttachmentSize, value: attachSizeVWR.value as! AnyObject, range: attachSizeVWR.range)
////        }
//        
//        var iaAttributes:[IntensityAttributes] = []
//        
//        
//        for sizeVWR in textSizes {
//            for index in (sizeVWR.location)..<(sizeVWR.location + sizeVWR.length){
//                var ia = IntensityAttributes(intensity: self.intensities[index], size: sizeVWR.value as! CGFloat)
//                if self.renderScheme != nil {
//                    ia.currentScheme = renderScheme.rawValue
//                }
//                iaAttributes.append(ia)
//            }
//        }
//        
//        for boldRange in bolds {
//            for i in (boldRange.location)..<(boldRange.location + boldRange.length) {
//                iaAttributes[i].isBold = true
//            }
//        }
//        for italRange in italics {
//            for i in (italRange.location)..<(italRange.location + italRange.length) {
//                iaAttributes[i].isItalic = true
//            }
//        }
//        for undRange in underlines {
//            for i in (undRange.location)..<(undRange.location + undRange.length) {
//                iaAttributes[i].isUnderlined = true
//            }
//        }
//        for strikeRange in strikethroughs {
//            for i in (strikeRange.location)..<(strikeRange.location + strikeRange.length) {
//                iaAttributes[i].isStrikethrough = true
//            }
//        }
//
//        guard iaAttributes.count == attString.length else {fatalError("IAIntermediate:toIAAttributedString: iaAttributes.count != attString.length")}
//        
//        for (i,attStruct) in iaAttributes.enumerate(){
//            attString.addAttribute(IATags.IAKeys, value: attStruct.asAttributeDict, range: NSRange(location: i, length: 1))
//        }
//        
//        if performRender {
//            attString.transformWithRenderSchemeInPlace(renderScheme.rawValue)
//        }
//        return NSAttributedString(attributedString: attString)
//    }
    
    ///converts the IAIntermediate to a tupple containing a JSON ready dictionary and an array of NSData for the text attachments in sequential order. We use the locations of the attachSizeVWRanges as the locations for our attachments when reconstructing
    public func convertToJSONReadyDictWithData()->([String:AnyObject],[Int:NSData]){
        var dict:[String:AnyObject] = [:]
        dict[IAStringKeys.text] = self.text
        dict[IAStringKeys.intensities] = self.intensities
        dict[IAStringKeys.textSizeVWRanges] = self.textSizes.map({$0.asArray})
        
        dict[IAStringKeys.boldRanges] = self.bolds.map({[$0.location,$0.length]})
        dict[IAStringKeys.italicRanges] = self.italics.map({[$0.location,$0.length]})
        dict[IAStringKeys.underlineRanges] = self.underlines.map({[$0.location,$0.length]})
        dict[IAStringKeys.strikethroughRanges] = self.strikethroughs.map({[$0.location,$0.length]})
        dict[IAStringKeys.linkVWRanges] = self.links.map({$0.asArray}).map({[$0[0],$0[1],($0[2] as! NSURL).absoluteString]})
        //dict[IAStringKeys.attachSizeVWRanges] = self.attachmentSizes.map({$0.asArray})
        
        
        if let scheme = self.renderScheme {
            dict[IAStringKeys.renderScheme] = scheme.rawValue
        }
        
        var dataDict:[Int:NSData] = [:]
        for attachVWR in self.attachments {
            let nsTA = attachVWR.value as! IATextAttachment
            if let data = nsTA.contents {
                dataDict[attachVWR.location] = data
            } else if let wrapper = nsTA.fileWrapper where wrapper.regularFileContents != nil {
                dataDict[attachVWR.location] = wrapper.regularFileContents!
            } else if let image = nsTA.image {
                dataDict[attachVWR.location] = UIImageJPEGRepresentation(image, 0.8)!
            } else {
                print("error converting text attachment to NSData. Appending empty placeholder instead")
                dataDict[attachVWR.location] = NSData()
            }
        }
        
        return (dict, dataDict)
    }
    
    ///inverse of convertToJSONReadyDictWithData with the exception of attachment data: IATextAttachments are added at the proper indexes but left empty
    public init!(dict:[String:AnyObject]){
        guard let newText = dict[IAStringKeys.text] as? String, newIntensities = dict[IAStringKeys.intensities] as? [Float] else {
            print("IAIntermediate received incomplete data"); self.text = "";return nil
        }
        //string
        self.text = newText
        //array
        self.intensities = newIntensities
        
        //arrays of VWRs
        if let newSizes = dict[IAStringKeys.textSizeVWRanges] as? [[AnyObject]]{
            for sizeObject in newSizes {
                if let vwr = ValueWithRange(arrayRepresentation: sizeObject) {
                    self.textSizes.append(vwr)
                }
            }
        }
        if let newLinks = dict[IAStringKeys.linkVWRanges] as? [[AnyObject]]{
            for link in newLinks {
                var linkVWR = ValueWithRange(arrayRepresentation: link) //with string
                if let url = NSURL(string:(linkVWR?.value as? String) ?? "") {
                    linkVWR.value = url
                    self.links.append(linkVWR)
                }
                
            }
        }
        if let newAttachments = dict[IAStringKeys.attachmentVWRanges] as? [[AnyObject]]{
            for attachVWRArray in newAttachments {
                if let vwr = ValueWithRange(arrayRepresentation: attachVWRArray) {
                    //self.attachmentSizes.append(vwr)
                    //creating a placeholder IATextAttachment
                    self.attachments.append(ValueWithRange(value: IATextAttachment(), location: vwr.location, length: vwr.length))
                }
            }
        }
        
        //single value
        if let scheme = dict[IAStringKeys.renderScheme] as? String {
            self.renderScheme = IntensityTransformers(rawValue: scheme)
        }
        
        //true ranges
        
        if let boldRanges = dict[IAStringKeys.boldRanges] as? [[Int]] {
            for bRange in boldRanges {
                if bRange.count == 2 {
                    bolds.append(NSMakeRange(bRange[0], bRange[1]))
                }
            }
        }
        
        if let italicRanges = dict[IAStringKeys.italicRanges] as? [[Int]] {
            for iRange in italicRanges {
                if iRange.count == 2 {
                    italics.append(NSMakeRange(iRange[0], iRange[1]))
                }
            }
        }
        if let underRanges = dict[IAStringKeys.underlineRanges] as? [[Int]] {
            for uRange in underRanges {
                if uRange.count == 2 {
                    underlines.append(NSMakeRange(uRange[0], uRange[1]))
                }
            }
        }
        if let strikeRanges = dict[IAStringKeys.strikethroughRanges] as? [[Int]] {
            for sRange in strikeRanges {
                if sRange.count == 2 {
                    strikethroughs.append(NSMakeRange(sRange[0], sRange[1]))
                }
            }
        }
        
    }

}

public struct IAStringKeys {
    public static let text = "text"
    public static let intensities = "intensities"
    public static let textSizeVWRanges = "textSizeVWRanges"
    public static let boldRanges = "boldRanges"
    public static let italicRanges = "italicRanges"
    public static let underlineRanges = "underlineRanges"
    public static let strikethroughRanges = "strikethroughRanges"
    public static let linkVWRanges = "linkVWRanges"
    //public static let attachSizeVWRanges = "attachSizeVWRanges"
    public static let attachmentVWRanges = "attachmentVWRanges"
    public static let renderScheme = "renderScheme"
}

///extracts NSRanges of true values from arrays of boolean values. "false" values are ignored since they can be inferred.
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



extension IAIntermediate {
    
//    private func wordRanges()->[NSRange]{
//        guard self.text.length > 0 else {return []}
//        var rangeArray:[NSRange] = []
//        self.text.enumerateSubstringsInRange(NSRange(location: 0, length: self.text.length), options: .ByWords) { (subString, strictSSRange, enclosingRange, stop) -> Void in
//            if subString != nil {
//                rangeArray.append(enclosingRange)
//            } else {
//                fatalError("IAIntermediate:wordRanges: found nil word in \(self.text) at \(strictSSRange) , \(enclosingRange)")
//            }
//        }
//        return rangeArray
//    }
//    
//    
//    
//    private func perWordIntensityArray()->[Float]{
//        var perWord:[Float] = Array<Float>()
//        perWord.reserveCapacity(self.text.length)
//        for range in self.wordRanges() {
//            if perWord.count != range.location {
//                fatalError("(IAIntermediate perWordIntensityArray) perWord.length != range.location in \(self.text)")
//            }
//            let swiftRange = range.location..<(range.location + range.length)
//            let avgForRange:Float = self.intensities[swiftRange].reduce(0.0, combine: +) / Float(range.length)
//            perWord.appendContentsOf(Array<Float>(count: range.length, repeatedValue: avgForRange))
//        }
//        guard perWord.count == self.intensities.count else {fatalError("(IAIntermediate perWordIntensityArray) perWord.count == self.intensities.count")}
//        return perWord
//    }
    
    func unitRanges(separationOptions:NSStringEnumerationOptions)->[NSRange]{
        guard self.text.length > 0 else {return []}
        var rangeArray:[NSRange] = []
        self.text.enumerateSubstringsInRange(NSRange(location: 0, length: self.text.length), options: separationOptions) { (subString, strictSSRange, enclosingRange, stop) -> Void in
            if subString != nil {
                rangeArray.append(enclosingRange)
            } else {
                fatalError("IAIntermediate:unitRanges: found nil word in \(self.text) at \(strictSSRange) , \(enclosingRange)")
            }
        }
        return rangeArray
    }
    
    
    public func perUnitSmoothedIntensities(separationOptions:NSStringEnumerationOptions)->[Float]{
        guard separationOptions != .SubstringNotRequired else {return self.intensities}
        var perWord:[Float] = Array<Float>()
        perWord.reserveCapacity(self.text.length)
        for range in self.unitRanges(separationOptions) {
            if perWord.count != range.location {
                fatalError("(IAIntermediate perUnitSmoothedIntensities) perWord.length != range.location in \(self.text), with separationOptions: \(separationOptions)")
            }
            let swiftRange = range.location..<(range.location + range.length)
            let avgForRange:Float = self.intensities[swiftRange].reduce(0.0, combine: +) / Float(range.length)
            perWord.appendContentsOf(Array<Float>(count: range.length, repeatedValue: avgForRange))
        }
        guard perWord.count == self.intensities.count else {fatalError("(IAIntermediate perUnitSmoothedIntensities) perWord.count == self.intensities.count, with separationOptions: \(separationOptions)")}
        return perWord
    }
    
    
    func generateIntensityAttributesArray(renderSteps steps:Int, separateOn separator:NSStringEnumerationOptions)->[(range:NSRange, ia:IntensityAttributes)]{
        //centers the intensity in its bin
        let binWidth = 1 / Float(steps)
        let smoother:(Float)->(Float) = { (intensity)->(Float) in
            guard intensity > 0.0 else {return 0.0}
            guard intensity < 1.0 else {return (Float(steps) - 0.5) * binWidth}
            let bin = intensity / binWidth
            return (floor(bin) + 0.5) * binWidth
        }
        let binnedIntensities:[Float] = self.perUnitSmoothedIntensities(separator).map(smoother)
        
        return generateIAThenCondenseRanges(binnedIntensities)
    }
    
    
    
    private func generateIAThenCondenseRanges(binnedIntensities:[Float])->[(range:NSRange, ia:IntensityAttributes)]{
        let rawArray = generateIARawArray(binnedIntensities)
        var resultArray:[(range:NSRange, ia:IntensityAttributes)] = []
        
        var currentItem:IntensityAttributes!
        var currentLoc:Int = 0
        var currentLen:Int = 1
        for (index, ia) in rawArray.enumerate() {
            if index == 0 {
                currentItem = ia
                currentLoc = 0
                currentLen = 1
            } else if currentItem == ia {
                currentLen += 1
            } else {
                resultArray.append((range:NSRange(location: currentLoc, length: currentLen), ia:currentItem))
                currentItem = ia
                currentLoc = index
                currentLen = 1
            }
        }
        resultArray.append((range:NSRange(location: currentLoc, length: currentLen), ia:currentItem))
        
        return resultArray
    }
    
    private func generateIARawArray(binnedIntensities:[Float])->[IntensityAttributes]{
        var intensityAttributes:[IntensityAttributes] = []
        intensityAttributes.reserveCapacity(self.text.length)
        
        for sizeVWR in textSizes {
            for index in (sizeVWR.location)..<(sizeVWR.location + sizeVWR.length){
                intensityAttributes.append(IntensityAttributes(intensity: binnedIntensities[index], size: sizeVWR.value as! CGFloat))
            }
        }
        assert(intensityAttributes.count == self.text.length, "intensityAttributes.count == self.text.length")
        
        for boldRange in bolds {
            for i in (boldRange.location)..<(boldRange.location + boldRange.length) {
                intensityAttributes[i].isBold = true
            }
        }
        for italRange in italics {
            for i in (italRange.location)..<(italRange.location + italRange.length) {
                intensityAttributes[i].isItalic = true
            }
        }
        for undRange in underlines {
            for i in (undRange.location)..<(undRange.location + undRange.length) {
                intensityAttributes[i].isUnderlined = true
            }
        }
        for strikeRange in strikethroughs {
            for i in (strikeRange.location)..<(strikeRange.location + strikeRange.length) {
                intensityAttributes[i].isStrikethrough = true
            }
        }
        return intensityAttributes
    }
    
    
    func convertToNSAttributedStringWithOptions(options:[String:AnyObject])->NSAttributedString{
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

        ///attachment and attachSize should always exist together
        for attachVWR in attachments {
            attString.addAttribute(NSAttachmentAttributeName, value: attachVWR.value as! IATextAttachment, range: attachVWR.range)
        }
        
        //options have two levels: prefered (internal) and override passed in by the user. Override trumps internal
        var renderWithScheme = self.renderScheme
        if let overrideScheme = options["renderWithScheme"] as? String where IntensityTransformers(rawValue: overrideScheme) != nil{
            renderWithScheme = IntensityTransformers(rawValue: overrideScheme)
        }
        let transformer = renderWithScheme.transformer
        
        var preferedSmoothing:NSStringEnumerationOptions!
        if let smoothing = options["smoothingSeparator"] as? NSStringEnumerationOptions {
            preferedSmoothing = smoothing
        } else if let smoothing = self.renderOptions["smoothingSeparator"] as? NSStringEnumerationOptions {
            preferedSmoothing = smoothing
        } else {
            preferedSmoothing = .SubstringNotRequired
        }
        
        //other options should be implemented here...
        
        
        //render steps needs to come from renderScheme
        
        for (range, ia) in generateIntensityAttributesArray(renderSteps: transformer.stepCount, separateOn: preferedSmoothing) {
            let attDict = transformer.nsAttributesForIntensityAttributes(ia)
            attString.addAttributes(attDict, range: range)
        }
        return attString
    }
    
    
    
}




