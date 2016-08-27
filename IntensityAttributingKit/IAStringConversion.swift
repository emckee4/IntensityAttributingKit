//
//  IAStringConversion.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/27/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


///This extension provides the interface for converting an IAString to NSAttributedStrings for display
extension IAString {
    
    ///Gets an array of ranges or Character/word/sentance/etc units, as determined by the separation option
    func unitRanges(withOverridingOptions options:IAStringOptions?)->[Range<Int>]{
        let usingOptions = (self.baseOptions ?? IAKitPreferences.iaStringDefaultBaseOptions).optionsWithOverridesApplied(options)
        return unitRanges(usingOptions.preferedSmoothing)
    }
    
    ///Gets an array of ranges or Character/word/sentance/etc units, as determined by the separation option
    private func unitRanges(tokenizer:IAStringTokenizing)->[Range<Int>]{
        guard self.length > 0 else {return []}
        guard let separationOptions = tokenizer.enumerationOption else {return [0..<((self.text as NSString).length)]  }//assume .Message
        var rangeArray:[Range<Int>] = []
        (self.text as NSString).enumerateSubstringsInRange(NSRange(location: 0, length: self.length), options: separationOptions) { (subString, strictSSRange, enclosingRange, stop) -> Void in
            if subString != nil {
                rangeArray.append(enclosingRange.toRange()!)
            } else {
                fatalError("IAIntermediate:unitRanges: found nil word in \(self.text) at \(strictSSRange) , \(enclosingRange)")
            }
        }
        guard !rangeArray.isEmpty else {return [0..<((self.text as NSString).length)]} ///Tokenizers like .ByWords will yield nothing if the contents of the string are only seperator characters like spaces and newlines.
        return rangeArray
    }
    
    ///Returns a collapsing array filled with the unit-smoothed intensity values.
    private func perUnitSmoothedIntensities(iaTokenizer:IAStringTokenizing)->CollapsingArray<Int>{
        //guard separationOptions != .SubstringNotRequired else {return CollapsingArray(array: self.intensities)}
        var ca:CollapsingArray<Int> = []
        for range in self.unitRanges(iaTokenizer) {
            let rangeLength = range.endIndex - range.startIndex
            let avgForRange:Int = self.intensities[range].reduce(0, combine: +) / rangeLength
            ca.setValueForRange(avgForRange, range: range)
        }
        guard ca.validate() && ca.count == self.intensities.count else {fatalError("(IAIntermediate perUnitSmoothedIntensities) perWord.count == self.intensities.count, with separationOptions: \(iaTokenizer)")}
        return ca
    }
    
    ///Smooths and bins intensities similar to perUnitSmoothedIntensities except that the collapsingArray is filled with bin numbers rather than averaged intensities
    private func binnedSmoothedIntensities(bins:Int, usingTokenizer: IAStringTokenizing)->CollapsingArray<Int>{
        //guard separationOptions != .SubstringNotRequired else {return CollapsingArray(array: self.intensities.map({return binNumberForSteps($0, steps: bins)}))}
        var ca:CollapsingArray<Int> = []
        for range in self.unitRanges(usingTokenizer) {
            let rangeLength = range.endIndex - range.startIndex
            let avgForRange:Int = self.intensities[range].reduce(0, combine: +) / rangeLength
            let bin = IAString.binNumberForSteps(avgForRange, steps: bins)
            ca.setValueForRange(bin, range: range)
        }
        guard ca.validate() && ca.count == self.intensities.count else {fatalError("(IAIntermediate perUnitSmoothedIntensities) perWord.count == self.intensities.count, with separationOptions: \(usingTokenizer)")}
        return ca
    }
    
    static func binNumberForSteps(intensity:Int, steps:Int)->Int{
        return clamp((steps * intensity) / 100, lowerBound: 0, upperBound: steps - 1)
    }
    
    ///Renders a substring out to the boundaries of the tokenized text, which may extend further than the requested range.
    internal func convertRangeToNSAttributedStringExtendingBoundaries(range:Range<Int>, withOverridingOptions options:IAStringOptions? = nil)->(rangeModified:Range<Int>,attString:NSAttributedString) {
        var usingOptions = self.baseOptions ?? IAKitPreferences.iaStringDefaultBaseOptions
        if options != nil {
            usingOptions = usingOptions.optionsWithOverridesApplied(options!)
            
        }
        let trans = usingOptions.renderScheme.transformer

        let smoothedBinned:CollapsingArray<Int> = binnedSmoothedIntensities(trans.stepCount, usingTokenizer: usingOptions.preferedSmoothing)
        assert(smoothedBinned.count == text.utf16.count && text.utf16.count == self.baseAttributes.count)
        

        let startBinDataIndex = smoothedBinned.data.indexOf({$0.range.intersects(range)})!
        let endBinDataIndex = smoothedBinned.data[startBinDataIndex..<smoothedBinned.data.endIndex].indexOf({!($0.range.intersects(range))}) ?? smoothedBinned.data.endIndex

        let modRange = smoothedBinned.data[startBinDataIndex].startIndex ..< smoothedBinned.data[endBinDataIndex - 1].endIndex
        
        let subIA = self.iaSubstringFromRange(modRange)
        let attString = subIA.convertToNSAttributedString(withOverridingOptions: usingOptions)
        

        return (rangeModified:modRange, attString:attString)
        
        
    }
    
