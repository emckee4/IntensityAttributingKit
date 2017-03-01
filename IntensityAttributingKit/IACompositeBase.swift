//
//  IACompositeBase.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/19/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

/**
Abstract parent class for IACompositeTextEditor and IACompositeTextView. 
*/
open class IACompositeBase:UIView {
    
    var containerView:UIView
    var selectionView:IASelectionView
    var topTV:ThinTextView
    var bottomTV:ThinTextView
    ///The imageLayer coordinate system is positioned to be the same as that of the textContainers. i.e. it's subject to the textContainerInset property.
    ///The imageLayer view holds the actual rendered textAttachments. This allows us to show them opaquely regardless of where the textViews are in their animation cycles. This also allows us to render these asynchronously if necessary.
    var imageLayerView:IAImageLayerView
    ///Use the setIAString function to set the value
    internal(set) open var iaString:IAString!

    open var selectable:Bool = false
    
    open var preferedMaxLayoutWidth:CGFloat? {
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
    var _selectedRange:CountableRange<Int>?
    internal(set) open var selectedRange:CountableRange<Int>? {
        get{return _selectedRange}
        set{
            let selectedRangeDidChange = _selectedRange != newValue
            _selectedRange = newValue
            if selectedRangeDidChange {
                selectedRangeChanged()
            }
        }
    }
    
    open var maximumNumberOfLines:Int = 0 {
        didSet{
            topTV.textContainer.maximumNumberOfLines = maximumNumberOfLines
            bottomTV.textContainer.maximumNumberOfLines = maximumNumberOfLines
        }
    }
    
    var markedRange:CountableRange<Int>? {
        didSet{if markedRange != oldValue{updateSelectionLayer()}}
    }
    
    open var isAnimating:Bool {
        return (topTV.layer.animation(forKey: "opacity") != nil) || (bottomTV.layer.animation(forKey: "opacity") != nil)
    }
    
    open var thumbSizesForAttachments: IAThumbSize = .Medium {
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
    
    fileprivate var insetConstraintsNeedUpdating = false
    open var textContainerInset:UIEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0) {
        didSet {
            if textContainerInset != oldValue {
                insetConstraintsNeedUpdating = true
                setNeedsUpdateConstraints()
            }
        }
    }
    
    var menu:UIMenuController {
        return UIMenuController.shared
    }
    
    override open var bounds: CGRect{
        didSet{if bounds != oldValue {self.rerenderIAString()}}
    }
    
    //define constraints
    
    /// if non nil then the corners of the internal container view are set with this value. We interface with the container view instead of this view itself sinc
    open var cornerRadius:CGFloat {
        get{return self.containerView.layer.cornerRadius}
        set{self.containerView.layer.cornerRadius = newValue}
    }
    
    open override var backgroundColor: UIColor? {
        get{return containerView.backgroundColor}
        set{containerView.backgroundColor = newValue}
    }
    
    
    
    open override func updateConstraints() {
        if insetConstraintsNeedUpdating{
            insetConstraintsNeedUpdating = false
            topTVTopConstraint.constant = textContainerInset.top
            topTVLeadingConstraint.constant = textContainerInset.left
            topTVBottomConstraint.constant = -textContainerInset.bottom
            topTVTrailingConstraint.constant = -textContainerInset.right
        }
        super.updateConstraints()
    }
    
    
    func setupIATV(){
        containerView.clipsToBounds = true
        
        selectionView.backgroundColor = UIColor.clear
        selectionView.isHidden = true
        
        topTV.backgroundColor = UIColor.clear
        
        bottomTV.backgroundColor = UIColor.clear
        bottomTV.thinTVIsSlave = true
        bottomTV.isHidden = true
        
        imageLayerView.layer.drawsAsynchronously = false
        
        containerView.addSubview(bottomTV)
        containerView.addSubview(topTV)
        containerView.addSubview(imageLayerView)
        containerView.addSubview(selectionView)
        self.addSubview(containerView)
        setupGestureRecognizers()
        setupConstraints()
        super.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(IACompositeBase.handleContentReadyNotification(_:)), name: NSNotification.Name(rawValue: IATextAttachment.contentReadyNotificationName), object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func handleContentReadyNotification(_ notification:Notification!){
        guard let attachment = notification.object as? IATextAttachment, self.iaString.attachments.attachment(withLocalID: attachment.localID) != nil else {return}
        imageLayerView.redrawImage(inAttachment: attachment)
    }

    
    
    func setupConstraints(){
        containerView.translatesAutoresizingMaskIntoConstraints = false
        topTV.translatesAutoresizingMaskIntoConstraints = false
        bottomTV.translatesAutoresizingMaskIntoConstraints = false
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        imageLayerView.translatesAutoresizingMaskIntoConstraints = false
        
        
        topTVTopConstraint = topTV.topAnchor.constraint(equalTo: self.topAnchor, constant: textContainerInset.top).activateWithPriority(1000, identifier: "topTVTopConstraint")
        topTVLeadingConstraint =  topTV.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: textContainerInset.left).activateWithPriority(1000, identifier: "topTVLeadingConstraint")
        
        topTV.setContentCompressionResistancePriority(751, for: .horizontal)
        topTV.setContentCompressionResistancePriority(750, for: .vertical)
        
        topTVBottomConstraint = topTV.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -textContainerInset.bottom).activateWithPriority(1000, identifier: "topTVBottomConstraint")
        topTVTrailingConstraint = topTV.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -textContainerInset.right).activateWithPriority(1000, identifier: "topTVTrailingConstraint")

