//
//  IACompositeTextEditor.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/3/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

public class IACompositeTextEditor:UIView, UITextInput{
    
    var topTV:UITextView!
    var bottomTV:UITextView!
    ///The imageLayer coordinate system is positioned to be the same as that of the textContainers. i.e. it's subject to the textContainerInset property.
    var imageLayer:UIView!
    
    private var caret:IACaret!
    private var selectionViews:[UIView] = []
    private var imageLayerImageViews:[UIImageView] = []
    ///Use the setIAString function to set the value
    private(set) public var iaString:IAString!
    
    weak public var editorDelegate:IATextEditorDelegate?

    ///Indicates whether an opacity animation is active on any layer
    public var isAnimating:Bool {
        return (topTV.layer.animationForKey("opacity") != nil) || (bottomTV.layer.animationForKey("opacity") != nil)
    }
    
    public var thumbSizesForAttachments: ThumbSize = .Medium {
        //didSet {self.iaString?.thumbSize = thumbSizesForAttachments}
        didSet{
            (topTV.textContainer as? IATextContainer)?.preferedThumbSize = thumbSizesForAttachments
            (bottomTV.textContainer as? IATextContainer)?.preferedThumbSize = thumbSizesForAttachments
            //TODO: invalidate layout if this changes
        }
    }
    
    var overridingTransformer:IntensityTransformers? = IAKitPreferences.overridesTransformer
    var overridingSmoother:IAStringTokenizing? = IAKitPreferences.overridesTokenizer
    
