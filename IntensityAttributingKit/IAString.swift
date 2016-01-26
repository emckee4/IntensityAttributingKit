//
//  IAString.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/26/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


public class IAString {
    
    var text:NSString
    var intensities:[Int] = []
    
    var baseAttributes:CollapsingArray<IABaseAttributes>
    
    
    var links:[RangeValuePair<NSURL>] = []

    var attachments: [(loc:Int,attach:IATextAttachment)] = []
    public var attachmentCount:Int {
        return attachments.count
    }
    
    var renderScheme:IntensityTransformers!
    var renderOptions:[String:AnyObject] = [:]
    
    var thumbSize:ThumbSize = .Medium
    
    var preferedSmoothing: NSStringEnumerationOptions = .ByComposedCharacterSequences

    //////////////////////////////////////
    
    
    ///converts the IAIntermediate to a tupple containing a JSON ready dictionary and an array of NSData for the text attachments in sequential order. We use the locations of the attachSizeVWRanges as the locations for our attachments when reconstructing
    public func convertToJSONReadyDictWithData()->([String:AnyObject],[Int:NSData]){
        var dict:[String:AnyObject] = [:]
        dict[IAStringKeys.text] = self.text
        dict[IAStringKeys.intensities] = self.intensities
        
        dict[IAStringKeys.baseAttributes] = self.baseAttributes.asRVPArray
        dict[IAStringKeys.linkRVPs] = self.links.map({$0.asArray})
        
        
        dict[IAStringKeys.renderScheme] = scheme.rawValue //FIXME: add  ?? IAKitOptions.defaultScheme
        dict[IAStringKeys.preferedSmoothing] = self.preferedSmoothing.rawValue
        
        
        //TODO: Choosing of source of data/ conversion should occur in IATextAttachment
        var dataDict:[Int:NSData] = [:]
        for (loc,attach) in self.attachments {
            //let nsTA = attachVWR.value as! IATextAttachment
            if let data = attach.contents {
                dataDict[loc] = data
            } else if let wrapper = attach.fileWrapper where wrapper.regularFileContents != nil {
                dataDict[loc] = wrapper.regularFileContents!
            } else if let image = attach.image {
                dataDict[loc] = UIImageJPEGRepresentation(image, 0.8)!
            } else {
                print("error converting text attachment to NSData. Appending empty placeholder instead")
                dataDict[loc] = NSData()
            }
        }
        
        return (dict, dataDict)
    }
    
