//
//  ThinTextView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/13/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


///ThinTextView is a basic implementation of the NSLayoutManager based TextKit components (as is used in UITextView) but without UITextInput support or all of the private api stuff which makes UITextView a pain to subclass. Since this is intended to be embedded in a composite view it's very bare bones with options and accessors. It has some minor tweaks to accomodate thumbnail sizing in the IAKit
final public class ThinTextView:UIView, NSLayoutManagerDelegate, NSTextStorageDelegate {
    
    let textContainer:IATextContainer
    let layoutManager:NSLayoutManager
    let textStorage:NSTextStorage
    var thumbSize:IAThumbSize {
        get{return textContainer.preferedThumbSize}
        set{textContainer.preferedThumbSize = newValue}
    }
    
    ///The intrinsicContentSize of the view will be calculated against this if set.
    var preferedMaxLayoutWidth:CGFloat? {
        didSet{if oldValue != preferedMaxLayoutWidth {
                invalidateIntrinsicContentSize()
            }}
    }
    
    ///If true (as in the case of the bottomTV of the IAComposite views) then this view does minimal sizing calculations of its own and has no intrinsicContentSize.
    var thinTVIsSlave:Bool = false
    
    ///systemLayoutSizeFittingSize sets this true so that didCompleteLayoutForTextContainer doesn't redraw the layer while other sizing calculations are in progress.
    private var isCalculatingSize:Bool = false
    ///When calling systemLayoutSizeFittingSize with empty textStorage, the layout engine will be provided with an empty character in this font size for the purposes of calculating its needed size. This lets dynamic resizing cells built around ThinTextView start with the desired size.
    var sizeForFontWhenEmpty:UIFont? = UIFont.systemFontOfSize(20)
    
    private var cachedICS:CGSize?
    
    public override init(frame: CGRect) {
        textContainer = IATextContainer()
        layoutManager = NSLayoutManager()
        textStorage = NSTextStorage()
        super.init(frame: frame)
        setupSTV()
    }
    
    public override func invalidateIntrinsicContentSize() {
        cachedICS = nil
        super.invalidateIntrinsicContentSize()
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
        //textContainer.size = self.bounds.size
        textContainer.heightTracksTextView = false
        textContainer.widthTracksTextView = true
        textContainer.size = CGSizeMake(self.bounds.size.width, 10000000.0)
        layoutManager.delegate = self
        textStorage.delegate = self
        textContainer.lineBreakMode = .ByWordWrapping
    }
    
    //Doesn't get called in normal IA stack (frame-didSet gets called instead) but should be included in case thin viewer is used elsewhere
    public override var bounds: CGRect {
        didSet{
            if textContainer.size != self.bounds.size && textContainer.heightTracksTextView && textContainer.widthTracksTextView{
                textContainer.size = self.bounds.size
            } else if textContainer.heightTracksTextView && textContainer.size.height != self.bounds.height {
                textContainer.size.height = self.bounds.height
            } else if textContainer.widthTracksTextView && textContainer.size.width != self.bounds.width {
                textContainer.size.width = self.bounds.width
            }
        }
    }

    public override var frame: CGRect {
        didSet{
            if textContainer.size != self.bounds.size && textContainer.heightTracksTextView && textContainer.widthTracksTextView{
                textContainer.size = self.bounds.size
            } else if textContainer.heightTracksTextView && textContainer.size.height != self.bounds.height {
                textContainer.size.height = self.bounds.height
            } else if textContainer.widthTracksTextView && textContainer.size.width != self.bounds.width {
                textContainer.size.width = self.bounds.width
            }
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
        if isCalculatingSize == false {
            self.setNeedsDisplay()
        }
    }
    
//    public func textStorage(textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
//        //if animating opacity then we don't want to draw selection rects on the same layer
//    }
    
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
    
    ///This performs text layout as need to fit the size. This will ignore preferedMaxLayoutWidth
    public override func sizeThatFits(size: CGSize) -> CGSize {
        let useEmptyAttString = textStorage.length == 0 && sizeForFontWhenEmpty != nil
        let currentTCSize = textContainer.size
        isCalculatingSize = true
        if useEmptyAttString {
            textStorage.beginEditing()
            textStorage.replaceCharactersInRange(NSMakeRange(0,0), withString: "\u{200B}")
            textStorage.setAttributes([NSFontAttributeName:sizeForFontWhenEmpty!], range: NSMakeRange(0,1))
            textStorage.endEditing()
        }
        textContainer.size = size
        let result = layoutManager.usedRectForTextContainer(textContainer).size
        if useEmptyAttString {
            textStorage.replaceCharactersInRange(NSMakeRange(0,1), withString: "")
        }
        textContainer.size = currentTCSize
        isCalculatingSize = false
        return result
    }
    
    public override func intrinsicContentSize() -> CGSize {
        guard thinTVIsSlave == false else {return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric)}
        guard cachedICS == nil else {return cachedICS!}
        if let pmlw = preferedMaxLayoutWidth {
            var ics = sizeThatFits(CGSizeMake(floor(pmlw), 1000000))
            ics.height = ceil(ics.height)
            ics.width = ceil(ics.width)
            cachedICS = ics
            return ics
        } else if self.bounds.size == CGSizeZero {
            //let s = systemLayoutSizeFittingSize(CGSizeMake(10000000, 1000000))
            var ics = sizeThatFits(CGSizeMake(10000000, 1000000))
            ics.height = ceil(ics.height)
            ics.width = ceil(ics.width)
            cachedICS = ics
            return ics
        } else {
            let gr = layoutManager.glyphRangeForTextContainer(self.textContainer)
            var ics = layoutManager.boundingRectForGlyphRange(gr, inTextContainer: textContainer).size
            ics.height = ceil(ics.height)
            ics.width = ceil(ics.width)
            cachedICS = ics
            return ics
        }
    }
    
}


