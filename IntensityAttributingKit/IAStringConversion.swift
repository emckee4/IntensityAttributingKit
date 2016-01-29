//
//  IAStringConversion.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/27/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation



extension IAString {
    
    
    ///Gets an array of ranges or Character/word/sentance/etc units, as determined by the separation option
    private func unitRanges(separationOptions:NSStringEnumerationOptions)->[Range<Int>]{
        guard self.text.length > 0 else {return []}
        var rangeArray:[Range<Int>] = []
        self.text.enumerateSubstringsInRange(NSRange(location: 0, length: self.text.length), options: separationOptions) { (subString, strictSSRange, enclosingRange, stop) -> Void in
            if subString != nil {
                rangeArray.append(enclosingRange.intRange)
            } else {
                fatalError("IAIntermediate:unitRanges: found nil word in \(self.text) at \(strictSSRange) , \(enclosingRange)")
            }
        }
        return rangeArray
    }
    
    ///Returns a collapsing array filled with the unit-smoothed intensity values.
    private func perUnitSmoothedIntensities(separationOptions:NSStringEnumerationOptions)->CollapsingArray<Int>{
        guard separationOptions != .SubstringNotRequired else {return CollapsingArray(array: self.intensities)}
        var ca:CollapsingArray<Int> = []
        for range in self.unitRanges(separationOptions) {
            let rangeLength = range.endIndex - range.startIndex
            let avgForRange:Int = self.intensities[range].reduce(0, combine: +) / rangeLength
            ca.setValueForRange(avgForRange, range: range)
        }
        guard ca.validate() && ca.count == self.intensities.count else {fatalError("(IAIntermediate perUnitSmoothedIntensities) perWord.count == self.intensities.count, with separationOptions: \(separationOptions)")}
        return ca
    }
    
    ///Smooths and bins intensities similar to perUnitSmoothedIntensities except that the collapsingArray is filled with bin numbers rather than averaged intensities
    private func binnedSmoothedIntensities(bins:Int, separationOptions: NSStringEnumerationOptions)->CollapsingArray<Int>{
        guard separationOptions != .SubstringNotRequired else {return CollapsingArray(array: self.intensities.map({return binNumberForSteps($0, steps: bins)}))}
        var ca:CollapsingArray<Int> = []
        for range in self.unitRanges(separationOptions) {
            let rangeLength = range.endIndex - range.startIndex
            let avgForRange:Int = self.intensities[range].reduce(0, combine: +) / rangeLength
            let bin = binNumberForSteps(avgForRange, steps: bins)
            ca.setValueForRange(bin, range: range)
        }
        guard ca.validate() && ca.count == self.intensities.count else {fatalError("(IAIntermediate perUnitSmoothedIntensities) perWord.count == self.intensities.count, with separationOptions: \(separationOptions)")}
        return ca
    }
    
    
//    private func generateIntensityAttributesArray(renderSteps steps:Int, separateOn separator:NSStringEnumerationOptions)->[(range:NSRange, ia:IntensityAttributes)]{
//        //centers the intensity in its bin
//        let binWidth = 1 / Float(steps)
//        let smoother:(Float)->(Float) = { (intensity)->(Float) in
//            guard intensity > 0.0 else {return 0.0}
//            guard intensity < 1.0 else {return (Float(steps) - 0.5) * binWidth}
//            let bin = intensity / binWidth
//            return (floor(bin) + 0.5) * binWidth
//        }
//        let binnedIntensities:[Float] = self.perUnitSmoothedIntensities(separator).map(smoother)
//        
//        return generateIAThenCondenseRanges(binnedIntensities)
//    }
//    
//    
//    
//    private func generateIAThenCondenseRanges(binnedIntensities:[Float])->[(range:NSRange, ia:IntensityAttributes)]{
//        let rawArray = generateIARawArray(binnedIntensities)
//        var resultArray:[(range:NSRange, ia:IntensityAttributes)] = []
//        
//        var currentItem:IntensityAttributes!
//        var currentLoc:Int = 0
//        var currentLen:Int = 1
//        for (index, ia) in rawArray.enumerate() {
//            if index == 0 {
//                currentItem = ia
//                currentLoc = 0
//                currentLen = 1
//            } else if currentItem == ia {
//                currentLen += 1
//            } else {
//                resultArray.append((range:NSRange(location: currentLoc, length: currentLen), ia:currentItem))
//                currentItem = ia
//                currentLoc = index
//                currentLen = 1
//            }
//        }
//        resultArray.append((range:NSRange(location: currentLoc, length: currentLen), ia:currentItem))
//        
//        return resultArray
//    }
//    
//    private func generateIARawArray(binnedIntensities:[Float])->[IntensityAttributes]{
//        var intensityAttributes:[IntensityAttributes] = []
//        intensityAttributes.reserveCapacity(self.text.length)
//        
//        for sizeVWR in textSizes {
//            for index in (sizeVWR.location)..<(sizeVWR.location + sizeVWR.length){
//                intensityAttributes.append(IntensityAttributes(intensity: binnedIntensities[index], size: sizeVWR.value as! CGFloat))
//            }
//        }
//        assert(intensityAttributes.count == self.text.length, "intensityAttributes.count == self.text.length")
//        
//        for boldRange in bolds {
//            for i in (boldRange.location)..<(boldRange.location + boldRange.length) {
//                intensityAttributes[i].isBold = true
//            }
//        }
//        for italRange in italics {
//            for i in (italRange.location)..<(italRange.location + italRange.length) {
//                intensityAttributes[i].isItalic = true
//            }
//        }
//        for undRange in underlines {
//            for i in (undRange.location)..<(undRange.location + undRange.length) {
//                intensityAttributes[i].isUnderlined = true
//            }
//        }
//        for strikeRange in strikethroughs {
//            for i in (strikeRange.location)..<(strikeRange.location + strikeRange.length) {
//                intensityAttributes[i].isStrikethrough = true
//            }
//        }
//        return intensityAttributes
//    }
    
