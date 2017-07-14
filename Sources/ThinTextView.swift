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
    fileprivate var isCalculatingSize:Bool = false
    ///When calling systemLayoutSizeFittingSize with empty textStorage, the layout engine will be provided with an empty character in this font size for the purposes of calculating its needed size. This lets dynamic resizing cells built around ThinTextView start with the desired size.
    var sizeForFontWhenEmpty:UIFont? = UIFont.systemFont(ofSize: 20)
    
    fileprivate var cachedICS:CGSize?
    
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
        textContainer = (aDecoder.decodeObject(forKey: "textContainer") as? IATextContainer) ?? IATextContainer()
        layoutManager = (aDecoder.decodeObject(forKey: "layoutManager") as? NSLayoutManager) ?? NSLayoutManager()
        textStorage = (aDecoder.decodeObject(forKey: "textStorage") as? NSTextStorage) ?? NSTextStorage()
        super.init(coder: aDecoder)
        setupSTV()
    }
    
    public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(textContainer, forKey: "textContainer")
        aCoder.encode(layoutManager, forKey: "layoutManager")
        aCoder.encode(textStorage, forKey: "textStorage")
    }
    
    func setupSTV(){
        textStorage.addLayoutManager(layoutManager)
        textContainer.replaceLayoutManager(layoutManager)
        //textContainer.size = self.bounds.size
        textContainer.heightTracksTextView = false
        textContainer.widthTracksTextView = true
        textContainer.size = CGSize(width: self.bounds.size.width, height: 10000000.0)
        layoutManager.delegate = self
        textStorage.delegate = self
        textContainer.lineBreakMode = .byWordWrapping
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
    
    public override func draw(_ rect: CGRect) {
        if let bgColor = self.backgroundColor {
            bgColor.setFill()
            UIRectFill(rect)
        }
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        layoutManager.drawBackground(forGlyphRange: glyphRange, at: self.bounds.origin)
        layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: self.bounds.origin)
    }
    
    public func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        if isCalculatingSize == false {
            self.setNeedsDisplay()
        }
    }
    
//    public func textStorage(textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
//        //if animating opacity then we don't want to draw selection rects on the same layer
//    }
    
    ///Convenience function which returns the character index of the character at the provided point. If the point is not in a boundingRect of a glyph then this returns nil. The point is relative to this view.
    func characterIndexAtPoint(_ point:CGPoint)->Int?{
        let glyphIndex = layoutManager.glyphIndex(for: point, in: self.textContainer)
        let boundingRect = layoutManager.boundingRect(forGlyphRange: NSMakeRange(glyphIndex, 1), in: self.textContainer)
        if boundingRect.contains(point) {
            return layoutManager.characterIndexForGlyph(at: glyphIndex)
        } else {
            return nil
        }
    }
    
    ///This performs text layout as need to fit the size. This will ignore preferedMaxLayoutWidth
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let useEmptyAttString = textStorage.length == 0 && sizeForFontWhenEmpty != nil
        let currentTCSize = textContainer.size
        isCalculatingSize = true
        if useEmptyAttString {
            textStorage.beginEditing()
            textStorage.replaceCharacters(in: NSMakeRange(0,0), with: "\u{200B}")
            textStorage.setAttributes([NSFontAttributeName:sizeForFontWhenEmpty!], range: NSMakeRange(0,1))
            textStorage.endEditing()
        }
        textContainer.size = size
        let result = layoutManager.usedRect(for: textContainer).size
        if useEmptyAttString {
            textStorage.replaceCharacters(in: NSMakeRange(0,1), with: "")
        }
        textContainer.size = currentTCSize
        isCalculatingSize = false
        return result
    }
    
    public override var intrinsicContentSize : CGSize {
        guard thinTVIsSlave == false else {return CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)}
        guard cachedICS == nil else {return cachedICS!}
        if let pmlw = preferedMaxLayoutWidth {
            var ics = sizeThatFits(CGSize(width: floor(pmlw), height: 1000000))
            ics.height = ceil(ics.height)
            ics.width = ceil(ics.width)
            cachedICS = ics
            return ics
        } else if self.bounds.size == CGSize.zero {
            //let s = systemLayoutSizeFittingSize(CGSizeMake(10000000, 1000000))
            var ics = sizeThatFits(CGSize(width: 10000000, height: 1000000))
            ics.height = ceil(ics.height)
            ics.width = ceil(ics.width)
            cachedICS = ics
            return ics
        } else {
            let gr = layoutManager.glyphRange(for: self.textContainer)
            var ics = layoutManager.boundingRect(forGlyphRange: gr, in: textContainer).size
            ics.height = ceil(ics.height)
            ics.width = ceil(ics.width)
            cachedICS = ics
            return ics
        }
    }
    
}


