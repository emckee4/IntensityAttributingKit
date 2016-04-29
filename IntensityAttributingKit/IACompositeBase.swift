//
//  IACompositeBase.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/19/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


public class IACompositeBase:UIView {
    
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
    
    public var selectable:Bool = true
    //private(set) public var selected:Bool = false
    
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()   //should this be called before or after?
        //set frames for contained objects
        let frameWithInset = UIEdgeInsetsInsetRect(self.bounds, textContainerInset)
        
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
    
    func rerenderIAString(){
        setIAString(iaString)
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
    
    
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }
    

    

    
    
    
}
