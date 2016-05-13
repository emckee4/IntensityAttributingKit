//
//  IACompositeBase.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/19/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


public class IACompositeBase:UIView {
    
    var containerView:UIView
    var selectionView:IASelectionView
    var topTV:ThinTextView
    var bottomTV:ThinTextView
    ///The imageLayer coordinate system is positioned to be the same as that of the textContainers. i.e. it's subject to the textContainerInset property.
    ///The imageLayer view holds the actual rendered textAttachments. This allows us to show them opaquely regardless of where the textViews are in their animation cycles. This also allows us to render these asynchronously if necessary.
    var imageLayer:UIView
    var imageLayerImageViews:[UIImageView] = []
    ///Use the setIAString function to set the value
    internal(set) public var iaString:IAString!

    //public weak var delegate:IATextViewDelegate?
    
    //var tapGestureRecognizer:UITapGestureRecognizer!
    
    public var selectable:Bool = false
    
    ///backing store for selectedRange. We use this so that we can change the selectedRange without calling an update when needed.
    var _selectedRange:Range<Int>?
    internal(set) public var selectedRange:Range<Int>? {
        get{return _selectedRange}
        set{
            let selectedRangeDidChange = _selectedRange != newValue
            _selectedRange = newValue
            if selectedRangeDidChange {
                selectedRangeChanged()
            }
        }
    }
    
    public var isAnimating:Bool {
        return (topTV.layer.animationForKey("opacity") != nil) || (bottomTV.layer.animationForKey("opacity") != nil)
    }
    