    public var textContainerInset:UIEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0) {
        didSet {
            if textContainerInset != oldValue {
                topTV.textContainerInset = textContainerInset
                bottomTV?.textContainerInset = textContainerInset
                setNeedsLayout() // layoutSubviews will update the imageLayer position
            }
        }
    }
    
    //MARK:- default/last attributes
    
    lazy var baseAttributes:IABaseAttributes = {return IABaseAttributes(size:IAKitPreferences.defaultTextSize)}()
    var currentIntensity:Int = IAKitPreferences.defaultIntensity
    
    var selectedRange:Range<Int>? {
        get{return uitrToR(selectedTextRange)}
        //set{self.selectedTextRange = rangeToUITR(newValue) }
    }
    private var lastSelectedTextRange:UITextRange?
    
    //MARK:- Keyboard management
    
    private var _inputVC:UIInputViewController?
    override public var inputViewController:UIInputViewController? {
        set {self._inputVC = newValue}
        get {return self._inputVC}
    }
    
    override public var inputAccessoryViewController:UIInputViewController? {
        get {return IAKitPreferences.accessory}
    }
    
    ///returns true if IAKeyboard is presented by this, false if system keyboard, and nil if this is not first responder
    var keyboardIsIAKeyboard:Bool?{
        guard self.isFirstResponder() else {return nil}
        return inputViewController == IAKitPreferences.keyboard
    }
    
    func swapKB(){
        if self.inputViewController == nil {
            self.inputViewController = IAKitPreferences.keyboard
            IAKitPreferences.keyboard.prepareKeyboardForAppearance()
            IAKitPreferences.accessory.updateAccessoryLayout(true)
        } else {
            self.inputViewController = nil
            IAKitPreferences.accessory.updateAccessoryLayout(false)
        }
        self.reloadInputViews()
        self.updateSuggestionsBar()
    }
    
    
    //MARK: IAString setting
    
    
    ///Prefered method for setting stored IAText for display. By default this assumes text has been prerendered and only needs bounds set on its images. If needsRendering is set as true then this will render according to whatever its included schemeName is.
    public func setIAString(iaString:IAString!, withCacheIdentifier:String? = nil){
        self.iaString = iaString
        guard iaString != nil else {clearTextView(); return}
        guard iaString.length > 0 else {clearTextView(); return}

        let options = iaString.baseOptions.optionsWithOverridesApplied(IAKitPreferences.iaStringOverridingOptions)

        //self.attributedText = self._iaString?.convertToNSAttributedString(withOptions: _renderOptions)
        let attStrings = self.iaString.convertToNSAttributedStringsForLayeredDisplay(withOverridingOptions: options)
        topTV.attributedText = attStrings.top
        bottomTV.attributedText = attStrings.bottom
        
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
        if options.animatesIfAvailable == true && options.renderScheme.isAnimatable {
            startAnimation()
        } else {
            stopAnimation()
        }
    }
    
    //MARK:- Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()   //should this be called before or after?
        //set frames for contained objects
        topTV.frame = self.bounds
        bottomTV?.frame = self.bounds
        imageLayer?.frame = CGRect(x: textContainerInset.left, y: textContainerInset.top,
                                   width: self.bounds.width - (textContainerInset.left + textContainerInset.right),
                                   height: self.bounds.height - (textContainerInset.top + textContainerInset.bottom)
        )
        //TODO: If bounds have changed but content hasn't then we should try to move imageviews rather than reloading the images. Need to make this object a delegate of the topTV's layoutManager
        repositionImageViews()
    }

    private func clearTextView(){
        stopAnimation()
        topTV.attributedText = nil
        bottomTV.attributedText = nil
        bottomTV.hidden = true
    }
    
    ///Reloads all attachments and draws them to the imageLayer.
    public func refreshImageLayer(){
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
    
    ///Adjusts the frames of the already instantiated and presumably drawn image views rather than reloading. This is useful when inserting text before an image that would move its frame without otherwise changing the contents of the image layer.
    func repositionImageViews(){
        //nothing to do here
        guard iaString?.attachmentCount > 0 else {return}
        //check that we have enough image views. This should never fail
        guard iaString.attachmentCount <= imageLayerImageViews.count else {refreshImageLayer(); return}
        for (i ,locAttach) in iaString.attachments.enumerate() {
            let (location, _) = locAttach
            let attachRect = topTV.layoutManager.boundingRectForGlyphRange(NSMakeRange(location, 1), inTextContainer: topTV.textContainer)
            imageLayerImageViews[i].frame = attachRect
        }
    }

    public override func intrinsicContentSize() -> CGSize {
        return topTV.intrinsicContentSize()
    }
    
    public override func systemLayoutSizeFittingSize(targetSize: CGSize) -> CGSize {
        return topTV.systemLayoutSizeFittingSize(targetSize)
    }
    
    //MARK:- Animation
    
    public func startAnimation(){
        guard let options = iaString?.baseOptions?.optionsWithOverridesApplied(IAKitPreferences.iaStringOverridingOptions) where options.animatesIfAvailable == true && options.renderScheme.isAnimatable && iaString.length > 0 else {return}
        
        let trans:IntensityTransformers =  options.renderScheme
        guard let animatingTransformer = (trans.transformer as? AnimatedIntensityTransforming.Type) else {return}
        let aniParams:IAAnimationParameters = options.animationOptions ?? animatingTransformer.defaultAnimationParameters
        // get properties, adjust offsets, start animation
        let baseOffset = NSProcessInfo.processInfo().systemUptime % aniParams.duration
        
        if animatingTransformer.topLayerAnimates {
            let topAnimation = IACompositeTextView.generateOpacityAnimation(aniParams.topLayerFromValue, endAlpha: aniParams.topLayerToValue, duration: aniParams.duration, offset: baseOffset)
            topTV.layer.addAnimation(topAnimation, forKey: "opacity")
        } else {
            topTV.layer.removeAnimationForKey("opacity")
        }
        if animatingTransformer.bottomLayerAnimates{
            let bottomOffset = baseOffset + (animatingTransformer.bottomLayerTimingOffset * aniParams.duration)
            let bottomAnimation = IACompositeTextView.generateOpacityAnimation(aniParams.bottomLayerFromValue, endAlpha: aniParams.bottomLayerToValue, duration: aniParams.duration, offset: bottomOffset)
            bottomTV.layer.addAnimation(bottomAnimation, forKey: "opacity")
        } else {
            bottomTV.layer.removeAnimationForKey("opacity")
        }
        
    }
    
    public func stopAnimation(){
        topTV.layer.removeAnimationForKey("opacity")
        bottomTV.layer.removeAnimationForKey("opacity")
        //TODO: may want to set final value for opacity here
    }
    
    
    static func generateOpacityAnimation(startAlpha:Float = 0, endAlpha:Float = 1, duration:NSTimeInterval, offset:NSTimeInterval = 0)->CABasicAnimation{
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = NSNumber(float: startAlpha)
        anim.toValue = NSNumber(float: endAlpha)
        
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        anim.autoreverses = true
        anim.duration = duration
        anim.repeatCount = 100
        anim.timeOffset = offset
        return anim
    }
    
    
    //MARK: inits/setup

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupIATV()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if topTV == nil || bottomTV == nil || imageLayer == nil {
            setupIATV()
        }
    }
    
    public convenience init(){
        self.init(frame:CGRectZero)
    }
    
    func setupIATV(){
        
        let topTextContainer = IATextContainer(size: CGSizeZero)
        let topLayoutManager = NSLayoutManager()
        let topTextStorage = NSTextStorage()
        topTextStorage.addLayoutManager(topLayoutManager)
        topTextContainer.replaceLayoutManager(topLayoutManager)
        topTV = UITextView(frame: CGRectZero, textContainer: topTextContainer)
        topTV.translatesAutoresizingMaskIntoConstraints = false
        topTV.editable = false
        topTV.scrollEnabled = false
        topTV.userInteractionEnabled = false

        topTV.backgroundColor = UIColor.clearColor()
        
        
        let bottomTextContainer = IATextContainer(size: CGSizeZero)
        let bottomLayoutManager = NSLayoutManager()
        let bottomTextStorage = NSTextStorage()
        bottomTextStorage.addLayoutManager(bottomLayoutManager)
        bottomTextContainer.replaceLayoutManager(bottomLayoutManager)
        bottomTV = UITextView(frame: CGRectZero, textContainer: bottomTextContainer)//UITextView(frame: CGRectZero)
        bottomTV.translatesAutoresizingMaskIntoConstraints = false
        bottomTV.editable = false
        bottomTV.userInteractionEnabled = false
        bottomTV.scrollEnabled = false
        bottomTV.backgroundColor = UIColor.clearColor()
        
        imageLayer = UIView(frame:CGRectZero)
        imageLayer.translatesAutoresizingMaskIntoConstraints = false
        imageLayer.userInteractionEnabled = false
        imageLayer.layer.drawsAsynchronously = true
        imageLayer.clipsToBounds = true
        
        self.addSubview(imageLayer)
        self.addSubview(bottomTV)
        self.addSubview(topTV)
        
        caret = IACaret(frame: CGRectZero)
        caret.hidden = true
        self.addSubview(caret)
        //self.resetEditor()
        self.iaString = IAString()
        setTopTVInputDelegate()
    }
    
    //MARK:- firstResponder
    
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override public func becomeFirstResponder() -> Bool {
        _inputVC = IAKitPreferences.keyboard
        guard super.becomeFirstResponder() else {return false}
        prepareToBecomeFirstResponder()
        return true
    }
    
    override public func resignFirstResponder() -> Bool {
        guard super.resignFirstResponder() else {return false}
        caret.hidden = true
        IAKitPreferences.keyboard.inputView!.layer.shouldRasterize = true
        RawIntensity.touchInterpreter.deactivate()
        return true
    }
    
    func prepareToBecomeFirstResponder(){
        let iaAccessory = IAKitPreferences.accessory
        let iaKeyboard = IAKitPreferences.keyboard
        
        
        iaKeyboard.delegate = self
        iaAccessory.delegate = self
        if selectedTextRange == nil {
            selectedTextRange = textRangeFromPosition(endOfDocument, toPosition: endOfDocument)
        }
        caret.hidden = false
        
        iaAccessory.setTransformKeyForScheme(iaString.baseOptions.renderScheme)
        iaAccessory.setTokenizerKeyValue(self.iaString!.baseOptions.preferedSmoothing)

        iaAccessory.updateAccessoryLayout(true)
        updateSuggestionsBar()
        iaKeyboard.inputView!.layer.shouldRasterize = true
        RawIntensity.touchInterpreter.activate()
    }
    
    
    //MARK:- UIKeyInput functions
    
    public func insertText(text: String) {
        
        let selectedRange = uitrToR(self.selectedTextRange) ?? 0..<0
        print("insertText: \(text), sr: \(selectedRange)")
        let replacement = IAString(text: text, intensity: currentIntensity, attributes: baseAttributes)
        replaceIAStringRange(replacement, range: selectedRange)
        
        //updateSelectionIndicators()
    }
    
    public func deleteBackward() {
        guard let sr = selectedRange else {return}
        if sr.isEmpty {
            if sr.startIndex > 0 {
                if let predecessorIndex = tokenizer.positionFromPosition(selectedTextRange!.start, toBoundary: UITextGranularity.Character, inDirection: UITextStorageDirection.Backward.rawValue) {
                    let start = offsetFromPosition(self.beginningOfDocument, toPosition: predecessorIndex)
                    let delRange = start..<sr.startIndex
                    deleteIAStringRange(delRange)
                } else {
                    print("index matching error in deleteBackwards when tring to find the index for \(sr.startIndex)")
                }
            } else {
                return
            }
        } else {
            deleteIAStringRange(sr)
        }
        //updateSelectionIndicators()
    }
    
    public func hasText() -> Bool {
        return topTV.hasText()
    }
    
    
    //MARK:- UITextInput Functions
    
    
    public func textInRange(range: UITextRange) -> String? {
        return topTV.textInRange(range)
    }
    
    public func replaceRange(range: UITextRange, withText text: String) {
        //topTV.replaceRange(range, withText: text)
        let replacement = IAString(text: text, intensity: currentIntensity, attributes: baseAttributes)
        replaceIAStringRange(replacement, range: selectedRange!)
        //updateSelectionIndicators()
    }
    
    //private var _selectedTextRange:UITextRange?
    public var selectedTextRange: UITextRange? {
        get{return topTV.selectedTextRange}
        set{topTV.selectedTextRange = newValue
            //updateSelectionIndicators()
        }
//        get{return _selectedTextRange}
//        set{_selectedTextRange = newValue
//            updateSelectionIndicators()
//        }

    }
    
    public var markedTextRange: UITextRange?{
        get{return topTV.markedTextRange}
    }
    
    public var markedTextStyle: [NSObject : AnyObject]? {
        get{return topTV.markedTextStyle}
        set{topTV.markedTextStyle = newValue}
    }
    
    public func setMarkedText(markedText: String?, selectedRange: NSRange) {
        topTV.setMarkedText(markedText, selectedRange: selectedRange)
        fatalError("setMarkedText not properlay implemented")
    }
    
    public func unmarkText() {
        topTV.unmarkText()
        fatalError("unmark not properlay implemented")
    }
    
    public var selectionAffinity: UITextStorageDirection {
        get{return topTV.selectionAffinity}
        set{topTV.selectionAffinity = newValue}
    }
    
    public func textRangeFromPosition(fromPosition: UITextPosition, toPosition: UITextPosition) -> UITextRange? {
        return topTV.textRangeFromPosition(fromPosition, toPosition: toPosition)
    }
    
    public func positionFromPosition(position: UITextPosition, offset: Int) -> UITextPosition? {
        return topTV.positionFromPosition(position, offset: offset)
    }
    public func positionFromPosition(position: UITextPosition, inDirection direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
        return topTV.positionFromPosition(position, inDirection: direction, offset: offset)
    }
    
    public var beginningOfDocument: UITextPosition  {
        get{return topTV.beginningOfDocument}
    }
    
    public var endOfDocument: UITextPosition  {
        get{return topTV.endOfDocument}
    }
    
    
    public func comparePosition(position: UITextPosition, toPosition other: UITextPosition) -> NSComparisonResult {
        return topTV.comparePosition(position, toPosition: other)
    }
    
    public func offsetFromPosition(from: UITextPosition, toPosition: UITextPosition) -> Int {
        return topTV.offsetFromPosition(from, toPosition: toPosition)
    }
    
    
    public func positionWithinRange(range: UITextRange, atCharacterOffset offset: Int) -> UITextPosition? {
        return topTV.positionWithinRange(range, atCharacterOffset: offset)
    }
    
    public func positionWithinRange(range: UITextRange, farthestInDirection direction: UITextLayoutDirection) -> UITextPosition? {
        return topTV.positionWithinRange(range, farthestInDirection: direction)
    }
    
    
    public func characterRangeByExtendingPosition(position: UITextPosition, inDirection direction: UITextLayoutDirection) -> UITextRange? {
        return topTV.characterRangeByExtendingPosition(position, inDirection: direction)
    }
    public func baseWritingDirectionForPosition(position: UITextPosition, inDirection direction: UITextStorageDirection) -> UITextWritingDirection {
        return topTV.baseWritingDirectionForPosition(position, inDirection: direction)
    }
    public func setBaseWritingDirection(writingDirection: UITextWritingDirection, forRange range: UITextRange) {
        topTV.setBaseWritingDirection(writingDirection, forRange: range)
    }
    
    
    public func firstRectForRange(range: UITextRange) -> CGRect {
        return topTV.firstRectForRange(range)
    }
    
    public func caretRectForPosition(position: UITextPosition) -> CGRect {
        return topTV.caretRectForPosition(position)
    }
    
    public func closestPositionToPoint(point: CGPoint) -> UITextPosition? {
        return topTV.closestPositionToPoint(point)
    }
    
    public func selectionRectsForRange(range: UITextRange) -> [AnyObject] {
        return topTV.selectionRectsForRange(range)
    }
    
    public func closestPositionToPoint(point: CGPoint, withinRange range: UITextRange) -> UITextPosition? {
        return topTV.closestPositionToPoint(point, withinRange: range)
    }
    public func characterRangeAtPoint(point: CGPoint) -> UITextRange? {
        return topTV.characterRangeAtPoint(point)
    }
    
    
    public var inputDelegate: UITextInputDelegate? {
        get{return topTV.inputDelegate}
        set{topTV.inputDelegate = newValue}
    }
    
    public var tokenizer: UITextInputTokenizer {
        get{return topTV.tokenizer}
    }
    
    public var textInputView: UIView {return self}
    
    //MARK: -Helpers for UITextInput
    
    
    ///Converts the UITextRange of the topTV to a Range<Int>. This is helpful/necessary for bridging between the UITextRange objects of the UITextView class and the ranges we're using with the iaString backing.
    func uitrToR(uitr:UITextRange!)->Range<Int>!{
        guard uitr != nil else {return nil}
        let start = self.offsetFromPosition(self.beginningOfDocument, toPosition: uitr.start)
        let end = offsetFromPosition(self.beginningOfDocument, toPosition: uitr.end)
        return start..<end
    }
    
    ///Converts a Range<Int> to the UITextRange of the topTV. This is helpful/necessary for bridging between the UITextRange objects of the UITextView class and the ranges we're using with the iaString backing.
    func rangeToUITR(range:Range<Int>!)->UITextRange!{
        guard range != nil else {return nil}
        guard let startPos = topTV.positionFromPosition(topTV.beginningOfDocument, offset: range.startIndex), endPos = topTV.positionFromPosition(topTV.beginningOfDocument, offset: range.endIndex) else {return nil}
        return topTV.textRangeFromPosition(startPos, toPosition: endPos)
    }
    
    ///Updates the caret position and selectionViews
    func updateSelectionIndicators(){
        if selectedTextRange != lastSelectedTextRange {
            inputDelegate?.selectionDidChange(self)
        }
        lastSelectedTextRange = selectedTextRange
        if let sr = selectedTextRange {
            caret.hidden = false
            caret.frame = caretRectForPosition(sr.end)
            if !sr.empty {
                let rects = selectionRectsForRange(selectedTextRange!) as! [UITextSelectionRect]
                for (i,rect) in rects.enumerate() {
                    if i >= selectionViews.count {
                        selectionViews.append(UIView(frame: CGRectZero))
                        selectionViews[i].backgroundColor = UIColor.cyanColor().colorWithAlphaComponent(0.3)
                        self.addSubview(selectionViews[i])
                    }
                    selectionViews[i].frame = rect.rect
                    selectionViews[i].hidden = false
                }
            }
        } else {
            caret.hidden = true
            _ = selectionViews.map({$0.hidden = true})
        }
    }
    
    
    ///This function performs a range replace on the iaString and updates affected portions ofthe provided textStorage with the new values. This can be complicated because a replaceRange on an IAString with a multi-character length tokenizer (ie anything but character length) can affect a longer range of the textStorage than is replaced in the IAString. This function tries to avoid modifying longer stretches than is necessary.
    internal func replaceIAStringRange(replacement:IAString, range:Range<Int>){
        guard replacement.length > 0 || !range.isEmpty else {return}
        //guard replacement.length > 0 else {deleteIAStringRange(range); return}
        
        self.iaString.replaceRange(replacement, range: range)
        let modRange = range.startIndex ..< (range.startIndex + replacement.length)
        
        let (extendedModRange,topAttString,botAttString) = self.iaString.convertRangeToLayeredAttStringExtendingBoundaries(modRange, withOverridingOptions: IAKitPreferences.iaStringOverridingOptions)
        
        //textStorage.beginEditing()
        //first we do a replace to align our indices
        //textStorage.replaceCharactersInRange(range.nsRange, withString: replacement.text)
        //let (renderedModRange, replacementAttString) = self.convertRangeToNSAttributedString(modRange, withOverridingOptions: nil)
        //textStorage.replaceCharactersInRange(renderedModRange.nsRange, withAttributedString: replacementAttString)
        //textStorage.endEditing()
        
        topTV.textStorage.beginEditing()
        //first we perform a replace range to line up the indices.
        topTV.textStorage.replaceCharactersInRange(range.nsRange, withString: replacement.text)
        topTV.textStorage.replaceCharactersInRange(extendedModRange.nsRange, withAttributedString: topAttString)
        topTV.textStorage.endEditing()
        
        if botAttString != nil && bottomTV?.hidden == false{
            bottomTV.textStorage.beginEditing()
            //first we perform a replace range to line up the indices.
            bottomTV.textStorage.replaceCharactersInRange(range.nsRange, withString: replacement.text)
            bottomTV.textStorage.replaceCharactersInRange(extendedModRange.nsRange, withAttributedString: topAttString)
            bottomTV.textStorage.endEditing()
        }
        if replacement.attachmentCount > 0 {
            refreshImageLayer()
        } else if iaString.attachmentCount > 0 {
            repositionImageViews()
        }
        //update selection:
        let newTextPos = positionFromPosition(beginningOfDocument, offset: (range.startIndex + replacement.length) )!
        selectedTextRange = textRangeFromPosition(newTextPos, toPosition: newTextPos)
        
        inputDelegate?.textDidChange(self)
    }
    
    ///Performs similarly to replaceRange:iaString, deleting text form the store and updating the displaying textStorage to match, taking into account the interaction between the range deletion and tokenizer to determine and execute whatever changes need to be made.
    internal func deleteIAStringRange(range:Range<Int>){
        guard !range.isEmpty else {return}
        let rangeContainedAttachments:Bool = iaString.rangeContainsAttachments(range)
        
        if iaString.checkRangeIsIndependentInRendering(range, overridingOptions: IAKitPreferences.iaStringOverridingOptions) {
            //range is independent, nothing needs to be recalculated by us.
            iaString.removeRange(range)
            topTV.textStorage.deleteCharactersInRange(range.nsRange)
            if bottomTV?.hidden == false {
                bottomTV.textStorage.deleteCharactersInRange(range.nsRange)
            }
        } else {
            // Deleting the range will affect the rendering of surrounding text, so we need to modify an extended range
            replaceIAStringRange(iaString.emptyCopy(), range: range)
            return
        }
        
        if rangeContainedAttachments {
            refreshImageLayer()
        } else if iaString.attachmentCount > 0 {
            repositionImageViews()
        }
        
        let newTextPos = positionFromPosition(beginningOfDocument, offset: range.startIndex )!
        selectedTextRange = textRangeFromPosition(newTextPos, toPosition: newTextPos)
        
        inputDelegate?.textDidChange(self)
    }
    
    
    //MARK: Other utility funcitons
    
    func rerenderIAString(){
        setIAString(iaString)
    }
    
    
    func updateSuggestionsBar(){
        print("updateSuggestionsBar")
    }
 
    ///Creates a copy and scans for urls and may perform other actions to prepare an IAString for export.
    public func finalizeIAString(updateDefaults:Bool = true)->IAString {
        let result = iaString.copy()
        result.scanLinks()
        if updateDefaults {
            IAKitPreferences.defaultTokenizer = self.iaString.baseOptions.preferedSmoothing
            IAKitPreferences.defaultTransformer = self.iaString.baseOptions.renderScheme
        }
        return result
    }
    
    ///Sets the IATextEditor to an empty IAString and resets properties to the IAKitPreferences defaults. This should be called while the editor is not first responder.
    public func resetEditor(){
        self.setIAString(IAString())
        currentIntensity = IAKitPreferences.defaultIntensity
        baseAttributes = IABaseAttributes(size: IAKitPreferences.defaultTextSize)
        self.iaString.baseOptions.preferedSmoothing = IAKitPreferences.defaultTokenizer
        self.iaString.baseOptions.renderScheme = IAKitPreferences.defaultTransformer
    }
    
}

