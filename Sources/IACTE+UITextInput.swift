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
    
    public func insertText(_ text: String) {
        guard selectedRange != nil else {print("insertText called while selectedRange is nil"); return}
        let replacement = IAString(text: text, intensity: currentIntensity, attributes: baseAttributes)
        replaceIAStringRange(replacement, range: selectedRange!)
    }
    
    public func deleteBackward() {
        guard let sr = selectedRange else {return}
        if sr.isEmpty {
            if sr.lowerBound > 0 {
                if let predecessorIndex = tokenizer.position(from: selectedTextRange!.start, toBoundary: UITextGranularity.character, inDirection: UITextStorageDirection.backward.rawValue) {
                    let start = offset(from: self.beginningOfDocument, to: predecessorIndex)
                    let delRange = start..<sr.lowerBound
                    deleteIAStringRange(delRange)
                } else {
                    print("index matching error in deleteBackwards when tring to find the index for \(sr.lowerBound)")
                }
            } else {
                return
            }
        } else {
            deleteIAStringRange(sr)
        }
        //updateSelectionIndicators()
    }
    
    public var hasText : Bool {
        guard iaString != nil else {return false}
        return !(iaString!.text.isEmpty)
    }
    
    
    //MARK:- UITextInput Functions
    
    public func text(in range: UITextRange) -> String? {
        guard let stringRange = (range as? IATextRange)?.stringRange(string: iaString.text) else {
            return nil
        }
        return iaString.text.substring(with: stringRange)
    }
    
    public func replace(_ range: UITextRange, withText text: String) {
        guard let iaRange = (range as? IATextRange) else {print("UITextInput.replaceRange received non IATextRange as a parameter"); return}
        let replacement = IAString(text: text, intensity: currentIntensity, attributes: baseAttributes)
        replaceIAStringRange(replacement, range: iaRange.range(inIAString:iaString))
    }

    
    public func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
        handleInconsistancy("setMarkedText not properly implemented")
    }
    
    public func unmarkText() {
        markedRange = nil
    }
    
    //MARK: Ranging and positioning
    
    public func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
        guard let fromPosition = (fromPosition as? IATextPosition), let toPosition = (toPosition as? IATextPosition) else {print("UITextInput.textRangeFromPosition received non IATextPositions as a parameters"); return nil}
        return iaTextRangeFromPosition(fromPosition, toPosition: toPosition)
    }
    
    ///Uses character offset, not utf16 offset
    public func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
        guard let position = (position as? IATextPosition) else {print("UITextInput.positionFromPosition received non IATextPosition as a parameters"); return nil}
        return iaPositionFromPosition(position, offset: offset)
    }
    
    public func position(from position: UITextPosition, in direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
        guard let position = (position as? IATextPosition) else {print("UITextInput.positionFromPosition received non IATextPosition as a parameters"); return nil}
        ////guard direction == .Right else {print("positionFromPosition: receive layout direction of \(direction), rather than .Right (raw == 2) as expected"); return nil}
        switch direction {
        case .right:
            return iaPositionFromPosition(position, offset: offset)
        case .left:
            return iaPositionFromPosition(position, offset: -offset)
        case .up:
            //same result for any offset value
            let gi = topTV.layoutManager.glyphIndexForCharacter(at: position.position)
            let br = topTV.layoutManager.boundingRect(forGlyphRange: NSMakeRange(gi, 0), in: topTV.textContainer)
            let higherPoint = CGPoint(x: br.origin.x, y: br.origin.y - 0.5 * br.height)
            return closestIAPositionToPoint(higherPoint)
        case .down:
            //same result for any offset value
            let gi = topTV.layoutManager.glyphIndexForCharacter(at: position.position)
            let br = topTV.layoutManager.boundingRect(forGlyphRange: NSMakeRange(gi, 0), in: topTV.textContainer)
            let lowerPoint = CGPoint(x: br.origin.x, y: br.origin.y + 1.5 * br.height)
            return closestIAPositionToPoint(lowerPoint) 
        }
    }
    
    public func compare(_ position: UITextPosition, to other: UITextPosition) -> ComparisonResult {
        guard let position = (position as? IATextPosition), let other = (other as? IATextPosition) else {fatalError("UITextInput.comparePosition received non IATextPositions as a parameters")}
        return compareIAPosition(position, toPosition: other)
    }
    
    public func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
        guard let from = (from as? IATextPosition), let to = (toPosition as? IATextPosition) else {fatalError("UITextInput.comparePosition received non IATextPositions as a parameters")}
        return offsetFromIAPosition(from, toPosition: to)
    }
    
    public func position(within range: UITextRange, farthestIn direction: UITextLayoutDirection) -> UITextPosition? {
        guard let range = (range as? IATextRange) else {print("UITextInput.positionWithinRange received non IATextRange as a parameter: returning nil"); return nil}
        return iaPositionWithinRange(range, farthestInDirection: direction)
    }
    
    public func characterRange(byExtending position: UITextPosition, in direction: UITextLayoutDirection) -> UITextRange? {
        guard let position = (position as? IATextPosition) else {handleInconsistancy("UITextInput.characterRangeByExtendingPosition received non IATextPositions as a parameters"); return nil}
        return characterRangeByExtendingIAPosition(position, inDirection: direction)
    }
    
    public func baseWritingDirection(for position: UITextPosition, in direction: UITextStorageDirection) -> UITextWritingDirection {
        return UITextWritingDirection.leftToRight
    }
    public func setBaseWritingDirection(_ writingDirection: UITextWritingDirection, for range: UITextRange) {
        if writingDirection == .rightToLeft {
            print("setBaseWritingDirection: received baseWriting direction rightToLeft. Ignoring.")
        }
    }
    
        
    //MARK: Geometry and hit testing
    
    public func firstRect(for range: UITextRange) -> CGRect {
        guard let range = (range as? IATextRange) else {print("UITextInput.firstRectForRange received non IATextRange as a parameter: returning CGRectZero"); return CGRect.zero}
        return firstRectForIARange(range)
    }
    
    ///Note: This assumes forward layout direction with left-to-right writing.
    public func caretRect(for position: UITextPosition) -> CGRect {
        guard let position = (position as? IATextPosition) else {fatalError("UITextInput.caretRectForPosition received non IATextPosition as a parameters")}
        return caretRectForIAPosition(position)
    }
    
    ///Yields the character index of the following glyph if the point is more than halfway towards the far side of the glyph. This utilizes the primitive of closestIAPositionToPoint
    public func closestPosition(to point: CGPoint) -> UITextPosition? {
        return closestIAPositionToPoint(point)
    }
    
    public func closestPosition(to point: CGPoint, within range: UITextRange) -> UITextPosition? {
        guard let range = (range as? IATextRange) else {print("UITextInput.closestPositionToPoint received non IATextRange as a parameter: returning nil"); return nil}
        return closestIAPositionToPoint(point, withinRange: range)
    }
    
    /// Writing Direction and isVertical are hardcoded in this to .Natural and false, respectively. Uses iaSelectionRectsForRange.
    public func selectionRects(for range: UITextRange) -> [Any] {
        guard let range = (range as? IATextRange) else {print("UITextInput.selectionRectsForRange received non IATextRange as a parameter: returning CGRectZero"); return []}
        return iaSelectionRectsForRange(range)
    }
    
    public func characterRange(at point: CGPoint) -> UITextRange? {
        return characterIATextRangeAtPoint(point)
    }

    public var textInputView: UIView {return self}
    
}




