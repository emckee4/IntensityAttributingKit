//
//  IACTE+GestureRecognizers.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 5/3/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation



extension IACompositeTextEditor: UIGestureRecognizerDelegate {
    
    
    @objc func singleTapGestureUpdate(sender:UITapGestureRecognizer!){
        guard sender.state == .Ended else {return}
        if !self.isFirstResponder() {
            becomeFirstResponder()
        }
        let loc = sender.locationInView(self)
        let position = closestIAPositionToPoint(loc)
        
        if let selectedIATR = selectedIATextRange where selectedIATR.contains(position) {
            let targetRect = CGRectMake(loc.x - 10, loc.y - 10, 20, 20)
            menu.setTargetRect(targetRect, inView: self)
            menu.setMenuVisible(true, animated: true)
        } else {
            selectedIATextRange = IATextRange(start: position, end: position)
        }
        
        
    }
    
    @objc func doubleTapGestureUpdate(sender:UITapGestureRecognizer!){
        guard sender.state == .Ended else {return}
        let location = sender.locationInView(self)
        let iaPos = closestIAPositionToPoint(location)
        let direction = UITextStorageDirection.Forward.rawValue + UITextLayoutDirection.Right.rawValue
        if selectedRange == nil || selectedRange!.isEmpty || !selectedIATextRange!.contains(iaPos){
            //find word and select its range
            let newRange = tokenizer.rangeEnclosingPosition(iaPos, withGranularity: .Word, inDirection: direction)
            selectedTextRange = newRange
        } else {
            //highlight more
            selectAll(sender)
        }
    }
    
    @objc func longPressGestureUpdate(sender:UILongPressGestureRecognizer!){
        let location = sender.locationInView(self)
        let iaPos = closestIAPositionToPoint(location)
        
        debugPrint("Long Press recognized: state:\(sender.state), pos: \(iaPos.position)")
        
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



    
//    @objc func loupPanGestureUpdate(sender:UIPanGestureRecognizer!){
//        //TODO: enable loup Pan
//        print("pan")
//    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapGR && (otherGestureRecognizer == doubleTapGR || otherGestureRecognizer == longPressGR) && self.isFirstResponder(){
            return true
        }
        return false
    }
    
    
//    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer == doubleTapGR && otherGestureRecognizer == longPressGR || gestureRecognizer == longPressGR && otherGestureRecognizer == doubleTapGR {
//            return true
//        } else {
//            return false
//        }
//    }
    
    
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