    ///Should more clearly define options (maybe with a struct of keys). Need to add option for rendering size and style of thumbnails for attachments.
    public func convertToNSAttributedString(withOptions options:[String:AnyObject]? = nil)->NSAttributedString{
        let attString = NSMutableAttributedString(string: self.text as String)
        for linkRVP in links {
            attString.addAttribute(NSLinkAttributeName, value: linkRVP.value, range: linkRVP.nsRange)
        }
        
        ///attachment and attachSize should always exist together
        for attachTupple in attachments {
            assert(self.text.substringWithRange(NSRange(location: attachTupple.loc, length: 1)) == "\u{FFFC}")
            attString.addAttribute(NSAttachmentAttributeName, value: attachTupple.attach, range: NSRange(location:attachTupple.loc, length: 1))
        }
        
        //options have two levels: prefered (internal) and override passed in by the user. Override trumps internal
        var renderWithScheme = self.renderScheme
        if let overrideScheme = options?["renderWithScheme"] as? String where IntensityTransformers(rawValue: overrideScheme) != nil{
            renderWithScheme = IntensityTransformers(rawValue: overrideScheme)
        }
        let transformer = renderWithScheme.transformer
        
        var useSmoothing:NSStringEnumerationOptions!
        if let smoothing = options?["smoothingSeparator"] as? NSStringEnumerationOptions {
            useSmoothing = smoothing
        } else {
            useSmoothing = self.preferedSmoothing
        }
        
        //other options should be implemented here...
        
        
        //render steps needs to come from renderScheme
        
        
        let smoothedBinned:CollapsingArray<Int> = binnedSmoothedIntensities(transformer.stepCount, separationOptions: useSmoothing)
        assert(smoothedBinned.count == text.length && text.length == self.baseAttributes.count)
        applyAttributes(attString, transformer: transformer, smoothedBinned: smoothedBinned)
        
        return attString
    }
    
    private func applyAttributes(attString:NSMutableAttributedString, transformer:IntensityTransforming.Type,smoothedBinned:CollapsingArray<Int>){
        let textLength = attString.length
        var currentIndex = 0
        var binDi = 0
        var attsDi = 0
        var currentBin = smoothedBinned.rvp(binDi)
        var currentAtts =  baseAttributes.rvp(attsDi)
        while currentIndex < textLength {
            let nsAttributes = transformer.nsAttributesForBinsAndBaseAttributes(bin: currentBin.value, baseAttributes: currentAtts.value)
            let binEnd = currentBin.range.endIndex
            let attsEnd = currentAtts.range.endIndex
            var endIndex:Int!
            if binEnd < attsEnd {
                endIndex = binEnd
                currentBin = smoothedBinned.rvp(++binDi)
            } else if attsEnd < binEnd {
                endIndex = attsEnd
                currentAtts =  baseAttributes.rvp(++attsDi)
            } else {
                endIndex == attsEnd
                if endIndex < textLength {
                    currentBin = smoothedBinned.rvp(++binDi)
                    currentAtts =  baseAttributes.rvp(++attsDi)
                }
            }
            attString.addAttributes(nsAttributes, range: NSRange(location: currentIndex, length: endIndex - currentIndex))
            currentIndex = endIndex
        }
    }
}


///Extension providing subrange from range
extension IAString {
    