    public var thumbSizesForAttachments: ThumbSize = .Medium {
        didSet{
            topTV.thumbSize = thumbSizesForAttachments
            bottomTV.thumbSize = thumbSizesForAttachments
            if iaString.attachmentCount > 0 && thumbSizesForAttachments != oldValue {
                //trigger layout from scratch
                setIAString(iaString)
            }
        }
    }
    
    
    public var textContainerInset:UIEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0) {
        didSet {
            if textContainerInset != oldValue {
                setNeedsLayout() // layoutSubviews will update the imageLayer position
            }
        }
    }
    
    var menu:UIMenuController {
        return UIMenuController.sharedMenuController()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()   //should this be called before or after?
        //set frames for contained objects
        let frameWithInset = UIEdgeInsetsInsetRect(self.bounds, textContainerInset)
        containerView.frame = self.bounds
        selectionView.frame = self.bounds  //we use the full frame since we will be gettting selection rects (typically via UITextInput) in the coordinate space of the superview (the IATextView)
        topTV.frame = frameWithInset
        bottomTV.frame = frameWithInset
        imageLayer.frame = frameWithInset
        //TODO: If bounds have changed but content hasn't then we should try to move imageviews rather than reloading the images. Need to make this object a delegate of the topTV's layoutManager
        
    }
    
    
    
    func setupIATV(){
        //selectionView.userInteractionEnabled = false
        
        selectionView.backgroundColor = UIColor.clearColor()
        selectionView.hidden = true
        
        //topTV.userInteractionEnabled = false
        topTV.backgroundColor = UIColor.clearColor()
        topTV.textStorage.setAttributes([NSFontAttributeName:UIFont.systemFontOfSize(40)], range: NSMakeRange(0, 0))
        
        //bottomTV.userInteractionEnabled = false
        bottomTV.backgroundColor = UIColor.clearColor()
        bottomTV.hidden = true
        
        //imageLayer.userInteractionEnabled = false
        imageLayer.layer.drawsAsynchronously = true
        imageLayer.clipsToBounds = true
        imageLayer.hidden = true
        
        containerView.addSubview(imageLayer)
        containerView.addSubview(bottomTV)
        containerView.addSubview(topTV)
        containerView.addSubview(selectionView)
        self.addSubview(containerView)
        setupGestureRecognizers()
    }
    
    func setupGestureRecognizers(){
        
    }
    
    
    
    
    ///Prefered method for setting stored IAText for display. By default this assumes text has been prerendered and only needs bounds set on its images. If needsRendering is set as true then this will render according to whatever its included schemeName is.
    public func setIAString(iaString:IAString!){
        if iaString != nil {
            self.iaString = iaString
        } else {
            self.iaString = IAString()
        }
        
        let options = iaString.baseOptions.optionsWithOverridesApplied(IAKitPreferences.iaStringOverridingOptions)
        
        let willAnimate = options.animatesIfAvailable == true && options.renderScheme.isAnimatable
        
        //self.attributedText = self._iaString?.convertToNSAttributedString(withOptions: _renderOptions)
        
        
        let attStrings = self.iaString.convertToNSAttributedStringsForLayeredDisplay(withOverridingOptions: options)
        let attStringLength = attStrings.top.length
        topTV.textStorage.replaceCharactersInRange(NSMakeRange(0, topTV.textStorage.length), withAttributedString: attStrings.top)
        
        if attStrings.bottom?.length == attStringLength {
            bottomTV.hidden = false
            bottomTV.textStorage.replaceCharactersInRange(NSMakeRange(0, bottomTV.textStorage.length), withAttributedString: attStrings.bottom!)
        } else {
            bottomTV.hidden = true
        }
        
        
        //TODO: Need to figure out how to render attachments onto bottom layer (asynchronously ideally)
        
        if iaString.attachmentCount > imageLayerImageViews.count {
            for _ in 0..<(iaString.attachmentCount - imageLayerImageViews.count){
                let newImageView = UIImageView(frame: CGRectZero)
                newImageView.translatesAutoresizingMaskIntoConstraints = false
                imageLayerImageViews.append(newImageView)
                imageLayer.addSubview(newImageView)
            }
            
        }
        
        refreshImageLayer()
        
        
        //Start animation according to animation scheme if possible/desired
        if willAnimate {
            startAnimation()
        } else {
            stopAnimation()
        }
    }
    
    //Recalculates and redraws entire range of iaString, similar to what would happen calling setIAString(self.iaString) but keeps selection intact and may have optimizations (eventually). Typically called after changes in states that affect the display of the entire string, like changing the smoother or transformer (current values or global overrides).
    func rerenderIAString(){
        let currentSelection = selectedRange
        setIAString(iaString)
        selectedRange = currentSelection
        //TODO: only do as much work as required
    }
    
    func refreshImageLayer(){
        guard imageLayerImageViews.count >= iaString.attachmentCount else {fatalError("refreshImageLayer: not enough imageLayerImageViews for attachment count")}
        for (i ,locAttach) in iaString.attachments.enumerate() {
            let (location, attachment) = locAttach
            let attachRect = topTV.layoutManager.boundingRectForGlyphRange(NSMakeRange(location, 1), inTextContainer: topTV.textContainer)
            imageLayerImageViews[i].image = attachment.imageForThumbSize(self.thumbSizesForAttachments)
            imageLayerImageViews[i].hidden = false
            imageLayerImageViews[i].frame = attachRect
        }
        if iaString.attachmentCount < imageLayerImageViews.count {
            for i in (iaString.attachmentCount)..<(imageLayerImageViews.count){
                imageLayerImageViews[i].image = nil
                imageLayerImageViews[i].hidden = true
            }
        }
    }
    
    ///If bounds change but images do not need to be reloaded then this can be called as a more efficient alternative to refreshImageLayer.
    func repositionImageViews(){
        guard imageLayerImageViews.count >= iaString.attachmentCount else {fatalError("repositionImageViews: not enough imageLayerImageViews for attachment count")}
        for (i ,locAttach) in iaString.attachments.enumerate() {
            let (location, _) = locAttach
            let attachRect = topTV.layoutManager.boundingRectForGlyphRange(NSMakeRange(location, 1), inTextContainer: topTV.textContainer)
            imageLayerImageViews[i].frame = attachRect
        }
    }
    
