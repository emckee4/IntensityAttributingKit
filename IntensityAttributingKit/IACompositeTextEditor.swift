//
//  IACompositeTextEditor.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/3/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

class IACompositeTextEditor:UIView{
    
        
        var topTV:UITextView!
        var bottomTV:UITextView!
        ///The imageLayer coordinate system is positioned to be the same as that of the textContainers. i.e. it's subject to the textContainerInset property.
        var imageLayer:UIView!
        private var imageLayerImageViews:[UIImageView] = []
        ///Use the setIAString function to set the value
        private(set) public var iaString:IAString!
        //private var _renderOptions:[String:AnyObject]?
        public weak var delegate:IATextViewDelegate?
        
        public var animatesIfPossible:Bool = true
        private var shouldAnimate:Bool = false
        public var isAnimating:Bool {
            return (topTV.layer.animationForKey("opacity") != nil) || (bottomTV.layer.animationForKey("opacity") != nil)
        }
        
        public var baseAnimationDuration:NSTimeInterval = 1
        
        public var thumbSizesForAttachments: ThumbSize = .Medium {
            //didSet {self.iaString?.thumbSize = thumbSizesForAttachments}
            didSet{(topTV.textContainer as? IATextContainer)?.preferedThumbSize = thumbSizesForAttachments }
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
            
        }
        
        
        
        func setupIATV(){
            topTV = UITextView(frame: CGRectZero, textContainer: IATextContainer(size: CGSizeZero))
            topTV.translatesAutoresizingMaskIntoConstraints = false
            topTV.editable = false
            topTV.scrollEnabled = false
            topTV.backgroundColor = UIColor.clearColor()
            topTV.userInteractionEnabled = false
            
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
            
            
            
            shouldAnimate = self.animatesIfPossible
            
            var options = [String:AnyObject]()
            if let trans = self.overridingTransformer {
                options["overrideTransformer"] = trans.rawValue
                if trans.isAnimatable == false {
                    shouldAnimate = false
                }
            } else if iaString.renderScheme.isAnimatable == false {
                shouldAnimate = false
            }
            if let smooth = self.overridingSmoother {
                options["overrideSmoothing"] = smooth.shortLabel
            }
            
            self.iaString?.thumbSize = self.thumbSizesForAttachments
            //self.attributedText = self._iaString?.convertToNSAttributedString(withOptions: _renderOptions)
            let attStrings = self.iaString.convertToNSAttributedStringsForLayeredDisplay(withOptions: options)
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
            if shouldAnimate {
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
            guard shouldAnimate else {return}
            guard iaString != nil && iaString.length > 0 else {return}
            let trans:IntensityTransformers = overridingTransformer ?? iaString.renderScheme
            guard let animatingTransformer = (trans.transformer as? AnimatedIntensityTransforming.Type) else {return}
            // get properties, adjust offsets, start animation
            let baseOffset = NSProcessInfo.processInfo().systemUptime % baseAnimationDuration
            if animatingTransformer.topLayerAnimates {
                let topAnimation = IACompositeTextView.generateOpacityAnimation(0, endAlpha: 1.0, duration: baseAnimationDuration, offset: baseOffset)
                topTV.layer.addAnimation(topAnimation, forKey: "opacity")
            } else {
                topTV.layer.removeAnimationForKey("opacity")
            }
            if animatingTransformer.bottomLayerAnimates{
                let bottomOffset = baseOffset + (animatingTransformer.bottomLayerTimingOffset * baseAnimationDuration)
                let bottomAnimation = IACompositeTextView.generateOpacityAnimation(0, endAlpha: 1.0, duration: baseAnimationDuration, offset: bottomOffset)
                bottomTV.layer.addAnimation(bottomAnimation, forKey: "opacity")
            } else {
                bottomTV.layer.removeAnimationForKey("opacity")
            }
            
        }
        
        public func stopAnimation(){
            shouldAnimate = false
            topTV.layer.removeAnimationForKey("opacity")
            bottomTV.layer.removeAnimationForKey("opacity")
            //TODO: may want to set final value for opacity here
        }
        
        
        //    textAlignment
        //
        //    typingAttributes
        //
        //    linkTextAttributes
        //
        
        //
        //    selectedRange
        //    - scrollRangeToVisible:
        //    clearsOnInsertion
        //
        //    selectable
        //
        //    override public func copy(sender: AnyObject?){
        //
        //    }
        
        
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
        
}
    
    
    
