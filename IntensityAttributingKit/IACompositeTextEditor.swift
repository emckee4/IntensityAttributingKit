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
    private var imageLayerImageViews:[UIImageView] = []
    ///Use the setIAString function to set the value
    private(set) public var iaString:IAString!
    //private var _renderOptions:[String:AnyObject]?
    //public weak var delegate:IATextViewDelegate?
    
    lazy var baseAttributes:IABaseAttributes = {return IABaseAttributes()}()
    var currentIntensity:Int = 40
    

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
        
    }
    
    
    
    func setupIATV(){
        topTV = UITextView(frame: CGRectZero, textContainer: IATextContainer(size: CGSizeZero))
        topTV.translatesAutoresizingMaskIntoConstraints = false
        topTV.editable = false
        topTV.scrollEnabled = false
        topTV.backgroundColor = UIColor.clearColor()
        
        bottomTV = UITextView(frame: CGRectZero, textContainer: IATextContainer(size: CGSizeZero))//UITextView(frame: CGRectZero)
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
        
        
    }
    
    
    

    
    
    private func clearTextView(){
        stopAnimation()
        topTV.attributedText = nil
        bottomTV.attributedText = nil
        bottomTV.hidden = true
        
        
    }
    
    
    ///Prefered method for setting stored IAText for display. By default this assumes text has been prerendered and only needs bounds set on its images. If needsRendering is set as true then this will render according to whatever its included schemeName is.
    public func setIAString(iaString:IAString!, withCacheIdentifier:String? = nil){
        self.iaString = iaString
        guard iaString != nil else {clearTextView(); return}
        guard iaString.length > 0 else {clearTextView(); return}
        
        
        
        //shouldAnimate = self.animatesIfPossible
        let options = iaString.baseOptions.optionsWithOverridesApplied(IAKitPreferences.iaStringOverridingOptions)
        
//        var options = [String:AnyObject]()
//        if let trans = self.overridingTransformer {
//            options["overrideTransformer"] = trans.rawValue
//            if trans.isAnimatable == false {
//                shouldAnimate = false
//            }
//        } else if iaString.renderScheme.isAnimatable == false {
//            shouldAnimate = false
//        }
//        if let smooth = self.overridingSmoother {
//            options["overrideSmoothing"] = smooth.shortLabel
//        }
        
        
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
    
    public override func intrinsicContentSize() -> CGSize {
        return topTV.intrinsicContentSize()
    }
    
    public override func systemLayoutSizeFittingSize(targetSize: CGSize) -> CGSize {
        return topTV.systemLayoutSizeFittingSize(targetSize)
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
    
    ///////////////////////////////
    ///////////////////////////////
    
    
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override public func becomeFirstResponder() -> Bool {
        return super.becomeFirstResponder()
    }
    
///////////////

    public func insertText(text: String) {
        guard let range = selectedTextRange as? IATextRange else {print("insert text triggered without valid selection range"); return}
        print("insertText: \(selectedTextRange as! IATextRange), text: \(text)")
        let replacement = IAString(text: text, intensity: self.currentIntensity, attributes: baseAttributes)
        
        iaString.replaceRange(replacement, range: (selectedTextRange as! IATextRange).range())
        
        //rerender
        setIAString(iaString)
        
    }
    
    public func deleteBackward() {

    }
    
    public func hasText() -> Bool {
        return true
    }
    
///////////////
    //UITextInput Stored properties
    public var selectedTextRange: UITextRange?
    
    public var markedTextRange: UITextRange?
    
    public var markedTextStyle: [NSObject : AnyObject]?
    
    public var selectionAffinity: UITextStorageDirection
    
    public var beginningOfDocument: UITextPosition {return IATextPosition(0)}
    public var endOfDocument: UITextPosition {return IATextPosition(self.iaString.length)}
    public var inputDelegate: UITextInputDelegate?
    public lazy var tokenizer: UITextInputTokenizer = {
        return UITextInputStringTokenizer(textInput: self)
    }()
    

    //UITextInput functions
    
    public func textInRange(range: UITextRange) -> String? {
        guard let intRange = (range as? IATextRange)?.range() else {
            fatalError("non IATextRange passed in to textInRange")
        }
        return iaString.text.subStringFromRange(intRange)
    }
    
    public func replaceRange(range: UITextRange, withText text: String) {
        //need to modify the iaString, then figure out which ranges change in the rendering
        print("replaceRange: \(range as! IATextRange), with text: \(text)")
        let replacement = IAString(text: text, intensity: self.currentIntensity, attributes: baseAttributes)
        
        iaString.replaceRange(replacement, range: (range as! IATextRange).range())
        
        //rerender
        setIAString(iaString)
        
        
    }
    
    
    public func setMarkedText(markedText: String?, selectedRange: NSRange) {
        print("setMarkedText: \(markedText)")
        //textView.setMarkedText(markedText, selectedRange: selectedRange)
    }
    
    public func unmarkText() {
        print("unmarkText")
    }
    
    
    public func textRangeFromPosition(fromPosition: UITextPosition, toPosition: UITextPosition) -> UITextRange? {
        guard let fromPosition = fromPosition as? IATextPosition, toPosition = toPosition as? IATextPosition else {fatalError("non IATextPosition")}
        return IATextRange(start: fromPosition, end: toPosition)
    }
    
    public func positionFromPosition(position: UITextPosition, offset: Int) -> UITextPosition? {
        guard let loc = (position as? IATextPosition)?.position else {fatalError("non IATextPosition")}
        let iatp = IATextPosition(loc + offset)
        if iatp >= (self.beginningOfDocument as! IATextPosition) && iatp <= (self.endOfDocument as! IATextPosition) {
            return iatp
        } else {
            return nil
        }
    }
    
    public func positionFromPosition(position: UITextPosition, inDirection direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
        guard direction == UITextLayoutDirection.Right else {fatalError("positionFromPosition received non forward UITextLayoutDirection")}
        return positionFromPosition(position, offset: offset)
    }

    
    public func comparePosition(position: UITextPosition, toPosition other: UITextPosition) -> NSComparisonResult {
        let p1 = (position as! IATextPosition).position
        let p2 = (other as! IATextPosition).position
        if p1 < p2 { return NSComparisonResult.OrderedAscending }
        if p1 > p2 { return NSComparisonResult.OrderedDescending }
        return NSComparisonResult.OrderedSame
    }
    
    public func offsetFromPosition(from: UITextPosition, toPosition: UITextPosition) -> Int {
        return (toPosition as! IATextPosition).position - (from as! IATextPosition).position
    }
    
    

    
    public func positionWithinRange(range: UITextRange, farthestInDirection direction: UITextLayoutDirection) -> UITextPosition? {
        guard direction == UITextLayoutDirection.Right else {fatalError("positionWithinRange received non forward UITextLayoutDirection")}
        return range.end
    }
    
    
    public func characterRangeByExtendingPosition(position: UITextPosition, inDirection direction: UITextLayoutDirection) -> UITextRange? {
        guard direction == UITextLayoutDirection.Right else {fatalError("characterRangeByExtendingPosition received non forward UITextLayoutDirection")}
        return textRangeFromPosition(position, toPosition: endOfDocument)
    }
    public func baseWritingDirectionForPosition(position: UITextPosition, inDirection direction: UITextStorageDirection) -> UITextWritingDirection {
        guard direction == UITextStorageDirection.Forward else {fatalError("baseWritingDirectionForPosition received non forward UITextStorageDirection")}
        return UITextWritingDirection.LeftToRight
    }
    public func setBaseWritingDirection(writingDirection: UITextWritingDirection, forRange range: UITextRange) {
        guard writingDirection != UITextWritingDirection.RightToLeft else {fatalError("setBaseWritingDirection received UITextWritingDirection.RightToLeft ")}
        
    }

    
    public func firstRectForRange(range: UITextRange) -> CGRect {
        let topTVRange = convertIATextRangeToTopTVTextRange(range as! IATextRange)
        return topTV.firstRectForRange(topTVRange)
    }
    
    public func caretRectForPosition(position: UITextPosition) -> CGRect {
        let topTVPos = convertIATextPositionToTopTVTextPosition(position as! IATextPosition)
        return topTV.caretRectForPosition(topTVPos)
    }
    
    public func closestPositionToPoint(point: CGPoint) -> UITextPosition? {
        if let topTVPos = topTV.closestPositionToPoint(point) {
            return convertTopTVTextPositionToIATextPosition(topTVPos)
        }
        return nil
    }
    
    public func selectionRectsForRange(range: UITextRange) -> [AnyObject] {
        let topTVRanges = topTV.selectionRectsForRange(range)
        return topTVRanges.map({convertTopTVTextRangeToIATextRange($0 as! UITextRange)})
    }
    
    public func closestPositionToPoint(point: CGPoint, withinRange range: UITextRange) -> UITextPosition? {
        let topRange = convertIATextRangeToTopTVTextRange(range as! IATextRange)
        
        if let topTVPos = topTV.closestPositionToPoint(point, withinRange: topRange) {
            return convertTopTVTextPositionToIATextPosition(topTVPos)
        }
        return nil
    }
    public func characterRangeAtPoint(point: CGPoint) -> UITextRange? {
        if let topRange = topTV.characterRangeAtPoint(point) {
            convertTopTVTextRangeToIATextRange(topRange)
        }
        return nil
    }
    
//    non-required
//    public func positionWithinRange(range: UITextRange, atCharacterOffset offset: Int) -> UITextPosition? {
//        return textView.positionWithinRange(range, atCharacterOffset: offset)
//    }
    
    
    
    
    ///Helper function which converts the topTextView's UITextPosition to an IATextPosition used by the iaString backing store. The topTV should be in sync with the iaString or bad things will happen.
    private func convertTopTVTextPositionToIATextPosition(topTVPos:UITextPosition)->IATextPosition{
        return IATextPosition(topTV.offsetFromPosition(topTV.beginningOfDocument, toPosition: topTVPos))
    }
    ///Helper function which converts the topTextView's UITextRange to an IATextRange used by the iaString backing store. The topTV should be in sync with the iaString or bad things will happen.
    private func convertTopTVTextRangeToIATextRange(topTVRange:UITextRange)->IATextRange{
        return IATextRange(start: convertTopTVTextPositionToIATextPosition(topTVRange.start),end: convertTopTVTextPositionToIATextPosition(topTVRange.end))
    }
    
    ///Helper function which converts an iaTextPosition of the iaString to the topTextView's UITextPosition. The topTV should be in sync with the iaString or bad things will happen.
    private func convertIATextPositionToTopTVTextPosition(textPos:IATextPosition)->UITextPosition!{
        return topTV.positionFromPosition(topTV.beginningOfDocument, offset: textPos.position)
    }
   ///Helper function which converts an iaTextRange of the iaString to the topTextView's UITextRange. The topTV should be in sync with the iaString or bad things will happen.
    private func convertIATextRangeToTopTVTextRange(textRange:IATextRange)->UITextRange{
        return topTV.textRangeFromPosition(convertIATextPositionToTopTVTextPosition(textRange._start), toPosition: convertIATextPositionToTopTVTextPosition(textRange._end))!
    }
 
}




