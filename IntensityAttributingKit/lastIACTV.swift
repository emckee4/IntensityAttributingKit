//
//  IACompositeTextView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/29/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//
/*
import UIKit

public class IACompositeTextView: UIView {
    ///The selection view holds the selection rects
    private var selectionView:IASelectionView
    var topTV:ThinTextView
    var bottomTV:ThinTextView
    ///The imageLayer coordinate system is positioned to be the same as that of the textContainers. i.e. it's subject to the textContainerInset property.
    ///The imageLayer view holds the actual rendered textAttachments. This allows us to show them opaquely regardless of where the textViews are in their animation cycles. This also allows us to render these asynchronously if necessary.
    private var imageLayer:UIView
    private var imageLayerImageViews:[UIImageView] = []
    ///Use the setIAString function to set the value
    private(set) public var iaString:IAString!
    //private var _renderOptions:[String:AnyObject]?
    public weak var delegate:IATextViewDelegate?
    
    var tapGestureRecognizer:UITapGestureRecognizer!
    
    public var selectable:Bool = true
    private(set) public var selected:Bool = false
    
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
    
    var overridingTransformer:IntensityTransformers? = IAKitPreferences.overridesTransformer
    var overridingSmoother:IAStringTokenizing? = IAKitPreferences.overridesTokenizer
    
    public var textContainerInset:UIEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0) {
        didSet {
            if textContainerInset != oldValue {
                setNeedsLayout() // layoutSubviews will update the imageLayer position
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()   //should this be called before or after?
        //set frames for contained objects
        let frameWithInset = UIEdgeInsetsInsetRect(self.bounds, textContainerInset)

        selectionView.frame = frameWithInset
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
        
        //bottomTV.userInteractionEnabled = false
        bottomTV.backgroundColor = UIColor.clearColor()
        bottomTV.hidden = true
        
        //imageLayer.userInteractionEnabled = false
        imageLayer.layer.drawsAsynchronously = true
        imageLayer.clipsToBounds = true
        imageLayer.hidden = true
        
        self.addSubview(imageLayer)
        self.addSubview(bottomTV)
        self.addSubview(topTV)
        self.addSubview(selectionView)
        
        setupGestureRecognizers()
    }
    
    func setupGestureRecognizers(){
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(IACompositeTextView.tapDetected(_:)))
        
        self.addGestureRecognizer(tapGestureRecognizer)
        
    }
    

    
    
    ///Prefered method for setting stored IAText for display. By default this assumes text has been prerendered and only needs bounds set on its images. If needsRendering is set as true then this will render according to whatever its included schemeName is.
    public func setIAString(iaString:IAString!, withCacheIdentifier:String? = nil){
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
    
    
    public override func intrinsicContentSize() -> CGSize {
        return topTV.intrinsicContentSize()
    }
    
    public override func systemLayoutSizeFittingSize(targetSize: CGSize) -> CGSize {
        return topTV.systemLayoutSizeFittingSize(targetSize)
    }
        

    
    
    public override init(frame: CGRect) {
        topTV = ThinTextView()
        bottomTV = ThinTextView()
        selectionView = IASelectionView()
        imageLayer = UIView()
        
        
        super.init(frame: frame)
        setupIATV()
    }
    
    required public init?(coder aDecoder: NSCoder) {
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
    
    
    func tapDetected(sender:UITapGestureRecognizer!){
        if sender?.state == .Ended {
            let location = sender.locationInView(topTV)
            guard let touchIndex = topTV.characterIndexAtPoint(location) else {deselect(); return}  //or make this select all/deselect all
            if let attachment = iaString.attachments[touchIndex] {
                self.delegate?.iaTextView?(self, userInteractedWithAttachment: attachment, inRange: NSMakeRange(touchIndex, 1))
                return
            } else if let (url, urlRange) = iaString.urlAtIndex(touchIndex) {
                self.delegate?.iaTextView?(self, userInteractedWithURL: url, inRange: urlRange.nsRange)
            } else {
                self.selectAll(sender)
            }
        }
    }

    
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    
    public override func selectAll(sender: AnyObject?) {
        guard selectable == true else {return}
        self.selected = true
        self.becomeFirstResponder()
        //use entire view as selection rect:
        let selectionBounds = convertRect(self.bounds, toView: selectionView)
        selectionView.updateSelections([selectionBounds], caretPosition: nil)
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
        selected = false
        selectionView.updateSelections([], caretPosition: nil)
        UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
    }
    
    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(NSObject.copy(_:)) && self.iaString?.length > 0{
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    public override func copy(sender: AnyObject?) {
        UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
        guard iaString != nil && iaString.length > 0 else {return}
        
        let pb = UIPasteboard.generalPasteboard()
        let copiedText = iaString.text
        let iaArchive = IAStringArchive.archive(iaString.copy(true))
        var pbItem:[String:AnyObject] = [:]
        pbItem[UTITypes.PlainText] = copiedText
        pbItem[UTITypes.IAStringArchive] = iaArchive
        pb.addItems([pbItem])
    }
    
}




//extension IACompositeTextView {
//    
//    ///Allows iaDelegate to control interaction with textAttachment. Defaults to true
//    public func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
//        if let iaTV = textView.superview as? IACompositeTextView, textAttachment = textAttachment as? IATextAttachment {
//            return delegate?.iaTextView?(iaTV, shouldInteractWithTextAttachment: textAttachment, inRange: characterRange) ?? true
//        }
//        return true
//    }
//    
//    public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
//        return true
//    }
//    
//    
//}






///Since the IATextView and IATextEditor must subscribe to their own UITextView delegate in order to manage some of the important functionality internally, the IATextViewDelegate is used to expose certain delegate functionality to the outside world. Note: implementing functions intended for IATextEditor in a delegate of an iaTextView will do nothing.
@objc public protocol IATextViewDelegate:class {
    //optional func iaTextView(iaTextView: IACompositeTextView, shouldInteractWithTextAttachment textAttachment: IATextAttachment, inRange characterRange: NSRange) -> Bool
    ///Pass in the view controller that will present the UIImagePicker or nil if it shouldn't be presented.
    //optional func iaTextEditorRequestsPresentationOfImagePicker(iaTextEditor:IATextEditor)->UIViewController?
    
    optional func iaTextView(atTextView: IACompositeTextView, userInteractedWithAttachment attachment:IATextAttachment, inRange: NSRange)
    optional func iaTextView(atTextView: IACompositeTextView, userInteractedWithURL URL: NSURL, inRange characterRange: NSRange)
}

*/


