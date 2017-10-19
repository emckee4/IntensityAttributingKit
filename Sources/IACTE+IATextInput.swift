//
//  IACTE+IATextInput.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/17/17.
//  Copyright © 2017 McKeeMaKer. All rights reserved.
//

import Foundation

extension IACompositeTextEditor {
    
    ///////////////////////////////////////////////////////////////////
    //MARK:- Native implementations (using IATextRange/Position objects
    
    func textInIARange(_ range: IATextRange) -> IAString {
        return iaString.iaSubstringFromRange(range.range(inIAString: iaString))
    }
    
    public func iaTextRangeFromPosition(_ fromPosition: IATextPosition, toPosition: IATextPosition) -> IATextRange? {
        guard fromPosition.position >= 0 && toPosition.position <= iaString.text.count else {return nil}
        return IATextRange(start: fromPosition, end: toPosition)
    }
    
    public func iaPositionFromPosition(_ position: IATextPosition, offset: Int) -> IATextPosition? {
        return position.withCharacterOffset(offset, iaString: self.iaString)
    }
    
    public func iaPositionFromPosition(_ position: IATextPosition, utf16Offset: Int) -> IATextPosition? {
        return position.withUTF16Offset(utf16Offset, iaString: self.iaString)
    }
    
    ///Layout direction is presently hard coded
    public func iaPositionFromPosition(_ position: IATextPosition, inDirection direction: UITextLayoutDirection, offset: Int) -> IATextPosition? {
        //TODO: Update this to handle other text directions?
        switch direction {
        case .right: print("iaPositionFromPosition.inDirection: RIGHT")
        case .left: print("iaPositionFromPosition.inDirection: LEFT")
        case .down: print("iaPositionFromPosition.inDirection: DOWN")
        case .up: print("iaPositionFromPosition.inDirection: UP")
        }
        return iaPositionFromPosition(position, offset: offset)
    }
    
    func compareIAPosition(_ position: IATextPosition, toPosition other: IATextPosition) -> ComparisonResult {
        //TODO: Update this to handle other text directions?
        return (position.position as NSNumber).compare(other.position as NSNumber)
    }
    
    ///utf16 characters separating these positions
    func offsetFromIAPosition(_ from: IATextPosition, toPosition: IATextPosition) -> Int {
        let fromOffset = iaString.text.index(iaString.text.startIndex, offsetBy: from.position).encodedOffset
        let toOffset = iaString.text.index(iaString.text.startIndex, offsetBy: toPosition.position).encodedOffset
        return toOffset - fromOffset
    }
    ///Hardcoded with left to right. Note this doesn't respect glyph boundaries, just like the native implementation of UITextView's function.
    public func iaPositionWithinRange(_ range: IATextRange, farthestInDirection direction: UITextLayoutDirection) -> IATextPosition? {
        //TODO: Update this to handle other text directions?
        if direction == .up || direction == .left {
            return range.iaStart
        } else {
            return range.iaEnd
        }
    }
    
    ///This yields the same results as the function in UITextView, though I'm not entirely sure what this function is for or why (why doesn't it at least extend to the end of a non-decomposable glyph?)
    func characterRangeByExtendingIAPosition(_ position: IATextPosition, inDirection direction: UITextLayoutDirection) -> IATextRange? {
        guard let result = tokenizer.rangeEnclosingPosition(position, with: .character, inDirection: direction.rawValue) as? IATextRange else {fatalError()}
        return result
//        if direction == .left {
//            //return IATextRange(start: position.positionWithOffset(-1),end: position)
//        } else {
//            //return IATextRange(start: position,end: position.positionWithOffset(1))
//        }
    }
    
    //    func baseWritingDirectionForIAPosition(position: IATextPosition, inDirection direction: UITextStorageDirection) -> UITextWritingDirection {}
    //    public func iaSetBaseWritingDirection(writingDirection: UITextWritingDirection, forRange range: IATextRange) {
    //    }
    
    
    //MARK: IA geometry testing
    
    func firstRectForIARange(_ range: IATextRange) -> CGRect {
        var actualRange = NSRange()
        topTV.layoutManager.glyphRange(forCharacterRange: range.nsrange(inIAString: iaString), actualCharacterRange: &actualRange)
        var firstRect = CGRect.zero
        topTV.layoutManager.enumerateEnclosingRects(forGlyphRange: actualRange, withinSelectedGlyphRange: NSMakeRange(NSNotFound, 0), in: topTV.textContainer) { (rect, stop) in
            firstRect = rect
            stop.initialize(to: true)
        }
        return self.convert(firstRect, from: topTV)
    }
    
    ///Note: This assumes forward layout direction with left-to-right writing. Caret width is fixed at 2 points
    func caretRectForIAPosition(_ position: IATextPosition) -> CGRect {
        //TODO: Update this to handle other text directions?
        return caretRectForIntPosition(position.utf16Position(inIAString: iaString))
    }
    
    /// Writing Direction and isVertical are hardcoded in this to .Natural and false, respectively.
    func iaSelectionRectsForRange(_ range: IATextRange) -> [IATextSelectionRect]{
        //TODO: Update this to handle other text directions?
        return selectionRectsForIntRange(range.range(inIAString: iaString))
    }
    
    ///Yields the character index of the following glyph if the point is more than halfway towards the far side of the glyph. Returns the IATextPostion object.
    func closestIAPositionToPoint(_ point:CGPoint)->IATextPosition {
        let convertedPoint = self.convert(point, to: topTV)
        var fraction:CGFloat = 0
        let glyphIndex = topTV.layoutManager.glyphIndex(for: convertedPoint, in: topTV.textContainer, fractionOfDistanceThroughGlyph: &fraction )
        if fraction < 0.5 {
            let charIndex = topTV.layoutManager.characterIndexForGlyph(at: glyphIndex)
            return IATextPosition(utf16Location:charIndex, iaString:iaString)
        } else {
            let charIndex = topTV.layoutManager.characterIndexForGlyph(at: glyphIndex + 1)
            return IATextPosition(utf16Location:charIndex, iaString:iaString)
        }
    }
    
    func closestIAPositionToPoint(_ point: CGPoint, withinRange range: IATextRange) -> IATextPosition {
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
    func characterIATextRangeAtPoint(_ point: CGPoint)->IATextRange {
        let convertedPoint = self.convert(point, to: topTV)
        var fraction:CGFloat = 0
        let glyphIndex = topTV.layoutManager.glyphIndex(for: convertedPoint, in: topTV.textContainer, fractionOfDistanceThroughGlyph: &fraction )
        
        let startIndex = topTV.layoutManager.characterIndexForGlyph(at: glyphIndex)
        let endIndex = topTV.layoutManager.characterIndexForGlyph(at: glyphIndex + 1)
        return IATextRange(range: startIndex..<endIndex, iaString:iaString)
    }
    
    ///Returns the next boundary after the position unless the position is itself a boundary in which case it returns itself
    func nextBoundaryIncludingOrAfterIAPosition(_ position:IATextPosition)->IATextPosition{
        if position.position == 0 {
            return position
        } else if position == endOfDocument {
            return position
        } else if tokenizer.isPosition(position, atBoundary: .word, inDirection: 1) {
            return position
        } else if let newPos = tokenizer.position(from: position, toBoundary: .word, inDirection: 0) as? IATextPosition{
            return newPos
        } else {
            return endOfDocument as! IATextPosition
        }
        
    }
    
}
