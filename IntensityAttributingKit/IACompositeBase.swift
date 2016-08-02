//
//  IACompositeBase.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/19/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit
/**
Abstract parent class for IACompositeTextEditor and IACompositeTextView. 
*/
public class IACompositeBase:UIView {
    
    var containerView:UIView
    var selectionView:IASelectionView
    var topTV:ThinTextView
    var bottomTV:ThinTextView
    ///The imageLayer coordinate system is positioned to be the same as that of the textContainers. i.e. it's subject to the textContainerInset property.
    ///The imageLayer view holds the actual rendered textAttachments. This allows us to show them opaquely regardless of where the textViews are in their animation cycles. This also allows us to render these asynchronously if necessary.
//var imageLayer:UIView
//var imageLayerImageViews:[UIImageView] = []
    var imageLayerView:IAImageLayerView
    ///Use the setIAString function to set the value
    internal(set) public var iaString:IAString!

    //public weak var delegate:IATextViewDelegate?
    
    //var tapGestureRecognizer:UITapGestureRecognizer!
    
    public var selectable:Bool = false
    
    public var preferedMaxLayoutWidth:CGFloat? {
        get{
            if let val = topTV.preferedMaxLayoutWidth {
                return val + textContainerInset.left + textContainerInset.right
            } else {
                return nil
            }
        }
        set{
            if newValue != nil {
                topTV.preferedMaxLayoutWidth = newValue! - (textContainerInset.left + textContainerInset.right)
            } else {
                topTV.preferedMaxLayoutWidth = nil
            }
        }
    }
    
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
    
    var markedRange:Range<Int>? {
        didSet{if markedRange != oldValue{updateSelectionLayer()}}
    }
    
    public var isAnimating:Bool {
        return (topTV.layer.animationForKey("opacity") != nil) || (bottomTV.layer.animationForKey("opacity") != nil)
    }
    
    public var thumbSizesForAttachments: ThumbSize = .Medium {
        didSet{
            topTV.thumbSize = thumbSizesForAttachments
            bottomTV.thumbSize = thumbSizesForAttachments
            if iaString?.attachmentCount > 0 && thumbSizesForAttachments != oldValue {
                //trigger layout from scratch
                setIAString(iaString)
            }
        }
    }
    
    var topTVTopConstraint:NSLayoutConstraint!
    var topTVLeadingConstraint:NSLayoutConstraint!
    var topTVBottomConstraint:NSLayoutConstraint!
    var topTVTrailingConstraint:NSLayoutConstraint!
    