    ///inverse of convertToJSONReadyDictWithData with the exception of attachment data: IATextAttachments are added at the proper indexes but left empty
    public init!(dict:[String:AnyObject]){
        guard let newText = dict[IAStringKeys.text] as? String, newIntensities = dict[IAStringKeys.intensities] as? [Float], rawBaseAtts = dict[IAStringKeys.baseAttributes] as? [[Int]] else {
            print("IAIntermediate received incomplete data"); self.text = "";return nil
        }
        //string
        self.text = newText
        //array
        self.intensities = newIntensities
        
        //arrays of VWRs

        self.baseAttributes = CollapsingArray(rawBaseAtts)
        
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
    
    ///This is intended for initialization of IAIntermediate within the module. It provides only minimal sanity checks.
    private init!(text:NSString, intensities:[Float], size:CGFloat){
        self.text = text
        guard intensities.count == text.length else {return nil}
        self.intensities = intensities
        self.textSizes = [ValueWithRange(value: size, location: 0, length: text.length)]
    }
    
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
    
    private func unitRanges(separationOptions:NSStringEnumerationOptions)->[NSRange]{
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
    
    
    private func perUnitSmoothedIntensities(separationOptions:NSStringEnumerationOptions)->[Float]{
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
    
    
    private func generateIntensityAttributesArray(renderSteps steps:Int, separateOn separator:NSStringEnumerationOptions)->[(range:NSRange, ia:IntensityAttributes)]{
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
    
    ///Should more clearly define options (maybe with a struct of keys). Need to add option for rendering size and style of thumbnails for attachments.
    public func convertToNSAttributedString(withOptions options:[String:AnyObject]? = nil)->NSAttributedString{
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
        if let overrideScheme = options?["renderWithScheme"] as? String where IntensityTransformers(rawValue: overrideScheme) != nil{
            renderWithScheme = IntensityTransformers(rawValue: overrideScheme)
        }
        let transformer = renderWithScheme.transformer
        
        var preferedSmoothing:NSStringEnumerationOptions!
        if let smoothing = options?["smoothingSeparator"] as? NSStringEnumerationOptions {
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


///Extension providing subrange from range
extension IAIntermediate {
    
    
    
    ///This provides a new IAString comprised of copies of the contents in the given range. This inherits its parent's options
    public func iaSubstringFromRange(range:NSRange)->IAIntermediate {
        let textSS = self.text.substringWithRange(range).copy() as! NSString
        let intRange = range.intRange
        let intenseSS = Array(self.intensities[intRange])
        
        
        
        let newIA = IAIntermediate(text: textSS, intensities: intenseSS, size: 10.0)
        
        
        
        
        return newIA
    }
    
    
    //need attributes at index
    
    //need attributes for range
    
    
    
    
    
    
    
    
    
}

//add array extension specifically for arrays of VWRs: should extract, insert, and repair arrays of VWRs and NSRanges

/*

private extension MutableCollectionType where Generator.Element: ValueWithRangeProtocol {
    //TODO: manage copying of non structs
    ///provides the VWRs for a given range, with locations zeroed to the new sub array's origin
    func vwrsForRange(range:Range<Int>)->Array<ValueWithRangeProtocol>{
        var newArray:[ValueWithRangeProtocol] = []
        
        
        //cases: vwr starts in range, vwr starts before but ends in range, vwr contains range
        for vwr in self {
            if (vwr.location >= range.startIndex && vwr.location < range.endIndex){
                //copy, adjust location, clip end if necessary
                let valCopy = ((vwr.value as? NSObject)?.copy()) ?? vwr.value
                let adjLoc = vwr.location - range.startIndex
                let adjLen = ((vwr.location + vwr.length) <= range.endIndex) ? vwr.length : (range.endIndex - vwr.location)  //check this
                
                newArray.append(ValueWithRange(value: valCopy, location: adjLoc, length: adjLen))
                
            } else if (vwr.location < range.startIndex && (vwr.location + vwr.length) > range.startIndex) {
                //copy, adjust location, clip end if necessary
                let valCopy = ((vwr.value as? NSObject)?.copy()) ?? vwr.value
                let adjLoc = 0
                let offset = range.startIndex - vwr.location
                let adjLen = vwr.location + vwr.length < range.endIndex ? vwr.length - offset : (range.endIndex - range.startIndex)  //check this
                
                newArray.append(ValueWithRange(value: valCopy, location: adjLoc, length: adjLen))
            }
        }
        
        return newArray
    }
    
    ///inserts array of ValueWithRanges (zero indexed relative to the insertion point) at the given index. If severOverlapping is true (the default), then VWRs with ranges overlapping the index will be severed in two (objects will not be specially copied, ie the same reference will be used for both halves values if values are passed by ref). If severOverlapping is false then overlapping VWRs will only have their lengths extended.
    mutating func insertVWRsatIndex(vwrs:[ValueWithRange],index:Int, severOverlapping:Bool = true) {
        //items before are untouched, items overlapping are handled depending on sever, items after only have their locations extended
        
        
        if severOverlapping {
            
            
            
        } else {
            
            
            
            
        }
        
    }
    
    mutating func deleteVWRsInRange(range:Range<Int>){
        
        
    }
    
    
    //func insertVWRsForRange  : how to handle inserts into the middle of existing VWRs? We should usually sever them since there should typically only be one active VWR for a given range. We should have an option to allow extending instead for the rare cases where that may be desired
    
    //replace range == deleteVWRs in range, insertVWRs at index
    
}
*/