    ///Should more clearly define options (maybe with a struct of keys). Need to add option for rendering size and style of thumbnails for attachments.
    public func convertToNSAttributedString(withOverridingOptions options:IAStringOptions? = nil)->NSAttributedString{
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
        
        //render steps needs to come from renderScheme
        var usingOptions = self.baseOptions ?? IAKitPreferences.iaStringDefaultBaseOptions
        if options != nil {
            usingOptions = usingOptions.optionsWithOverridesApplied(options!)
            
        }
        let trans = usingOptions.renderScheme.transformer
        
        
        
        let smoothedBinned:CollapsingArray<Int> = binnedSmoothedIntensities(trans.stepCount, usingTokenizer: usingOptions.preferedSmoothing)
        assert(smoothedBinned.count == text.utf16.count && text.utf16.count == self.baseAttributes.count)
        applyAttributesForStaticDisplay(attString, transformer: trans, smoothedBinned: smoothedBinned)
        
        return attString
    }
    
    private func applyAttributesForStaticDisplay(attString:NSMutableAttributedString, transformer:IntensityTransforming.Type,smoothedBinned:CollapsingArray<Int>){
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
                //currentBin = smoothedBinned.rvp(++binDi)
                binDi += 1
                currentBin = smoothedBinned.rvp(binDi)
            } else if attsEnd < binEnd {
                endIndex = attsEnd
                //currentAtts =  baseAttributes.rvp(++attsDi)
                attsDi += 1
                currentAtts =  baseAttributes.rvp(attsDi)
            } else {
                endIndex = attsEnd
                if endIndex < textLength {
//                    currentBin = smoothedBinned.rvp(++binDi)
//                    currentAtts =  baseAttributes.rvp(++attsDi)
                    binDi += 1
                    currentBin = smoothedBinned.rvp(binDi)
                    attsDi += 1
                    currentAtts =  baseAttributes.rvp(attsDi)
                }
            }
            attString.addAttributes(nsAttributes, range: NSRange(location: currentIndex, length: endIndex - currentIndex))
            currentIndex = endIndex
        }
    }
    ///Checks if modifications to a range of text would change the rendering of text beyond that range. e.g. adding/removing a character in an IAString with .Sentence level intensity smoothing would require that the entire sentence be rerendered (or at least recalculated) to reflect the new average intensity, meaning we would return false. OTOH, modifying a word in an IAString using character or word level smoothing would not affect the rendered intensities of any parts of the string outside the range, so this would return true.
    func checkRangeIsIndependentInRendering(range:Range<Int>, overridingOptions options:IAStringOptions? = nil)->Bool{
        guard range.isEmpty == false else {return true}
        let usingOptions = (self.baseOptions ?? IAKitPreferences.iaStringDefaultBaseOptions).optionsWithOverridesApplied(options)
        let renderedRanges = self.unitRanges(usingOptions.preferedSmoothing)
        if let startRangeIndex = renderedRanges.indexOf({$0.startIndex == range.startIndex}) {
            if renderedRanges[startRangeIndex..<renderedRanges.count].contains({$0.endIndex == range.endIndex}) {
                return true
            }
        }
        return false
    }
    
    ///Returns true if the range of the iaString contains an attachment. This checks the attachment array rather than looking in the string for an attachment character.
    func rangeContainsAttachments(range:Range<Int>)->Bool{
        return !self.attachments.rangeIsEmpty(range)
    }
    
}

extension IAString {
    
    typealias LayeredNSAttributedStrings = (top:NSAttributedString, bottom:NSAttributedString?)
    
