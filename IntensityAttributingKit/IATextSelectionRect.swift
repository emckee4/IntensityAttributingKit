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
    class func generateSelectionArray(rects:[CGRect], writingDirection:UITextWritingDirection = .Natural, isVertical:Bool = false, markEnds:Bool = true)->[IATextSelectionRect]{
        return rects.enumerate().map({(i:Int, rect:CGRect)->IATextSelectionRect in
            return IATextSelectionRect(rect: rect, writingDirection: writingDirection, isVertical: isVertical,
                containsStart: (i == 0 && markEnds) ,
                containsEnd: (i == rects.count - 1 && markEnds)
            )
        })
    }
    
}
