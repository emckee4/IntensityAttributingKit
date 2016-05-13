//
//  IATextSelectionRect.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/28/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


public class IATextSelectionRect: UITextSelectionRect {
    
    private let _rect: CGRect
    public override var rect: CGRect {
        return _rect
    }
    private let _writingDirection:UITextWritingDirection
    public override var writingDirection: UITextWritingDirection{
        return _writingDirection
    }

    private let _isVertical: Bool
    public override var isVertical: Bool {
        return _isVertical
    }
    
    private let _containsStart:Bool
    public override var containsStart: Bool {
        return _containsStart
    }
    
    private let _containsEnd:Bool
    public override var containsEnd: Bool {
        return _containsEnd
    }
    
    
    
    public init(rect:CGRect, writingDirection:UITextWritingDirection = .Natural, isVertical:Bool = false, containsStart:Bool, containsEnd:Bool) {
        _rect = rect
        _writingDirection = writingDirection
        _isVertical = isVertical
        _containsStart = containsStart
        _containsEnd = containsEnd
    }
    ///Takes an array of raw selection rects, ordered first to last, and returns an array IATextSelectionRects with first and last components set if markEnds is true.
    class func generateSelectionArray(rects:[CGRect], writingDirection:UITextWritingDirection = .LeftToRight, isVertical:Bool = false, markEnds:Bool = true)->[IATextSelectionRect]{
        guard rects.isEmpty == false else {return []}
        var selectionRects = rects.map({(rect:CGRect)->IATextSelectionRect in
            return IATextSelectionRect(rect: rect, writingDirection: writingDirection, isVertical: isVertical,
                containsStart: false ,
                containsEnd: false
            )
        })
        if markEnds == true {
            let startRect = CGRectMake(floor(rects.first!.origin.x), rects.first!.origin.y, 0, rects.first!.height + 1.0)
            selectionRects.append(IATextSelectionRect(rect: startRect, writingDirection: writingDirection, isVertical: isVertical, containsStart: true, containsEnd: false))
            
            let endRect = CGRectMake(ceil(rects.last!.origin.x + rects.last!.width), rects.last!.origin.y - 1.0, 0, rects.last!.height + 1.0)
            selectionRects.append(IATextSelectionRect(rect: endRect, writingDirection: writingDirection, isVertical: isVertical, containsStart: false, containsEnd: true))
        }
        return selectionRects
    }
    
}

/*
 (50.509765625, 7.0, 244.490234375, 22.48046875) false false
 (5.0, 29.48046875, 81.685546875, 22.48046875) false false
 (50.0, 7.0, 0.0, 23.48046875) true false
 (87.0, 28.48046875, 0.0, 23.48046875) false true
 */