        //container and selection view match own bounds
        containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).activateWithPriority(1000)
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).activateWithPriority(1000)
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).activateWithPriority(1000)
        containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).activateWithPriority(1000)
        
        selectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).activateWithPriority(1000)
        selectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).activateWithPriority(1000)
        selectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).activateWithPriority(1000)
        selectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).activateWithPriority(1000)
        
        //bottomTV and imagelayer match topTV bounds
        
        bottomTV.topAnchor.constraint(equalTo: topTV.topAnchor, constant: 0).activateWithPriority(1000)
        bottomTV.leadingAnchor.constraint(equalTo: topTV.leadingAnchor, constant: 0).activateWithPriority(1000)
        bottomTV.trailingAnchor.constraint(equalTo: topTV.trailingAnchor, constant: 0).activateWithPriority(1000)
        bottomTV.bottomAnchor.constraint(equalTo: topTV.bottomAnchor, constant: 0).activateWithPriority(1000)
        
        imageLayerView.topAnchor.constraint(equalTo: topTV.topAnchor, constant: 0).activateWithPriority(1000)
        imageLayerView.leadingAnchor.constraint(equalTo: topTV.leadingAnchor, constant: 0).activateWithPriority(1000)
        imageLayerView.trailingAnchor.constraint(equalTo: topTV.trailingAnchor, constant: 0).activateWithPriority(1000)
        imageLayerView.bottomAnchor.constraint(equalTo: topTV.bottomAnchor, constant: 0).activateWithPriority(1000)
    }
    
    
    
    ///Implement in subclasses as needed
    func setupGestureRecognizers(){
        
    }
    
    
    
    
    ///Prefered method for setting stored IAText for display. By default this assumes text has been prerendered and only needs bounds set on its images. If needsRendering is set as true then this will render according to whatever its included schemeName is.
    open func setIAString(_ iaString:IAString!){
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
        topTV.textStorage.replaceCharacters(in: NSMakeRange(0, topTV.textStorage.length), with: attStrings.top)
        
        if attStrings.bottom?.length == attStringLength {
            bottomTV.isHidden = false
            bottomTV.textStorage.replaceCharacters(in: NSMakeRange(0, bottomTV.textStorage.length), with: attStrings.bottom!)
        } else {
            bottomTV.isHidden = true
            bottomTV.textStorage.replaceCharacters(in: NSMakeRange(0, bottomTV.textStorage.length), with: NSAttributedString())
        }
        
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
    func rerenderIAString(recalculateStrings:Bool = false){
        guard iaString != nil else {return}
        if recalculateStrings || (bottomTV.isHidden == false && bottomTV.textStorage.length != topTV.textStorage.length){
            let options = iaString.baseOptions.optionsWithOverridesApplied(IAKitPreferences.iaStringOverridingOptions)
            let attStrings = self.iaString.convertToNSAttributedStringsForLayeredDisplay(withOverridingOptions: options)
            let attStringLength = attStrings.top.length
            topTV.textStorage.replaceCharacters(in: NSMakeRange(0, topTV.textStorage.length), with: attStrings.top)
            if attStrings.bottom?.length == attStringLength {
                bottomTV.isHidden = false
                bottomTV.textStorage.replaceCharacters(in: NSMakeRange(0, bottomTV.textStorage.length), with: attStrings.bottom!)
            } else {
                bottomTV.isHidden = true
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
        imageLayerView.imagesWereChanged(inIAString: iaString, layoutManager: topTV.layoutManager)
    }
    
    ///If attachment positions have changed but the images do not need to be reloaded then this can be called as a more efficient alternative to refreshImageLayer.
    func repositionImageViews(){
        imageLayerView.repositionImageViews(self.iaString, layoutManager: topTV.layoutManager)
    }
    
//    ///The intrinsicContentSize incorporates insets if the topTV ics is non-zero
    open override var intrinsicContentSize : CGSize {
        //return super.intrinsicContentSize()
            //topTV.intrinsicContentSize()
        var val = topTV.intrinsicContentSize
        
        val.width += textContainerInset.left + textContainerInset.right
        val.height += textContainerInset.top + textContainerInset.bottom
        return val
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let insetHor = textContainerInset.left + textContainerInset.right
        let insetVert = textContainerInset.top + textContainerInset.bottom
        let sizeMinusInsets = CGSize(width: size.width - insetHor, height: size.height - insetVert)
        let topTVSize = topTV.sizeThatFits(sizeMinusInsets)
        return CGSize(width: topTVSize.width + insetHor, height: topTVSize.height + insetVert)
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
        containerView = (aDecoder.decodeObject(forKey: "containerView") as?  UIView) ?? UIView()
        topTV = (aDecoder.decodeObject(forKey: "topTV") as?  ThinTextView) ?? ThinTextView()
        bottomTV = (aDecoder.decodeObject(forKey: "bottomTV") as?  ThinTextView) ?? ThinTextView()
        selectionView = (aDecoder.decodeObject(forKey: "selectionView") as?  IASelectionView) ?? IASelectionView()
        imageLayerView = (aDecoder.decodeObject(forKey: "imageLayerView") as?  IAImageLayerView) ?? IAImageLayerView()
        super.init(coder: aDecoder)
        setupIATV()
        
        
        if let ts = IAThumbSize(rawOptional: (aDecoder.decodeObject(forKey: "thumbSizes") as? String)) {
            thumbSizesForAttachments = ts
        }
        if let insetArray = aDecoder.decodeObject(forKey: "textContainerInsetArray") as? [CGFloat], insetArray.count == 4 {
            self.textContainerInset = UIEdgeInsets(top: insetArray[0], left: insetArray[1], bottom: insetArray[2], right: insetArray[3])
        }
        if let iasArch = aDecoder.decodeObject(forKey: "iaStringArchive") as? IAStringArchive {
            setIAString(iasArch.iaString)
        }
        if let selectableOption = aDecoder.decodeObject(forKey: "selectable") as? Bool {
            self.selectable = selectableOption
        }
    }
    
    public convenience init(){
        self.init(frame:CGRect.zero)
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(containerView, forKey: "containerView")
        aCoder.encode(topTV, forKey: "topTV")
        aCoder.encode(bottomTV, forKey: "bottomTV")
        aCoder.encode(imageLayerView, forKey: "imageLayerView")
        aCoder.encode(selectionView, forKey: "selectionView")
        
        
        //want thumbsize, insets, iaString, etc
        aCoder.encode(thumbSizesForAttachments.rawValue, forKey: "thumbSizes")
        let insets = [textContainerInset.top,textContainerInset.left,textContainerInset.bottom,textContainerInset.right]
        aCoder.encode(insets, forKey: "textContainerInsetArray")
        if iaString != nil {
            aCoder.encode(IAStringArchive(iaString: iaString), forKey: "iaStringArchive")
        }
        aCoder.encode(selectable, forKey: "selectable")
    }
    
    
    open override var canBecomeFirstResponder : Bool {
        return true
    }
    

    open override func selectAll(_ sender: Any?) {
        guard selectable == true else {return}
        selectedRange = 0..<self.iaString.length
        self.becomeFirstResponder()
        // present menu
        //if sender is UILongPressGestureRecognizer {
            _ = presentMenu(nil)
        //}
    }
    
    func deselect(){
        if selectedRange != nil {
            selectedRange = nil
            selectionView.clearSelection()
            if menu.isMenuVisible {
                menu.setMenuVisible(false, animated: true)
            }
        }
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) && self.selectedRange?.count > 0{
            return true
        }
        if action == #selector(selectAll(_:)){
            if _selectedRange != nil && _selectedRange!.count == iaString.length {
                return false //filter out cases where we've already selected all
            }
            return iaString.length > 0
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    ///Attachments are not being deep copied as is
    open override func copy(_ sender: Any?) {
        defer{UIMenuController.shared.setMenuVisible(false, animated: true)}
        guard iaString != nil && _selectedRange?.count > 0 && _selectedRange?.lowerBound >= 0 && _selectedRange?.upperBound <= iaString.length else {return}
        
        let pb = UIPasteboard.general
        let copyOfSelected = iaString.iaSubstringFromRange(selectedRange!)
        //let copiedText = iaString.text.subStringFromRange(selectedRange!)
        //let iaArchive = IAStringArchive.archive(iaString.copy(true))
        let iaArchive = IAStringArchive.archive(copyOfSelected)
        var pbItem:[String:AnyObject] = [:]
        pbItem[UTITypes.PlainText] = copyOfSelected.text as AnyObject?
        pbItem[UTITypes.IAStringArchive] = iaArchive as AnyObject?
        pb.items = [pbItem]
    }
    
    ///Called internally by a didSet on selectedRange. Calls updateSelectionLayer. In editing subclasses this should also update the current/next text properties.
    func selectedRangeChanged(){
        if menu.isMenuVisible {
            menu.setMenuVisible(false, animated: true)
        }
        updateSelectionLayer()
    }
    
    ///Updates the selection layer if needed.
    func updateSelectionLayer(){
        if selectedRange == nil { // changed from selectedRange == nil && markedRange == nil
            markedRange = nil
            selectionView.clearSelection()
        } else if self.isFirstResponder && selectedRange!.count == 0 {
            //selectionView.updateSelections([], caretRect: caretRectForIntPosition(selectedRange!.startIndex))
            let markedRect:CGRect? = {
                guard markedRange != nil else {return nil}
                let gr = topTV.layoutManager.glyphRange(forCharacterRange: markedRange!.nsRange, actualCharacterRange: nil)
                let rect = topTV.layoutManager.boundingRect(forGlyphRange: gr, in: topTV.textContainer)
                return topTV.convert(rect, to: self)
            }()
            selectionView.setTextMarking(markedRect, caretRect: caretRectForIntPosition(selectedRange!.lowerBound))
        } else {
            let selectionRects = selectionRectsForIntRange(selectedRange!)
            let caretRect = caretRectForIntPosition(selectedRange!.upperBound)
            selectionView.updateSelections(selectionRects, caretRect: caretRect )
        }
    }
    
    ///Presents a UIMenuController using the provided targetRect or in the middle of the view if none is provided
    func presentMenu(_ targetRect:CGRect?)->UIMenuController{
        let targetRect = CGRect(x: self.bounds.midX, y: self.bounds.midY, width: 10, height: 10)
        let menu = UIMenuController.shared
        menu.update()
        menu.setTargetRect(targetRect, in: selectionView)
        menu.setMenuVisible(true, animated: true)
        return menu
    }
    
    ///Note: This assumes forward layout direction with left-to-right writing. Caret width is fixed at 2 points. Caret will be increased in size (height increased) if it's too small (as a result of an empty field).
    func caretRectForIntPosition(_ position: Int) -> CGRect {
        let caretWidth:CGFloat = 2
        let glyphRange = topTV.layoutManager.glyphRange(forCharacterRange: NSMakeRange(position, 0), actualCharacterRange: nil)
        var baseRect:CGRect!

        baseRect = topTV.layoutManager.boundingRect(forGlyphRange: glyphRange, in: topTV.textContainer)
        if baseRect == nil {
            baseRect = topTV.layoutManager.lineFragmentRect(forGlyphAt: glyphRange.location, effectiveRange: nil)
        }
        
        let caretHeight:CGFloat = max(baseRect.size.height, 22.0) //establish minimum caret height
        //rect in topTV coordinate space
        let tvRect = CGRect(x: baseRect.origin.x + baseRect.size.width, y: baseRect.origin.y, width: caretWidth, height: caretHeight)
        return self.convert(tvRect, from: topTV)
    }
    
    /// Writing Direction and isVertical are hardcoded in this to .Natural and false, respectively.
    func selectionRectsForIntRange(_ range: CountableRange<Int>) -> [IATextSelectionRect]{
        let glyphRange = topTV.layoutManager.glyphRange(forCharacterRange: range.nsRange, actualCharacterRange: nil)
        var rawEnclosingRects:[CGRect] = []
        topTV.layoutManager.enumerateEnclosingRects(forGlyphRange: glyphRange, withinSelectedGlyphRange: NSMakeRange(NSNotFound, 0), in: topTV.textContainer) { (rect, stop) in
            rawEnclosingRects.append(rect)
        }
        let convertedRects = rawEnclosingRects.map({self.convert($0, from: topTV)})

        if convertedRects.isEmpty == false {
            return IATextSelectionRect.generateSelectionArray(convertedRects)
        } else {
            let rect = caretRectForIntPosition(range.lowerBound)
            return [IATextSelectionRect(rect: rect, containsStart: false, containsEnd: false)]
        }
    }
    
}