    ///Converts iaString to a pair of NSAttributesStrings so that they can be opacity animated. If the render scheme is non animateable then the bottom
    func convertToNSAttributedStringsForLayeredDisplay(withOverridingOptions options:IAStringOptions? = nil)->LayeredNSAttributedStrings{
        guard self.length > 0 else {return LayeredNSAttributedStrings(top: NSAttributedString(), bottom: nil)}
        let attString = NSMutableAttributedString(string: self.text as String)
        for linkRVP in links {
            attString.addAttribute(NSLinkAttributeName, value: linkRVP.value, range: linkRVP.nsRange)
        }
        
        ///attachment and attachSize should always exist together
        for attachTupple in attachments {
            assert(self.text.subStringFromRange(attachTupple.loc..<attachTupple.loc.successor()) == "\u{FFFC}")
            attString.addAttribute(NSAttachmentAttributeName, value: attachTupple.attach, range: NSRange(location:attachTupple.loc, length: 1))
        }
        var usingOptions = self.baseOptions ?? IAKitPreferences.iaStringDefaultBaseOptions
        if options != nil {
            usingOptions = usingOptions.optionsWithOverridesApplied(options!)

        }
        let trans = usingOptions.renderScheme.transformer

        //render steps needs to come from renderScheme
        
        
        let smoothedBinned:CollapsingArray<Int> = binnedSmoothedIntensities(trans.stepCount, usingTokenizer: usingOptions.preferedSmoothing)
        assert(smoothedBinned.count == text.utf16.count && text.utf16.count == self.baseAttributes.count)
        
        if trans.schemeIsAnimatable {
            let bottomAttString = NSMutableAttributedString(attributedString: attString)
            applyAttributesForLayeredDisplay(topAttString:attString, bottomAttString: bottomAttString, transformer: (trans as! AnimatedIntensityTransforming.Type), smoothedBinned: smoothedBinned)
            return LayeredNSAttributedStrings(top:attString, bottom:bottomAttString)
        } else {
            applyAttributesForStaticDisplay(attString, transformer: trans, smoothedBinned: smoothedBinned)
            return LayeredNSAttributedStrings(top:attString, bottom:nil)
        }

    }
    
    private func applyAttributesForLayeredDisplay(topAttString topAttString:NSMutableAttributedString, bottomAttString:NSMutableAttributedString,transformer:AnimatedIntensityTransforming.Type,smoothedBinned:CollapsingArray<Int>){
        let textLength = topAttString.length
        var currentIndex = 0
        var binDi = 0
        var attsDi = 0
        var currentBin = smoothedBinned.rvp(binDi)
        var currentAtts =  baseAttributes.rvp(attsDi)
        while currentIndex < textLength {
            let atts = transformer.layeredNSAttributesForBinsAndBaseAttributes(bin: currentBin.value, baseAttributes: currentAtts.value)
            
            let binEnd = currentBin.range.endIndex
            let attsEnd = currentAtts.range.endIndex
            var endIndex:Int = 0
            if binEnd < attsEnd {
                endIndex = binEnd
                binDi += 1
                currentBin = smoothedBinned.rvp(binDi)
            } else if attsEnd < binEnd {
                endIndex = attsEnd
                attsDi += 1
                currentAtts =  baseAttributes.rvp(attsDi)
            } else {
                endIndex = attsEnd
                if endIndex < textLength {
                    binDi += 1
                    currentBin = smoothedBinned.rvp(binDi)
                    attsDi += 1
                    currentAtts =  baseAttributes.rvp(attsDi)
                }
            }
            let thisRange = NSRange(location: currentIndex, length: endIndex - currentIndex)
            topAttString.addAttributes(atts.top, range: thisRange)
            bottomAttString.addAttributes(atts.bottom, range: thisRange)
            currentIndex = endIndex
        }
    }

    
    ///Renders a substring out to the boundaries of the tokenized text, which may extend further than the requested range.
    internal func convertRangeToLayeredAttStringExtendingBoundaries(range:Range<Int>, withOverridingOptions options:IAStringOptions? = nil)->(rangeModified:Range<Int>,topAttString:NSAttributedString, botAttString:NSAttributedString?) {
//        var usingOptions = self.baseOptions ?? IAKitPreferences.iaStringDefaultBaseOptions
//        if options != nil {
//            usingOptions = usingOptions.optionsWithOverridesApplied(options!)
//        }
        let usingOptions = (self.baseOptions ?? IAKitPreferences.iaStringDefaultBaseOptions).optionsWithOverridesApplied(options)
        let trans = usingOptions.renderScheme.transformer
        
        let smoothedBinned:CollapsingArray<Int> = binnedSmoothedIntensities(trans.stepCount, usingTokenizer: usingOptions.preferedSmoothing)
        assert(smoothedBinned.count == text.utf16.count && text.utf16.count == self.baseAttributes.count)
        
        var modRange:Range<Int>!
        if let startBinDataIndex = smoothedBinned.data.indexOf({$0.range.intersects(range)}) {
            let endBinDataIndex = smoothedBinned.data[startBinDataIndex..<smoothedBinned.data.endIndex].indexOf({!($0.range.intersects(range))}) ?? smoothedBinned.data.endIndex
            modRange = smoothedBinned.data[startBinDataIndex].startIndex ..< smoothedBinned.data[endBinDataIndex - 1].endIndex
            let subIA = self.iaSubstringFromRange(modRange)
            let attStrings = subIA.convertToNSAttributedStringsForLayeredDisplay(withOverridingOptions: options)
            return (rangeModified:modRange,topAttString:attStrings.top, botAttString:attStrings.bottom)
        } else {
            let attStrings = self.convertToNSAttributedStringsForLayeredDisplay(withOverridingOptions: options)
            return (rangeModified:0..<self.length,topAttString:attStrings.top, botAttString:attStrings.bottom)
        }
    }
    
    
    
}