extension IACompositeTextEditor {
    
    func setTopTVInputDelegate(){
        let intermediateInputDelegate = TextInputDelegateIntermediary()
        intermediateInputDelegate.owningCompositeTE = self
        topTV.inputDelegate = intermediateInputDelegate
    }
    
    private func topTVSelectionDidChange(){
        updateSelectionIndicators()
        inputDelegate?.selectionDidChange(self)
    }
    
    private func topTVSelectionWillChange(){
        inputDelegate?.selectionWillChange(self)
    }
    
    private func topTVTextWillChange(){
        inputDelegate?.textWillChange(self)
    }
    
    private func topTVTextDidChange(){
        inputDelegate?.textDidChange(self)
    }
    
}

private class TextInputDelegateIntermediary:NSObject,UITextInputDelegate {
    weak var owningCompositeTE:IACompositeTextEditor?
    @objc private func textDidChange(textInput: UITextInput?) {
        owningCompositeTE?.topTVTextDidChange()
    }
    @objc private func textWillChange(textInput: UITextInput?) {
        owningCompositeTE?.topTVTextWillChange()
    }
    @objc private func selectionDidChange(textInput: UITextInput?) {
        owningCompositeTE?.topTVSelectionDidChange()
    }
    @objc private func selectionWillChange(textInput: UITextInput?) {
        owningCompositeTE?.topTVTextWillChange()
    }
}


