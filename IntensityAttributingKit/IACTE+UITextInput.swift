//
//  IACTE+UITextInput.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/19/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation

/*
UIKeyInput, UITextInput Implementations along with underlying functions using IA Objects.
Layout directions are hard coded at present. For most UITextInput functions there is a native option with "IA" in the name which takes and returns IATextPosition/IATextRange objects and the like. They're located in the later part of this file.
 
 setMarkedText, setBaseWritingDirection are not implemented and will print warnings then do nothing.
 baseWritingDirectionForPosition is hard coded to return .Natural
 
 I don't know enough about text layout and rendering in non western scripts to provide full functionality for non-western scripts at this point.
*/
extension IACompositeTextEditor {
    
    
    //MARK:- UIKeyInput functions
    
    public func insertText(text: String) {
        guard selectedRange != nil else {print("insertText called while selectedRange is nil"); return}
        let replacement = IAString(text: text, intensity: currentIntensity, attributes: baseAttributes)
        replaceIAStringRange(replacement, range: selectedRange!)
    }
    
    public func deleteBackward() {
        guard let sr = selectedRange else {return}
        if sr.isEmpty {
            if sr.startIndex > 0 {
                if let predecessorIndex = tokenizer.positionFromPosition(selectedTextRange!.start, toBoundary: UITextGranularity.Character, inDirection: UITextStorageDirection.Backward.rawValue) {
                    let start = offsetFromPosition(self.beginningOfDocument, toPosition: predecessorIndex)
                    let delRange = start..<sr.startIndex
                    deleteIAStringRange(delRange)
                } else {
                    print("index matching error in deleteBackwards when tring to find the index for \(sr.startIndex)")
                }
            } else {
                return
            }
        } else {
            deleteIAStringRange(sr)
        }
        //updateSelectionIndicators()
    }
    
    public func hasText() -> Bool {
        guard iaString != nil else {return false}
        return !(iaString!.text.isEmpty)
    }
    
    
    //MARK:- UITextInput Functions
    
    public func textInRange(range: UITextRange) -> String? {
        guard let range = (range as? IATextRange)?.range() else {print("text in range received non IATextRange as a parameter"); return nil}
        return iaString.text.subStringFromRange(range)
    }
    
    public func replaceRange(range: UITextRange, withText text: String) {
        guard let iaRange = (range as? IATextRange) else {print("UITextInput.replaceRange received non IATextRange as a parameter"); return}
        let replacement = IAString(text: text, intensity: currentIntensity, attributes: baseAttributes)
        replaceIAStringRange(replacement, range: iaRange.range())
    }

    
    public func setMarkedText(markedText: String?, selectedRange: NSRange) {
        fatalError("setMarkedText not properly implemented")
    }
    
    public func unmarkText() {
        markedRange = nil
    }
    
    //MARK: Ranging and positioning
    
    public func textRangeFromPosition(fromPosition: UITextPosition, toPosition: UITextPosition) -> UITextRange? {
        guard let fromPosition = (fromPosition as? IATextPosition), toPosition = (toPosition as? IATextPosition) else {print("UITextInput.textRangeFromPosition received non IATextPositions as a parameters"); return nil}
        return iaTextRangeFromPosition(fromPosition, toPosition: toPosition)
    }
    
    public func positionFromPosition(position: UITextPosition, offset: Int) -> UITextPosition? {
        guard let position = (position as? IATextPosition) else {print("UITextInput.positionFromPosition received non IATextPosition as a parameters"); return nil}
        return iaPositionFromPosition(position, offset: offset)
    }
    
    public func positionFromPosition(position: UITextPosition, inDirection direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
        guard let position = (position as? IATextPosition) else {print("UITextInput.positionFromPosition received non IATextPosition as a parameters"); return nil}
        ////guard direction == .Right else {print("positionFromPosition: receive layout direction of \(direction), rather than .Right (raw == 2) as expected"); return nil}
        switch direction {
        case .Right:
            return iaPositionFromPosition(position, offset: offset)
        case .Left:
            return iaPositionFromPosition(position, offset: -offset)
        case .Up:
            //same result for any offset value
            let gi = topTV.layoutManager.glyphIndexForCharacterAtIndex(position.position)
            let br = topTV.layoutManager.boundingRectForGlyphRange(NSMakeRange(gi, 0), inTextContainer: topTV.textContainer)
            let higherPoint = CGPointMake(br.origin.x, br.origin.y - 0.5 * br.height)
            return closestIAPositionToPoint(higherPoint)
        case .Down:
            //same result for any offset value
            let gi = topTV.layoutManager.glyphIndexForCharacterAtIndex(position.position)
            let br = topTV.layoutManager.boundingRectForGlyphRange(NSMakeRange(gi, 0), inTextContainer: topTV.textContainer)
            let lowerPoint = CGPointMake(br.origin.x, br.origin.y + 1.5 * br.height)
            return closestIAPositionToPoint(lowerPoint) 
        }
    }
    