    private var insetConstraintsNeedUpdating = false
    public var textContainerInset:UIEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0) {
        didSet {
            if textContainerInset != oldValue {
                insetConstraintsNeedUpdating = true
                setNeedsUpdateConstraints()
            }
        }
    }
    
    var menu:UIMenuController {
        return UIMenuController.sharedMenuController()
    }
    
    override public var bounds: CGRect{
        didSet{if bounds != oldValue {self.rerenderIAString()}}
    }
    
    //define constraints
    
    /// if non nil then the corners of the internal container view are set with this value. We interface with the container view instead of this view itself sinc
    public var cornerRadius:CGFloat {
        get{return self.containerView.layer.cornerRadius}
        set{self.containerView.layer.cornerRadius = newValue}
    }
    
    public override var backgroundColor: UIColor? {
        get{return containerView.backgroundColor}
        set{containerView.backgroundColor = newValue}
    }
    
    
    
    public override func updateConstraints() {
        if insetConstraintsNeedUpdating{
            insetConstraintsNeedUpdating = false
            topTVTopConstraint.constant = textContainerInset.top
            topTVLeadingConstraint.constant = textContainerInset.left
            topTVBottomConstraint.constant = -textContainerInset.bottom
            topTVTrailingConstraint.constant = -textContainerInset.right
        }
        
        
        
        super.updateConstraints()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()   //should this be called before or after?
//        if iaString != nil && imageLayerView.layedOutForContainerSize != topTV.textContainer.size && iaString.attachmentCount > 0{
//            imageLayerView.repositionImageViews(iaString, layoutManager: topTV.layoutManager)
//
//        }
//        //set frames for contained objects
//        let frameWithInset = UIEdgeInsetsInsetRect(self.bounds, textContainerInset)
//        containerView.frame = self.bounds
//        selectionView.frame = self.bounds  //we use the full frame since we will be gettting selection rects (typically via UITextInput) in the coordinate space of the superview (the IATextView)
//        topTV.frame = frameWithInset
//        bottomTV.frame = frameWithInset
//        imageLayerView.frame = frameWithInset
        //TODO: If bounds have changed but content hasn't then we should try to move imageviews rather than reloading the images. Need to make this object a delegate of the topTV's layoutManager
    }
    
    
    
    func setupIATV(){
        //selectionView.userInteractionEnabled = false
        containerView.clipsToBounds = true
        
        selectionView.backgroundColor = UIColor.clearColor()
        selectionView.hidden = true
        
        //topTV.userInteractionEnabled = false
        topTV.backgroundColor = UIColor.clearColor()
        
        //bottomTV.userInteractionEnabled = false
        bottomTV.backgroundColor = UIColor.clearColor()
        bottomTV.thinTVIsSlave = true
        bottomTV.hidden = true
        
        //imageLayer.userInteractionEnabled = false
        imageLayerView.layer.drawsAsynchronously = false
        //imageLayerView.clipsToBounds = true
        //imageLayer.hidden = true
        
        //containerView.addSubview(imageLayerView)
        containerView.addSubview(bottomTV)
        containerView.addSubview(topTV)
        containerView.addSubview(imageLayerView)
        containerView.addSubview(selectionView)
        self.addSubview(containerView)
        setupGestureRecognizers()
        setupConstraints()
        super.backgroundColor = UIColor.clearColor()
    }
    
    

    
    
    func setupConstraints(){
        containerView.translatesAutoresizingMaskIntoConstraints = false
        topTV.translatesAutoresizingMaskIntoConstraints = false
        bottomTV.translatesAutoresizingMaskIntoConstraints = false
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        imageLayerView.translatesAutoresizingMaskIntoConstraints = false
        
        
        topTVTopConstraint = topTV.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: textContainerInset.top).activateWithPriority(1000, identifier: "topTVTopConstraint")
        topTVLeadingConstraint =  topTV.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor, constant: textContainerInset.left).activateWithPriority(1000, identifier: "topTVLeadingConstraint")
        
        topTV.setContentCompressionResistancePriority(751, forAxis: .Horizontal)
        topTV.setContentCompressionResistancePriority(750, forAxis: .Vertical)
        
        topTVBottomConstraint = topTV.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -textContainerInset.bottom).activateWithPriority(1000, identifier: "topTVBottomConstraint")
        topTVTrailingConstraint = topTV.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor, constant: -textContainerInset.right).activateWithPriority(1000, identifier: "topTVTrailingConstraint")
        //topTVBottomConstraint = self.bottomAnchor.constraintEqualToAnchor(topTV.bottomAnchor, constant: 0.0).activateWithPriority(1000, identifier: "topTVBottomConstraint")
        //topTVTrailingConstraint = self.trailingAnchor.constraintEqualToAnchor(topTV.trailingAnchor, constant: 0.0).activateWithPriority(1000, identifier: "topTVTrailingConstraint")
        

        //container and selection view match own bounds
        containerView.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 0).activateWithPriority(1000)
        containerView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor, constant: 0).activateWithPriority(1000)
        containerView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor, constant: 0).activateWithPriority(1000)
        containerView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: 0).activateWithPriority(1000)
        
        selectionView.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 0).activateWithPriority(1000)
        selectionView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor, constant: 0).activateWithPriority(1000)
        selectionView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor, constant: 0).activateWithPriority(1000)
        selectionView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: 0).activateWithPriority(1000)
        
        //bottomTV and imagelayer match topTV bounds
        
        bottomTV.topAnchor.constraintEqualToAnchor(topTV.topAnchor, constant: 0).activateWithPriority(1000)
        bottomTV.leadingAnchor.constraintEqualToAnchor(topTV.leadingAnchor, constant: 0).activateWithPriority(1000)
        bottomTV.trailingAnchor.constraintEqualToAnchor(topTV.trailingAnchor, constant: 0).activateWithPriority(1000)
        bottomTV.bottomAnchor.constraintEqualToAnchor(topTV.bottomAnchor, constant: 0).activateWithPriority(1000)
        
        imageLayerView.topAnchor.constraintEqualToAnchor(topTV.topAnchor, constant: 0).activateWithPriority(1000)
        imageLayerView.leadingAnchor.constraintEqualToAnchor(topTV.leadingAnchor, constant: 0).activateWithPriority(1000)
        imageLayerView.trailingAnchor.constraintEqualToAnchor(topTV.trailingAnchor, constant: 0).activateWithPriority(1000)
        imageLayerView.bottomAnchor.constraintEqualToAnchor(topTV.bottomAnchor, constant: 0).activateWithPriority(1000)
    }
    
    
    
    ///Implement in subclasses as needed
    func setupGestureRecognizers(){
        
    }
    
    
    
    
    ///Prefered method for setting stored IAText for display. By default this assumes text has been prerendered and only needs bounds set on its images. If needsRendering is set as true then this will render according to whatever its included schemeName is.
    public func setIAString(iaString:IAString!){
        if iaString != nil {
            self.iaString = iaString
        } else {
            self.iaString = IAString()
        }
        topTV.invalidateIntrinsicContentSize()
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
            bottomTV.textStorage.replaceCharactersInRange(NSMakeRange(0, bottomTV.textStorage.length), withAttributedString: NSAttributedString())
        }
        
        
        //TODO: Need to figure out how to render attachments onto bottom layer (asynchronously ideally)
        
