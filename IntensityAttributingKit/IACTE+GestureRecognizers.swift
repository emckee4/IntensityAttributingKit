//
//  IACTE+GestureRecognizers.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 5/3/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation



extension IACompositeTextEditor: UIGestureRecognizerDelegate {
    
    ///Single taps make the textEditor first responder when it isn't already. It will move the cursor to the nearest word boundary or, if the new selection is already at/encompassing that boundary, toggle the selection menu.
    @objc func singleTapGestureUpdate(sender:UITapGestureRecognizer!){
        guard sender.state == .Ended else {return}
        let becomingFirstResponder = !self.isFirstResponder()
        if becomingFirstResponder {
            becomeFirstResponder()
        }
        let loc = sender.locationInView(self)
        let position = closestIAPositionToPoint(loc)
        
        if selectedIATextRange == nil {
            //let closestBoundary = closestWordOrDocBoundaryPositionToIAPosition(position)
            let closestBoundary = nextBoundaryIncludingOrAfterIAPosition(position)
            selectedRange = (closestBoundary.position)..<(closestBoundary.position)
        } else if selectedIATextRange!.empty {
            ///We need to calculate the appropriate word boundary to determine where the caret will be and whether this is the same or different from the current selection
            let closestBoundary = nextBoundaryIncludingOrAfterIAPosition(position)
            if selectedRange!.startIndex == closestBoundary.position && !becomingFirstResponder && menu.menuVisible == false{
                presentMenu(firstRectForIARange(selectedIATextRange!))//CGRect(origin: loc, size: CGSizeMake(10, 10)))
            } else {
                menu.menuVisible = false
                selectedRange = closestBoundary.position..<closestBoundary.position
            }
        } else { //non-empty selection range
            if selectedIATextRange!.contains(position) {
                presentMenu(firstRectForIARange(selectedIATextRange!))
            } else {
                //let closestBoundary = closestWordOrDocBoundaryPositionToIAPosition(position)
                let closestBoundary = nextBoundaryIncludingOrAfterIAPosition(position)
                selectedRange = (closestBoundary.position)..<(closestBoundary.position)
            }
        }
    }
    
    ///Double tap gesture will select the range of the word under the tap
    @objc func doubleTapGestureUpdate(sender:UITapGestureRecognizer!){
        guard sender.state == .Ended else {return}
        let location = sender.locationInView(self)
        let iaPos = closestIAPositionToPoint(location)
        let direction = UITextStorageDirection.Forward.rawValue + UITextLayoutDirection.Right.rawValue
        if selectedRange == nil || selectedRange!.isEmpty || !selectedIATextRange!.contains(iaPos){
            //find word and select its range
            let newRange = tokenizer.rangeEnclosingPosition(iaPos, withGranularity: .Word, inDirection: direction)
            selectedTextRange = newRange
            presentMenu(CGRect(origin: location, size: CGSizeMake(10, 10)))
        } else {
            //highlight more
            selectAll(sender)
            presentMenu(CGRect(origin: location, size: CGSizeMake(10, 10)))
        }
    }
    
    ///Longpresses trigger the presentation of the IAMagnifyingLoup which allows fine grained dragging of the edge of a selection range or the caret if no non-empty range was previously selected.
    @objc func longPressGestureUpdate(sender:UILongPressGestureRecognizer!){
        let location = sender.locationInView(self)
        let iaPos = closestIAPositionToPoint(location)
        
        guard sender.state == .Began || sender.state == .Changed else {
            longPressDragStartingPoint = nil
            longPressDragStartingSelectionRect = nil
            magnifyingLoup.hidden = true;
            self.startAnimation();
            return
        }
        self.stopAnimation()
        
        guard selectedRange?.isEmpty == false else { //covering cases where selectedRange is empty or nil...
            selectedRange = iaPos.position..<iaPos.position
            magnifyingLoup.magnifyAtPoint(location)
            return
        }
        //so selected range is non-empty. 
        let selectionRects = iaSelectionRectsForRange(selectedIATextRange!)
        guard selectionRects.isEmpty == false else {return}

        guard let startSR = selectionRects.filter({$0.containsStart == true}).first, endSR = selectionRects.filter({$0.containsEnd == true}).first else {
            selectedRange = iaPos.position..<iaPos.position
            magnifyingLoup.magnifyAtPoint(location)
            return
        }
        
        
        if sender.state == .Began {
            let startDist = startSR.rect.distanceToPoint(location)
            let endDist = endSR.rect.distanceToPoint(location)
            if startDist < 20.0 && startDist < endDist {
                longPressDragStartingPoint = location
                longPressDragStartingSelectionRect = startSR
                
                
            } else if endDist < 20.0 && endDist < startDist {
                longPressDragStartingPoint = location
                longPressDragStartingSelectionRect = endSR
                
            } else {
                selectedRange = iaPos.position..<iaPos.position
            }
        } else { //case: .Changed (should include some .Ended when selection is non empty)
            if selectedRange!.isEmpty == false && longPressDragStartingSelectionRect != nil && longPressDragStartingPoint != nil {
                if longPressDragStartingSelectionRect!.containsStart {
                    let xAdjustment:CGFloat = longPressDragStartingPoint!.x - longPressDragStartingSelectionRect!.rect.origin.x
                    let adjustedLocation = CGPoint(x: location.x - xAdjustment, y: location.y)
                    let newPos = closestIAPositionToPoint(adjustedLocation)
                    if newPos.position < selectedRange!.endIndex {
                        selectedRange = newPos.position..<selectedRange!.endIndex
                    }
                } else { // longPressDragStartingSelectionRect!.containsEnd will be true
                    let xAdjustment:CGFloat = longPressDragStartingPoint!.x - longPressDragStartingSelectionRect!.rect.origin.x
                    let adjustedLocation = CGPoint(x: location.x - xAdjustment, y: location.y)
                    let newPos = closestIAPositionToPoint(adjustedLocation)
                    if newPos.position > selectedRange!.startIndex {
                        selectedRange = selectedRange!.startIndex..<newPos.position
                    }
                    
                    
                }
            } else {
                selectedRange = iaPos.position..<iaPos.position
            }
        }
        magnifyingLoup.magnifyAtPoint(location)
    }


    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapGR && (otherGestureRecognizer == doubleTapGR || otherGestureRecognizer == longPressGR) && self.isFirstResponder(){
            return true
        }
        return false
    }
    
    
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.isFirstResponder() {
            return true
        } else if gestureRecognizer == tapGR {
            return true
        } else {
            return false
        }
    }
    
    
}