    public func comparePosition(position: UITextPosition, toPosition other: UITextPosition) -> NSComparisonResult {
        guard let position = (position as? IATextPosition), other = (other as? IATextPosition) else {fatalError("UITextInput.comparePosition received non IATextPositions as a parameters")}
        return compareIAPosition(position, toPosition: other)
    }
    
    public func offsetFromPosition(from: UITextPosition, toPosition: UITextPosition) -> Int {
        guard let from = (from as? IATextPosition), to = (toPosition as? IATextPosition) else {fatalError("UITextInput.comparePosition received non IATextPositions as a parameters")}
        return offsetFromIAPosition(from, toPosition: to)
    }
    
    public func positionWithinRange(range: UITextRange, farthestInDirection direction: UITextLayoutDirection) -> UITextPosition? {
        guard let range = (range as? IATextRange) else {print("UITextInput.positionWithinRange received non IATextRange as a parameter: returning nil"); return nil}
        return iaPositionWithinRange(range, farthestInDirection: direction)
    }
    
    public func characterRangeByExtendingPosition(position: UITextPosition, inDirection direction: UITextLayoutDirection) -> UITextRange? {
        guard let position = (position as? IATextPosition) else {fatalError("UITextInput.characterRangeByExtendingPosition received non IATextPositions as a parameters")}
        return characterRangeByExtendingIAPosition(position, inDirection: direction)
    }
    
    public func baseWritingDirectionForPosition(position: UITextPosition, inDirection direction: UITextStorageDirection) -> UITextWritingDirection {
        return UITextWritingDirection.LeftToRight
    }
    public func setBaseWritingDirection(writingDirection: UITextWritingDirection, forRange range: UITextRange) {
        if writingDirection == .LeftToRight {
            print("setBaseWritingDirection: received baseWriting direction other than natural. Ignoring.")
        }
    }
    
        
    //MARK: Geometry and hit testing
    
    public func firstRectForRange(range: UITextRange) -> CGRect {
        guard let range = (range as? IATextRange) else {print("UITextInput.firstRectForRange received non IATextRange as a parameter: returning CGRectZero"); return CGRectZero}
        return firstRectForIARange(range)
    }
    
    ///Note: This assumes forward layout direction with left-to-right writing.
    public func caretRectForPosition(position: UITextPosition) -> CGRect {
        guard let position = (position as? IATextPosition) else {fatalError("UITextInput.caretRectForPosition received non IATextPosition as a parameters")}
        return caretRectForIAPosition(position)
    }
    
    ///Yields the character index of the following glyph if the point is more than halfway towards the far side of the glyph. This utilizes the primitive of closestIAPositionToPoint
    public func closestPositionToPoint(point: CGPoint) -> UITextPosition? {
        return closestIAPositionToPoint(point)
    }
    
    public func closestPositionToPoint(point: CGPoint, withinRange range: UITextRange) -> UITextPosition? {
        guard let range = (range as? IATextRange) else {print("UITextInput.closestPositionToPoint received non IATextRange as a parameter: returning nil"); return nil}
        return closestIAPositionToPoint(point, withinRange: range)
    }
    
    /// Writing Direction and isVertical are hardcoded in this to .Natural and false, respectively. Uses iaSelectionRectsForRange.
    public func selectionRectsForRange(range: UITextRange) -> [AnyObject] {
        guard let range = (range as? IATextRange) else {print("UITextInput.selectionRectsForRange received non IATextRange as a parameter: returning CGRectZero"); return []}
        return iaSelectionRectsForRange(range)
    }
    
    public func characterRangeAtPoint(point: CGPoint) -> UITextRange? {
        return characterIATextRangeAtPoint(point)
    }

    public var textInputView: UIView {return self}
    
    
    
    
    ///////////////////////////////////////////////////////////////////
    //MARK:- Native implementations (using IATextRange/Position objects
    
    func textInIARange(range: IATextRange) -> IAString {
        return iaString.iaSubstringFromRange(range.range())
    }
    
    public func iaTextRangeFromPosition(fromPosition: IATextPosition, toPosition: IATextPosition) -> IATextRange? {
        guard fromPosition.position >= 0 && toPosition.position <= iaString.length else {return nil}
        return IATextRange(start: fromPosition, end: toPosition)
    }
    
    public func iaPositionFromPosition(position: IATextPosition, offset: Int) -> IATextPosition? {
        let newLoc = position.position + offset
        guard newLoc >= 0 && newLoc <= iaString.length else {
            //print("UITextInput.positionFromPosition: new position would be out of bounds: \(position), + \(offset)");
            return nil}
        return position.positionWithOffset(offset)
    }
    
    ///Layout direction is presently hard coded
    public func iaPositionFromPosition(position: IATextPosition, inDirection direction: UITextLayoutDirection, offset: Int) -> IATextPosition? {
        return iaPositionFromPosition(position, offset: offset)
    }
    
    func compareIAPosition(position: IATextPosition, toPosition other: IATextPosition) -> NSComparisonResult {
        return (position.position as NSNumber).compare(other.position as NSNumber)
    }
    