//    ///The intrinsicContentSize incorporates insets if the topTV ics is non-zero
//    public override func intrinsicContentSize() -> CGSize {
//        let ics = topTV.intrinsicContentSize()
//        if ics == CGSizeZero {return CGSizeZero }
//        return CGSize(width: ics.width + textContainerInset.left + textContainerInset.right, height: ics.height + textContainerInset.top + textContainerInset.bottom)
//    }
    
    ///The systemLayoutSizeFittingSize doesn't incorporate insets if the topTV ics is non-zero
    public override func systemLayoutSizeFittingSize(targetSize: CGSize) -> CGSize {
        let insetHor = textContainerInset.left + textContainerInset.right
        let insetVert = textContainerInset.top + textContainerInset.bottom
        let sizeMinusInsets = CGSizeMake(targetSize.width - insetHor, targetSize.height - insetVert)
        let topTVSize = topTV.systemLayoutSizeFittingSize(sizeMinusInsets)
        return CGSizeMake(topTVSize.width + insetHor, topTVSize.height + insetVert)
    }
    
    
    
    
    public override init(frame: CGRect) {
        containerView = UIView(frame: frame)
        topTV = ThinTextView()
        bottomTV = ThinTextView()
        selectionView = IASelectionView()
        imageLayer = UIView()
        
        
        super.init(frame: frame)
        setupIATV()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        containerView = (aDecoder.decodeObjectForKey("containerView") as?  UIView) ?? UIView()
        topTV = (aDecoder.decodeObjectForKey("topTV") as?  ThinTextView) ?? ThinTextView()
        bottomTV = (aDecoder.decodeObjectForKey("bottomTV") as?  ThinTextView) ?? ThinTextView()
        selectionView = (aDecoder.decodeObjectForKey("selectionView") as?  IASelectionView) ?? IASelectionView()
        imageLayer = (aDecoder.decodeObjectForKey("imageLayer") as?  UIView) ?? UIView()
        super.init(coder: aDecoder)
        setupIATV()
        
        
        if let ts = ThumbSize(rawOptional: (aDecoder.decodeObjectForKey("thumbSizes") as? String)) {
            thumbSizesForAttachments = ts
        }
        if let insetArray = aDecoder.decodeObjectForKey("textContainerInsetArray") as? [CGFloat] where insetArray.count == 4 {
            self.textContainerInset = UIEdgeInsets(top: insetArray[0], left: insetArray[1], bottom: insetArray[2], right: insetArray[3])
        }
        if let iasArch = aDecoder.decodeObjectForKey("iaStringArchive") as? IAStringArchive {
            setIAString(iasArch.iaString)
        }
        if let selectableOption = aDecoder.decodeObjectForKey("selectable") as? Bool {
            self.selectable = selectableOption
        }
    }
    
    public convenience init(){
        self.init(frame:CGRectZero)
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(containerView, forKey: "containerView")
        aCoder.encodeObject(topTV, forKey: "topTV")
        aCoder.encodeObject(bottomTV, forKey: "bottomTV")
        aCoder.encodeObject(imageLayer, forKey: "imageLayer")
        aCoder.encodeObject(selectionView, forKey: "selectionView")
        
        
        //want thumbsize, insets, iaString, etc
        aCoder.encodeObject(thumbSizesForAttachments.rawValue, forKey: "thumbSizes")
        let insets = [textContainerInset.top,textContainerInset.left,textContainerInset.bottom,textContainerInset.right]
        aCoder.encodeObject(insets, forKey: "textContainerInsetArray")
        if iaString != nil {
            aCoder.encodeObject(IAStringArchive(iaString: iaString), forKey: "iaStringArchive")
        }
        aCoder.encodeObject(selectable, forKey: "selectable")
    }
    
    
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }
    

    public override func selectAll(sender: AnyObject?) {
        guard selectable == true else {return}
        selectedRange = 0..<self.iaString.length
        self.becomeFirstResponder()
        // present menu
        if sender is UITapGestureRecognizer {
            let targetRect = CGRectMake(self.bounds.midX, self.bounds.midY, 10, 10)
            let menu = UIMenuController.sharedMenuController()
            menu.update()
            menu.setTargetRect(targetRect, inView: selectionView)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    func deselect(){
        selectedRange = nil
        selectionView.clearSelection()
        UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
    }
    
    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(NSObject.copy(_:)) && self.selectedRange?.count > 0{
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    ///Attachments are not being deep copied as is
    public override func copy(sender: AnyObject?) {
        UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
        guard iaString != nil && selectedRange?.count > 0 && selectedRange?.startIndex >= 0 && selectedRange?.endIndex <= iaString.length else {return}
        
        let pb = UIPasteboard.generalPasteboard()
        let copyOfSelected = iaString.iaSubstringFromRange(selectedRange!)
        //let copiedText = iaString.text.subStringFromRange(selectedRange!)
        //let iaArchive = IAStringArchive.archive(iaString.copy(true))
        let iaArchive = IAStringArchive.archive(copyOfSelected)
        var pbItem:[String:AnyObject] = [:]
        pbItem[UTITypes.PlainText] = copyOfSelected.text
        pbItem[UTITypes.IAStringArchive] = iaArchive
        pb.addItems([pbItem])
    }
    
    ///Called internally by a didSet on selectedRange. Calls updateSelectionLayer. In editing subclasses this should also update the current/next text properties.
    func selectedRangeChanged(){
        if menu.menuVisible {
            menu.setMenuVisible(false, animated: true)
        }
        updateSelectionLayer()
    }
    
    ///Updates the selection layer if needed.
    func updateSelectionLayer(){
        if selectedRange == nil {
            selectionView.clearSelection()
        } else if self.isFirstResponder() && selectedRange!.count == 0{
            selectionView.updateSelections([], caretRect: caretRectForIntPosition(selectedRange!.startIndex))
        } else {
            let selectionRects = selectionRectsForIntRange(selectedRange!)
            let caretRect = caretRectForIntPosition(selectedRange!.endIndex)
            selectionView.updateSelections(selectionRects, caretRect: caretRect )
        }
    }
    
    
    ///Note: This assumes forward layout direction with left-to-right writing. Caret width is fixed at 2 points
    func caretRectForIntPosition(position: Int) -> CGRect {
        let caretWidth:CGFloat = 2
        let glyphRange = topTV.layoutManager.glyphRangeForCharacterRange(NSMakeRange(position, 0), actualCharacterRange: nil)
        var baseRect:CGRect!
        topTV.layoutManager.enumerateEnclosingRectsForGlyphRange(glyphRange, withinSelectedGlyphRange: NSMakeRange(NSNotFound, 0), inTextContainer: topTV.textContainer) { (rect, stop) in
            baseRect = rect
            stop.initialize(true)
        }
        //rect in topTV coordinate space
        let tvRect = CGRectMake(baseRect.origin.x + baseRect.size.width, baseRect.origin.y, caretWidth, baseRect.size.height)
        return self.convertRect(tvRect, fromView: topTV)
    }
    
    /// Writing Direction and isVertical are hardcoded in this to .Natural and false, respectively.
    func selectionRectsForIntRange(range: Range<Int>) -> [IATextSelectionRect]{
        let glyphRange = topTV.layoutManager.glyphRangeForCharacterRange(range.nsRange, actualCharacterRange: nil)
        var rawEnclosingRects:[CGRect] = []
        topTV.layoutManager.enumerateEnclosingRectsForGlyphRange(glyphRange, withinSelectedGlyphRange: NSMakeRange(NSNotFound, 0), inTextContainer: topTV.textContainer) { (rect, stop) in
            rawEnclosingRects.append(rect)
        }
        let convertedRects = rawEnclosingRects.map({self.convertRect($0, fromView: topTV)})

        if convertedRects.isEmpty == false {
            return IATextSelectionRect.generateSelectionArray(convertedRects)
        } else {
            let rect = caretRectForIntPosition(range.startIndex)
            return [IATextSelectionRect(rect: rect, containsStart: false, containsEnd: false)]
        }
    }
    
}

