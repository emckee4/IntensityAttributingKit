//
//  IACompositeTextView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/29/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

class IACompositeTextView: UIView {
    
    var topTV:UITextView!
    var bottomTV:UITextView!
    ///The imageLayer coordinate system is positioned to be the same as that of the textContainers. i.e. it's subject to the textContainerInset property.
    var imageLayer:UIView!
    
    var iaString:IAString!
    weak var delegate:IATextViewDelegate?
    
    var animatesIfPossible:Bool = true
    
    
    
    var textContainerInset:UIEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0) {
        didSet {
            if textContainerInset != oldValue {
                topTV.textContainerInset = textContainerInset
                bottomTV?.textContainerInset = textContainerInset
                setNeedsLayout() // layoutSubviews will update the imageLayer position
            }
        }
    }
    
    override func layoutSubviews() {
        //set frames for contained objects
        topTV.frame = self.bounds
        bottomTV?.frame = self.bounds
        imageLayer?.frame = CGRect(x: textContainerInset.left, y: textContainerInset.top,
               width: self.bounds.width - (textContainerInset.left + textContainerInset.right),
               height: self.bounds.height - (textContainerInset.top + textContainerInset.bottom)
        )
        //super.layoutSubviews()   //should this be called before or after?
    }
    
    
    
    func setupIATV(){
        topTV = UITextView(frame: CGRectZero)
        topTV.translatesAutoresizingMaskIntoConstraints = false
        topTV.editable = false
        
        bottomTV = UITextView(frame: CGRectZero)
        bottomTV.translatesAutoresizingMaskIntoConstraints = false
        bottomTV.editable = false
        bottomTV.userInteractionEnabled = false
        
        imageLayer = UIView(frame:CGRectZero)
        imageLayer.translatesAutoresizingMaskIntoConstraints = false
        imageLayer.userInteractionEnabled = false
        
        self.addSubview(imageLayer)
        self.addSubview(bottomTV)
        self.addSubview(topTV)
        topTV.delegate = self
        
        
    }
    
    
    
    func startAnimation(){
        
    }
    
    
    
    
    
    ///Prefered method for setting stored IAText for display. By default this assumes text has been prerendered and only needs bounds set on its images. If needsRendering is set as true then this will render according to whatever its included schemeName is.
    public func setIAString(iaString:IAString, withCacheIdentifier:String? = nil,overrideRenderOptions renderOptions:[String:AnyObject]? = nil){
        
        
        
        
//        self._iaString = iaString
//        if renderOptions != nil {
//            self._renderOptions = renderOptions
//        } else {
//            _renderOptions = [:]
//            if let overTrans = IAKitOptions.overridesTransformer {
//                self._renderOptions!["overrideTransformer"] = overTrans.rawValue
//            }
//            if let overToke = IAKitOptions.overridesTokenizer {
//                
//                self._renderOptions!["overrideSmoothing"] = overToke.shortLabel
//            }
//            
//        }
//        
//        self.iaString?.thumbSize = self.thumbSizesForAttachments
//        self.attributedText = self._iaString?.convertToNSAttributedString(withOptions: _renderOptions)
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
    
    
}




extension IACompositeTextView: UITextViewDelegate {
    
    ///Allows iaDelegate to control interaction with textAttachment. Defaults to true
    public func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        if let iaTV = textView as? IATextView, textAttachment = textAttachment as? IATextAttachment {
            return delegate?.iaTextView?(iaTV, shouldInteractWithTextAttachment: textAttachment, inRange: characterRange) ?? true
        }
        return true
    }
    
    public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return true
    }
    
    
}
