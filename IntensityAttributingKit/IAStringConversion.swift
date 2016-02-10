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
        guard self.length > 0 else {return []}
        var rangeArray:[Range<Int>] = []
        (self.text as NSString).enumerateSubstringsInRange(NSRange(location: 0, length: self.length), options: separationOptions) { (subString, strictSSRange, enclosingRange, stop) -> Void in
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
        guard self.length > 0 else {return NSAttributedString()}
        let attString = NSMutableAttributedString(string: self.text as String)
        for linkRVP in links {
            attString.addAttribute(NSLinkAttributeName, value: linkRVP.value, range: linkRVP.nsRange)
        }
        
        ///attachment and attachSize should always exist together
        for attachTupple in attachments {
            assert(self.text.subStringFromRange(attachTupple.loc..<attachTupple.loc.successor()) == "\u{FFFC}")
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
        assert(smoothedBinned.count == text.utf16.count && text.utf16.count == self.baseAttributes.count)
        applyAttributes(attString, transformer: transformer, smoothedBinned: smoothedBinned)
        
        return attString
    }
    
    private func applyAttributes(attString:NSMutableAttributedString, transformer:IntensityTransforming.Type,smoothedBinned:CollapsingArray<Int>){
        //guard let self.length > 0 else {return} //This is left to the public function calling it to check
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
            var endIndex:Int = 0
            if binEnd < attsEnd {
                endIndex = binEnd
                currentBin = smoothedBinned.rvp(++binDi)
            } else if attsEnd < binEnd {
                endIndex = attsEnd
                currentAtts =  baseAttributes.rvp(++attsDi)
            } else {
                endIndex = attsEnd
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