//        if iaString.attachmentCount > imageLayerImageViews.count {
//            for _ in 0..<(iaString.attachmentCount - imageLayerImageViews.count){
//                let newImageView = UIImageView(frame: CGRectZero)
//                newImageView.translatesAutoresizingMaskIntoConstraints = false
//                imageLayerImageViews.append(newImageView)
//                imageLayer.addSubview(newImageView)
//            }
//            
//        }
        invalidateIntrinsicContentSize()
        refreshImageLayer()
        updateSelectionLayer()
        
        //Start animation according to animation scheme if possible/desired
        if willAnimate {
            startAnimation()
        } else {
            stopAnimation()
        }
    }
    
    ///Forces layout and drawing of IAString. If recalculate option is true, then this recalculates entire range of iaString, similar to what would happen calling setIAString(self.iaString) but keeps selection intact. This function is typically called without the recalculatStrings option when bounds change or with recalculateStrings after changes in states that affect the display of the entire string, like changing the smoother or transformer (current values or global overrides).
    func rerenderIAString(recalculateStrings recalculateStrings:Bool = false){
        guard iaString != nil else {return}
        if recalculateStrings || (bottomTV.hidden == false && bottomTV.textStorage.length != topTV.textStorage.length){
            let options = iaString.baseOptions.optionsWithOverridesApplied(IAKitPreferences.iaStringOverridingOptions)
            let attStrings = self.iaString.convertToNSAttributedStringsForLayeredDisplay(withOverridingOptions: options)
            let attStringLength = attStrings.top.length
            topTV.textStorage.replaceCharactersInRange(NSMakeRange(0, topTV.textStorage.length), withAttributedString: attStrings.top)
            if attStrings.bottom?.length == attStringLength {
                bottomTV.hidden = false
                bottomTV.textStorage.replaceCharactersInRange(NSMakeRange(0, bottomTV.textStorage.length), withAttributedString: attStrings.bottom!)
            } else {
                bottomTV.hidden = true
            }
        } else {
            self.setNeedsLayout()
        }
        self.layoutIfNeeded()
        self.repositionImageViews()
        self.setNeedsDisplay()
        self.updateSelectionLayer()
        //TODO: might need to call reposition or refreshImageLayer
    }
    
    ///This calls the imageLayerView's imagesWereChanged function. This is called when the count or content of the attachments may have changed. If only position has changed then repositionImageViews is prefered as it is less expensive.
    func refreshImageLayer(){
//        guard iaString.attachmentCount > 0 else {return}
//        if imageLayer.hidden {imageLayer.hidden = false}
//        if imageLayerImageViews.count < iaString.attachmentCount {
//            for _ in 0..<(iaString.attachmentCount - imageLayerImageViews.count){
//                let newImageView = UIImageView(frame: CGRectZero)
//                newImageView.translatesAutoresizingMaskIntoConstraints = false
//                imageLayerImageViews.append(newImageView)
//                imageLayer.addSubview(newImageView)
//            }
//        }
//        for (i ,locAttach) in iaString.attachments.enumerate() {
//            imageLayerImageViews[i].hidden = false
//            let (location, attachment) = locAttach
//            let attachRect = topTV.layoutManager.boundingRectForGlyphRange(NSMakeRange(location, 1), inTextContainer: topTV.textContainer)
//            imageLayerImageViews[i].frame = attachRect
//            imageLayerImageViews[i].image = ThumbSize.Medium.imagePlaceholder//attachment.imageForThumbSize(self.thumbSizesForAttachments)
//        }
//        if iaString.attachmentCount < imageLayerImageViews.count {
//            for i in (iaString.attachmentCount)..<(imageLayerImageViews.count){
//                imageLayerImageViews[i].image = nil
//                imageLayerImageViews[i].hidden = true
//            }
//        }
        imageLayerView.imagesWereChanged(inIAString: iaString, layoutManager: topTV.layoutManager)
    }
    
    ///If attachment positions have changed but the images do not need to be reloaded then this can be called as a more efficient alternative to refreshImageLayer.
    func repositionImageViews(){
//        guard imageLayerImageViews.count >= iaString.attachmentCount else {refreshImageLayer();return}
//        for (i ,locAttach) in iaString.attachments.enumerate() {
//            let (location, _) = locAttach
//            let attachRect = topTV.layoutManager.boundingRectForGlyphRange(NSMakeRange(location, 1), inTextContainer: topTV.textContainer)
//            imageLayerImageViews[i].frame = attachRect
//        }
        imageLayerView.repositionImageViews(self.iaString, layoutManager: topTV.layoutManager)
    }
    