    convenience init!(text:NSString, intensities:[Int], baseAtts:CollapsingArray<IABaseAttributes>, attachments:IAAttachmentArray? = nil){
        self.init()
        let length = text.length
        guard length == baseAtts.count && length == intensities.count && (attachments?.lastLoc ?? 0) <= length else {return nil}
        self.text = text
        self.intensities = intensities
        self.baseAttributes = baseAtts
        if let attaches = attachments {
            self.attachments = attaches
        }
    }
    
    
    
    ///This provides a new IAString comprised of copies of the contents in the given range. This inherits its parent's options. It will reindex its attributes and it will discard links.
    public func iaSubstringFromRange(range:Range<Int>)->IAString {
        let substring = self.text.substringWithRange(range.nsRange)
        let intensities = Array(self.intensities[range])
        let baseAttsSub = self.baseAttributes.subRange(range)
        //links are ignored
        let attachSubs = self.attachments.reindexedSubrange(range)
        let newIA = IAString(text: substring, intensities: intensities,baseAtts: baseAttsSub, attachments: attachSubs)

        newIA.renderScheme = self.renderScheme
        newIA.renderOptions = self.renderOptions
        newIA.preferedSmoothing = self.preferedSmoothing
        return newIA
    }
    
    

    
    ///Append a 0 based IAString
    public func appendIAString(iaString:IAString){
        let appendingFromIndex = self.text.length
        //let startingLength = self.text.length
        let appendLength = iaString.text.length
        self.text = self.text.stringByAppendingString(iaString.text as String)
        self.baseAttributes.appendContentsOf(iaString.baseAttributes) //should automatically rebase
        self.intensities.appendContentsOf(iaString.intensities)
        //adding links and attachments requires rebasing those arrays manually
        //self.links.appendWithReindexing(iaString.links, reindexBy: startingLength)
        self.attachments.replaceRange(iaString.attachments, ofLength: appendLength, replacedRange: appendingFromIndex..<appendingFromIndex)
        
    }
    
    
    public func insertIAString(iaString:IAString, atIndex:Int){
        let mutableString = self.text.mutableCopy() as! NSMutableString
        mutableString.insertString(iaString.text as String, atIndex: atIndex)
        self.text = mutableString
        self.intensities.insertContentsOf(iaString.intensities, at: atIndex)
        self.baseAttributes.insertContentsOf(iaString.baseAttributes, at: atIndex)
        self.attachments.insertAttachments(iaString.attachments, ofLength: iaString.length, atIndex: atIndex)
        
    }
    
    public func removeRange(range:Range<Int>){
        self.text = self.text.stringByReplacingCharactersInRange(range.nsRange, withString: "")
        self.intensities.removeRange(range)
        self.baseAttributes.removeRange(range)
        self.attachments.removeSubrange(range)
    }
    
    public func replaceRange(replacement:IAString, range:Range<Int>){
        self.text = self.text.stringByReplacingCharactersInRange(range.nsRange, withString: replacement.text as String)
        self.intensities.replaceRange(range, with: replacement.intensities)
        self.baseAttributes.replaceRange(range, with: replacement.baseAttributes)
        self.attachments.replaceRange(replacement.attachments, ofLength: replacement.length, replacedRange: range)
        
    }
    
    
    //convenience editor
    public func insertAtPosition(text:String, position:Int, intensity:Int, attributes:IABaseAttributes){
        let mutableString = self.text.mutableCopy() as! NSMutableString
        mutableString.insertString(text, atIndex: position)
        self.text = mutableString
        let insertLength = (text as String).utf16.count
        self.intensities.insertContentsOf(Array<Int>(count: insertLength, repeatedValue: intensity), at: position)
        self.baseAttributes.insertContentsOf(Array<IABaseAttributes>(count: insertLength, repeatedValue: attributes), at: position)
        self.attachments.insertAttachment(nil, atLoc: position)
    }
    
    public func insertAttachmentAtPosition(attachment:IATextAttachment, position:Int, intensity:Int ,attributes:IABaseAttributes){
        let mutableString = self.text.mutableCopy() as! NSMutableString
        mutableString.insertString("\u{FFFC}", atIndex: position)
        self.text = mutableString
        self.intensities.insert(intensity, atIndex: position)
        self.baseAttributes.insert(attributes, atIndex: position)
        attachments.insertAttachment(attachment, atLoc: position)
    }
    
}


private typealias IALocAttachTupple = (loc:Int,attach:IATextAttachment)

//private func ==(lhs:IALocAttachTupple, rhs:IALocAttachTupple){
//    return rhs.loc == lhs.loc &&
//}

private extension MutableCollectionType where Generator.Element == IALocAttachTupple {
    