    func offsetFromIAPosition(from: IATextPosition, toPosition: IATextPosition) -> Int {
        return toPosition.position - from.position
    }
    ///Hardcoded with left to right. Note this doesn't respect glyph boundaries, just like the native implementation of UITextView's function.
    public func iaPositionWithinRange(range: IATextRange, farthestInDirection direction: UITextLayoutDirection) -> IATextPosition? {
        if direction == .Up || direction == .Left {
            return range.iaStart
        } else {
            return range.iaEnd
        }
    }
    
    ///This yields the same results as the function in UITextView, though I'm not entirely sure what this function is for or why (why doesn't it at least extend to the end of a non-decomposable glyph?)
    func characterRangeByExtendingIAPosition(position: IATextPosition, inDirection direction: UITextLayoutDirection) -> IATextRange? {
        if direction == .Left {
            return IATextRange(start: position.positionWithOffset(-1),end: position)
        } else {
            return IATextRange(start: position,end: position.positionWithOffset(1))
        }
    }
    
//    func baseWritingDirectionForIAPosition(position: IATextPosition, inDirection direction: UITextStorageDirection) -> UITextWritingDirection {}
//    public func iaSetBaseWritingDirection(writingDirection: UITextWritingDirection, forRange range: IATextRange) {
//    }
    
    
    //MARK: IA geometry testing
    
    func firstRectForIARange(range: IATextRange) -> CGRect {
        var actualRange = NSRange()
        topTV.layoutManager.glyphRangeForCharacterRange(range.nsrange(), actualCharacterRange: &actualRange)
        var firstRect = CGRectZero
        topTV.layoutManager.enumerateEnclosingRectsForGlyphRange(actualRange, withinSelectedGlyphRange: NSMakeRange(NSNotFound, 0), inTextContainer: topTV.textContainer) { (rect, stop) in
            firstRect = rect
            stop.initialize(true)
        }
        return self.convertRect(firstRect, fromView: topTV)
    }
    
    ///Note: This assumes forward layout direction with left-to-right writing. Caret width is fixed at 2 points
    func caretRectForIAPosition(position: IATextPosition) -> CGRect {
        return caretRectForIntPosition(position.position)
    }
    
    /// Writing Direction and isVertical are hardcoded in this to .Natural and false, respectively.
    func iaSelectionRectsForRange(range: IATextRange) -> [IATextSelectionRect]{
        return selectionRectsForIntRange(range.range())
    }
    
    ///Yields the character index of the following glyph if the point is more than halfway towards the far side of the glyph. Returns the IATextPostion object.
    func closestIAPositionToPoint(point:CGPoint)->IATextPosition {
        let convertedPoint = self.convertPoint(point, toView: topTV)
        var fraction:CGFloat = 0
        let glyphIndex = topTV.layoutManager.glyphIndexForPoint(convertedPoint, inTextContainer: topTV.textContainer, fractionOfDistanceThroughGlyph: &fraction )
        if fraction < 0.5 {
            let charIndex = topTV.layoutManager.characterIndexForGlyphAtIndex(glyphIndex)
            return IATextPosition(charIndex)
        } else {
            let charIndex = topTV.layoutManager.characterIndexForGlyphAtIndex(glyphIndex + 1)
            return IATextPosition(charIndex)
        }
    }
    
    func closestIAPositionToPoint(point: CGPoint, withinRange range: IATextRange) -> IATextPosition {
        let pos = self.closestIAPositionToPoint(point)
        if range.contains(pos) {
            return pos
        } else if range.iaStart > pos {
            return range.iaStart
        } else {
            return range.iaEnd
        }
    }
    
    ///Currently not using fraction value
    func characterIATextRangeAtPoint(point: CGPoint)->IATextRange {
        let convertedPoint = self.convertPoint(point, toView: topTV)
        var fraction:CGFloat = 0
        let glyphIndex = topTV.layoutManager.glyphIndexForPoint(convertedPoint, inTextContainer: topTV.textContainer, fractionOfDistanceThroughGlyph: &fraction )
        
        let startIndex = topTV.layoutManager.characterIndexForGlyphAtIndex(glyphIndex)
        let endIndex = topTV.layoutManager.characterIndexForGlyphAtIndex(glyphIndex + 1)
        return IATextRange(range: startIndex..<endIndex)
    }
        
    ///Returns the next boundary after the position unless the position is itself a boundary in which case it returns itself
    func nextBoundaryIncludingOrAfterIAPosition(position:IATextPosition)->IATextPosition{
        if position.position == 0 {
            return position
        } else if position == endOfDocument {
            return position
        } else if tokenizer.isPosition(position, atBoundary: .Word, inDirection: 1) {
            return position
        } else if let newPos = tokenizer.positionFromPosition(position, toBoundary: .Word, inDirection: 0) as? IATextPosition{
            return newPos
        } else {
            return endOfDocument as! IATextPosition
        }
        
    }
    
}




