//
//  ThinTextView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/13/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


///ThinTextView is a basic implementation of the NSLayoutManager based TextKit components (as is used in UITextView) but without UITextInput support or all of the private api stuff which makes UITextView a pain to subclass. Since this is intended to be embedded in a composite view it's very bare bones with options and accessors. It has some minor tweaks to accomodate thumbnail sizing in the IAKit
public class ThinTextView:UIView, NSLayoutManagerDelegate, NSTextStorageDelegate {
    
    let textContainer:IATextContainer
    let layoutManager:NSLayoutManager
    let textStorage:NSTextStorage
    var thumbSize:ThumbSize {
        get{return textContainer.preferedThumbSize}
        set{textContainer.preferedThumbSize = newValue}
    }
    
    public override init(frame: CGRect) {
        textContainer = IATextContainer()
        layoutManager = NSLayoutManager()
        textStorage = NSTextStorage()
        super.init(frame: frame)
        setupSTV()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        textContainer = (aDecoder.decodeObjectForKey("textContainer") as? IATextContainer) ?? IATextContainer()
        layoutManager = (aDecoder.decodeObjectForKey("layoutManager") as? NSLayoutManager) ?? NSLayoutManager()
        textStorage = (aDecoder.decodeObjectForKey("textStorage") as? NSTextStorage) ?? NSTextStorage()
        super.init(coder: aDecoder)
        setupSTV()
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(textContainer, forKey: "textContainer")
        aCoder.encodeObject(layoutManager, forKey: "layoutManager")
        aCoder.encodeObject(textStorage, forKey: "textStorage")
    }
    
    func setupSTV(){
        textStorage.addLayoutManager(layoutManager)
        textContainer.replaceLayoutManager(layoutManager)
        textContainer.size = self.bounds.size
        layoutManager.delegate = self
        textStorage.delegate = self
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if textContainer.size != self.bounds.size {
            textContainer.size = self.bounds.size
        }
        
        
    }
    
    
    public override func drawRect(rect: CGRect) {
        if let bgColor = self.backgroundColor {
            bgColor.setFill()
            UIRectFill(rect)
        }
        let glyphRange = layoutManager.glyphRangeForTextContainer(textContainer)
        layoutManager.drawBackgroundForGlyphRange(glyphRange, atPoint: self.bounds.origin)
        layoutManager.drawGlyphsForGlyphRange(glyphRange, atPoint: self.bounds.origin)
    }
    
    public func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        //could put drawing of underlayer here
        self.setNeedsDisplay()
    }
    
//    public func layoutManagerDidInvalidateLayout(sender: NSLayoutManager) {
//        print("ThinTextView: layoutManagerDidInvalidateLayout called but unimplemented")
//    }
    
    public func textStorage(textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        //if animating opacity then we don't want to draw selection rects on the same layer
    }
    
    ///Convenience function which returns the character index of the character at the provided point. If the point is not in a boundingRect of a glyph then this returns nil. The point is relative to this view.
    func characterIndexAtPoint(point:CGPoint)->Int?{
        let glyphIndex = layoutManager.glyphIndexForPoint(point, inTextContainer: self.textContainer)
        let boundingRect = layoutManager.boundingRectForGlyphRange(NSMakeRange(glyphIndex, 1), inTextContainer: self.textContainer)
        if boundingRect.contains(point) {
            return layoutManager.characterIndexForGlyphAtIndex(glyphIndex)
        } else {
            return nil
        }
    }
    
    public override func systemLayoutSizeFittingSize(targetSize: CGSize) -> CGSize {
        print("ThinTextView: warning: systemLayoutSizeFittingSize may not be properly implemented. Consider preventing layoutmanager from redrawing during this interval (possibly via the delegate?)")
        let currentTCSize = textContainer.size
        textContainer.size = targetSize
        let result = layoutManager.usedRectForTextContainer(textContainer).size
        textContainer.size = currentTCSize
        return result
    }
    
    
}

///The IATextContainer provides means for requesting standard thumbnail sizes when the layout manager calls the IATextAttachment's NSTextAttachmentContainer protocol functions
public class IATextContainer:NSTextContainer {
    ///This flag can be used to indicate to the IATextAttachments that they should return nil from imageForBounds because the image will be drawn by in another layer.
    var shouldPresentEmptyImageContainers:Bool = true
    var preferedThumbSize:ThumbSize = .Medium {
        didSet{
            if preferedThumbSize != oldValue {layoutManager?.textContainerChangedGeometry(self)}
        }
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(preferedThumbSize.rawValue, forKey: "thumbsize")
        aCoder.encodeObject(shouldPresentEmptyImageContainers, forKey: "shouldPresentEmptyImages")
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        if let tsname = coder.decodeObjectForKey("thumbsize") as? String {
            if let ts = ThumbSize(rawValue: tsname) {
                preferedThumbSize = ts
            }
        }
        if let emptyImages = coder.decodeObjectForKey("shouldPresentEmptyImages") as? Bool {
            shouldPresentEmptyImageContainers = emptyImages
        }
    }
    
    init(){
        super.init(size:CGSizeZero)
    }
    
    override init(size:CGSize){
        super.init(size: size)
    }
}