    mutating func reindexLocRange(locRange:Range<Int>! = nil, reindexBy by:Int){
        for i in self.startIndex..<self.endIndex {
            if locRange == nil || (self[i].loc >= locRange.startIndex && self[i].loc < locRange.endIndex) {
                self[i] = IALocAttachTupple(loc:self[i].loc + by,attach:self[i].attach)
            }
        }
    }
    
    func subrangeWithLocsInRange(locRange:Range<Int>)->Array<IALocAttachTupple>{
        var sub = Array<IALocAttachTupple>()
        for item in self {
            if item.loc >= locRange.startIndex && item.loc < locRange.endIndex {
                sub.append(item)
            }
        }
        return sub
    }
    
    ///Returns a copy of the subrange with textAttachment locs adjusted to maintain relative position
    func zeroIndexedSubrange(locRange:Range<Int>)->Array<IALocAttachTupple>{
        var sub = self.subrangeWithLocsInRange(locRange)
        sub.reindexLocRange(reindexBy: -locRange.startIndex)
        return sub
    }
    
    //Returns a copy of self with the locRange removed and loc indeces adjusted to reflect that
    func rangeRemovedWithLocAdjustment(locRange:Range<Int>)->Array<IALocAttachTupple>{
        var newSelf = self as! Array<IALocAttachTupple>
        var shouldRepeat = false
        repeat {
            shouldRepeat = false
            for i in newSelf.startIndex..<newSelf.endIndex{
                if newSelf[i].loc >= locRange.startIndex && newSelf[i].loc < locRange.endIndex {
                    newSelf.removeAtIndex(i)
                    shouldRepeat = true
                    break
                }
            }
        } while shouldRepeat
        if let lastLoc = newSelf.last?.loc {
            newSelf.reindexLocRange(locRange.startIndex...lastLoc, reindexBy: -locRange.count)
        }
        return newSelf
    }
    
    //need insert
    func insertZeroedSubrange(subRange:Array<IALocAttachTupple>, atPosition:Int ,locLength:Int) {
        
    }
    
    
    //need replace range
    
    
}
//
//
//private extension Array where Element:RVPProtocol {
//    mutating func reindexInPlace(by:Int){
//        for i in 0..<self.count{
//            self[i].reindex(by)
//        }
//    }
//    
//    func reindexed(by:Int)->Array<Element>{
//        var newArray = self
//        for i in 0..<self.count {
//            newArray[i].reindex(by)
//        }
//        return newArray
//    }
//    
//    mutating func reindexPastIndex(past:Int, reindexBy:Int, removeIntersected:Bool = true){
//        for i in 0..<self.count {
//            if self[i].startIndex >= past && self[i].endIndex < past {
//                if removeIntersected {
//                    self.removeAtIndex(i)
//                    reindexPastIndex(past, reindexBy: reindexBy)
//                } else {
//                    self[i].endIndex = past
//                }
//            } else if self[i].startIndex > past{
//                self[i].reindex(reindexBy)
//            }
//        }
//    }
//    
//    mutating func appendWithReindexing(contents:Array<Element>, reindexBy:Int){
//        guard !contents.isEmpty else {return}
//        let reindexedContents = contents.reindexed(reindexBy)
////        if let lastSelf = self.last, firstAppended = reindexedContents.first where lastSelf.endIndex == firstAppended.startIndex && lastSelf.hasEqualValue(firstAppended) {
////            let existingCount = self.count
////            self[existingCount - 1].endIndex = firstAppended.endIndex
////            self.appendContentsOf(reindexedContents[1..<reindexedContents.endIndex])
////        } else {
////            self.appendContentsOf(reindexedContents)
////        }
//        self.appendContentsOf(reindexedContents)
//    }
//    
//    ///If removeIntersected == true (the default) then any rvp which overlaps the insertLocation will be removed entirely. Otherwise the rvp will be clipped.
//    mutating func insertRVPArray(array:Array<Element>, location:Int, reindexBy:Int, removeIntersected:Bool = true){
//        self.reindexPastIndex(location, reindexBy: reindexBy, removeIntersected: removeIntersected)
//        let insertItems = array.reindexed(location)
//        for i in 0..<self.count{
//            if self[i].endIndex > location {
//                self.insert(<#T##newElement: RVPProtocol##RVPProtocol#>, atIndex: <#T##Int#>)
//            }
//            
//        }
//        self.appendContentsOf(insertItems)
//    }
//    
//    ///remove partial causes anything intersecting to be removed. Otherwise partially intersecting will be clipped
//    mutating func removeItemsWithRange(range:Range<Int>, removePartials:Bool = true){
//        
//    }
//}


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