//    ///The intrinsicContentSize incorporates insets if the topTV ics is non-zero
    public override func intrinsicContentSize() -> CGSize {
        //return super.intrinsicContentSize()
            //topTV.intrinsicContentSize()
        var val = topTV.intrinsicContentSize()
        
        val.width += textContainerInset.left + textContainerInset.right
        val.height += textContainerInset.top + textContainerInset.bottom
        return val
    }
    
//    ///The systemLayoutSizeFittingSize doesn't incorporate insets if the topTV ics is non-zero
//    public override func systemLayoutSizeFittingSize(targetSize: CGSize) -> CGSize {
//        let insetHor = textContainerInset.left + textContainerInset.right
//        let insetVert = textContainerInset.top + textContainerInset.bottom
//        let sizeMinusInsets = CGSizeMake(targetSize.width - insetHor, targetSize.height - insetVert)
//        let topTVSize = topTV.systemLayoutSizeFittingSize(sizeMinusInsets)
//        return CGSizeMake(topTVSize.width + insetHor, topTVSize.height + insetVert)
//    }
//    
//    public override func systemLayoutSizeFittingSize(targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
//        if verticalFittingPriority < horizontalFittingPriority {
//            return systemLayoutSizeFittingSize(CGSizeMake(targetSize.width, 10000000))
//        } else if verticalFittingPriority > horizontalFittingPriority{
//            return systemLayoutSizeFittingSize(CGSizeMake(10000000,targetSize.height))
//        } else{
//            return systemLayoutSizeFittingSize(targetSize)
//        }
//        
//        
//    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        let insetHor = textContainerInset.left + textContainerInset.right
        let insetVert = textContainerInset.top + textContainerInset.bottom
        let sizeMinusInsets = CGSizeMake(size.width - insetHor, size.height - insetVert)
        let topTVSize = topTV.sizeThatFits(sizeMinusInsets)
        return CGSizeMake(topTVSize.width + insetHor, topTVSize.height + insetVert)
    }
    
    
    
    
    public override init(frame: CGRect) {
        containerView = UIView(frame: frame)
        topTV = ThinTextView()
        bottomTV = ThinTextView()
        selectionView = IASelectionView()
        imageLayerView = IAImageLayerView()
        
        
        super.init(frame: frame)
        setupIATV()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        containerView = (aDecoder.decodeObjectForKey("containerView") as?  UIView) ?? UIView()
        topTV = (aDecoder.decodeObjectForKey("topTV") as?  ThinTextView) ?? ThinTextView()
        bottomTV = (aDecoder.decodeObjectForKey("bottomTV") as?  ThinTextView) ?? ThinTextView()
        selectionView = (aDecoder.decodeObjectForKey("selectionView") as?  IASelectionView) ?? IASelectionView()
        imageLayerView = (aDecoder.decodeObjectForKey("imageLayerView") as?  IAImageLayerView) ?? IAImageLayerView()
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
        aCoder.encodeObject(imageLayerView, forKey: "imageLayerView")
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
        //if sender is UILongPressGestureRecognizer {
            presentMenu(nil)
        //}
    }
    
    func deselect(){
        if selectedRange != nil {
            selectedRange = nil
            selectionView.clearSelection()
            if menu.menuVisible {
                menu.setMenuVisible(false, animated: true)
            }
        }
    }
    
    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(NSObject.copy(_:)) && self.selectedRange?.count > 0{
            return true
        }
        if action == #selector(NSObject.selectAll(_:)){
            if _selectedRange != nil && _selectedRange!.count == iaString.length {
                return false //filter out cases where we've already selected all
            }
            return iaString.length > 0
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    ///Attachments are not being deep copied as is
    public override func copy(sender: AnyObject?) {
        defer{UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)}
        guard iaString != nil && _selectedRange?.count > 0 && _selectedRange?.startIndex >= 0 && _selectedRange?.endIndex <= iaString.length else {return}
        
        let pb = UIPasteboard.generalPasteboard()
        let copyOfSelected = iaString.iaSubstringFromRange(selectedRange!)
        //let copiedText = iaString.text.subStringFromRange(selectedRange!)
        //let iaArchive = IAStringArchive.archive(iaString.copy(true))
        let iaArchive = IAStringArchive.archive(copyOfSelected)
        var pbItem:[String:AnyObject] = [:]
        pbItem[UTITypes.PlainText] = copyOfSelected.text
        pbItem[UTITypes.IAStringArchive] = iaArchive
        pb.items = [pbItem]
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
        if selectedRange == nil { // changed from selectedRange == nil && markedRange == nil
            markedRange = nil
            selectionView.clearSelection()
        } else if self.isFirstResponder() && selectedRange!.count == 0 {
            //selectionView.updateSelections([], caretRect: caretRectForIntPosition(selectedRange!.startIndex))
            let markedRect:CGRect? = {
                guard markedRange != nil else {return nil}
                let gr = topTV.layoutManager.glyphRangeForCharacterRange(markedRange!.nsRange, actualCharacterRange: nil)
                let rect = topTV.layoutManager.boundingRectForGlyphRange(gr, inTextContainer: topTV.textContainer)
                return topTV.convertRect(rect, toView: self)
            }()
            selectionView.setTextMarking(markedRect, caretRect: caretRectForIntPosition(selectedRange!.startIndex))
        } else {
            let selectionRects = selectionRectsForIntRange(selectedRange!)
            let caretRect = caretRectForIntPosition(selectedRange!.endIndex)
            selectionView.updateSelections(selectionRects, caretRect: caretRect )
        }
    }
    
    ///Presents a UIMenuController using the provided targetRect or in the middle of the view if none is provided
    func presentMenu(targetRect:CGRect?)->UIMenuController{
        let targetRect = CGRectMake(self.bounds.midX, self.bounds.midY, 10, 10)
        let menu = UIMenuController.sharedMenuController()
        menu.update()
        menu.setTargetRect(targetRect, inView: selectionView)
        menu.setMenuVisible(true, animated: true)
        return menu
    }
    
    ///Note: This assumes forward layout direction with left-to-right writing. Caret width is fixed at 2 points. Caret will be increased in size (height increased) if it's too small (as a result of an empty field).
    func caretRectForIntPosition(position: Int) -> CGRect {
        let caretWidth:CGFloat = 2
        let glyphRange = topTV.layoutManager.glyphRangeForCharacterRange(NSMakeRange(position, 0), actualCharacterRange: nil)
        var baseRect:CGRect!

        baseRect = topTV.layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: topTV.textContainer)
        if baseRect == nil {
            baseRect = topTV.layoutManager.lineFragmentRectForGlyphAtIndex(glyphRange.location, effectiveRange: nil)
        }
        
        let caretHeight:CGFloat = max(baseRect.size.height, 22.0) //establish minimum caret height
        //rect in topTV coordinate space
        let tvRect = CGRectMake(baseRect.origin.x + baseRect.size.width, baseRect.origin.y, caretWidth, caretHeight)
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

