//
//  IATextSelectionRect.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/28/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

///A custom subclass of the UITextSelectionRect is needed in order to more fully reimplement the UITextInput protocol.
open class IATextSelectionRect: UITextSelectionRect {
    
    fileprivate let _rect: CGRect
    open override var rect: CGRect {
        return _rect
    }
    fileprivate let _writingDirection:UITextWritingDirection
    open override var writingDirection: UITextWritingDirection{
        return _writingDirection
    }

    fileprivate let _isVertical: Bool
    open override var isVertical: Bool {
        return _isVertical
    }
    
    fileprivate let _containsStart:Bool
    open override var containsStart: Bool {
        return _containsStart
    }
    
    fileprivate let _containsEnd:Bool
    open override var containsEnd: Bool {
        return _containsEnd
    }
    
    
    
    public init(rect:CGRect, writingDirection:UITextWritingDirection = .natural, isVertical:Bool = false, containsStart:Bool, containsEnd:Bool) {
        _rect = rect
        _writingDirection = writingDirection
        _isVertical = isVertical
        _containsStart = containsStart
        _containsEnd = containsEnd
    }
    ///Takes an array of raw selection rects, ordered first to last, and returns an array IATextSelectionRects with first and last components set if markEnds is true.
    class func generateSelectionArray(_ rects:[CGRect], writingDirection:UITextWritingDirection = .leftToRight, isVertical:Bool = false, markEnds:Bool = true)->[IATextSelectionRect]{
        guard rects.isEmpty == false else {return []}
        var selectionRects = rects.map({(rect:CGRect)->IATextSelectionRect in
            return IATextSelectionRect(rect: rect, writingDirection: writingDirection, isVertical: isVertical,
                containsStart: false ,
                containsEnd: false
            )
        })
        if markEnds == true {
            let startRect = CGRect(x: floor(rects.first!.origin.x), y: rects.first!.origin.y, width: 0, height: rects.first!.height + 1.0)
            selectionRects.append(IATextSelectionRect(rect: startRect, writingDirection: writingDirection, isVertical: isVertical, containsStart: true, containsEnd: false))
            
            let endRect = CGRect(x: ceil(rects.last!.origin.x + rects.last!.width), y: rects.last!.origin.y - 1.0, width: 0, height: rects.last!.height + 1.0)
            selectionRects.append(IATextSelectionRect(rect: endRect, writingDirection: writingDirection, isVertical: isVertical, containsStart: false, containsEnd: true))
        }
        return selectionRects
    }
    
}



