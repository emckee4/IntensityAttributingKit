//
//  IATextView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/25/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

//import UIKit
/**The IATextView is (currently) a subclass of UITextView intended for the viewing (but not editing) of IAStrings. Setting of IAStrings should be done with the setIAString method
 */
/*

public class IATextView: UITextView, UITextViewDelegate {
    
    weak public var iaDelegate:IATextViewDelegate?

    public var thumbSizesForAttachments: ThumbSize = .Medium {
        didSet {self.iaString?.thumbSize = thumbSizesForAttachments}
    }
    
    private var _renderOptions:[String:AnyObject]?
    private var _iaString:IAString?
    public var iaString:IAString? {
        set{_iaString = newValue; self.attributedText = _iaString!.convertToNSAttributedString(withOptions:_renderOptions)}
        get{return _iaString}
    }
    
    //MARK:-inits and setup
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPressureTextView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPressureTextView()
    }
    
    
    func setupPressureTextView(){
        self.editable = false
        self.selectable = true
        self.layer.cornerRadius = 10.0
        self.textContainerInset = UIEdgeInsetsMake(7.0, 2.0, 7.0, 2.0)
        self.delegate = self
        self.layoutManager.allowsNonContiguousLayout = false
        self.layer.drawsAsynchronously = false
    }
    
    
    ///Prefered method for setting stored IAText for display. By default this assumes text has been prerendered and only needs bounds set on its images. If needsRendering is set as true then this will render according to whatever its included schemeName is.
    public func setIAString(iaString:IAString, withCacheIdentifier:String? = nil,overrideRenderOptions renderOptions:[String:AnyObject]? = nil){
        self._iaString = iaString
        if renderOptions != nil {
            self._renderOptions = renderOptions
        } else {
            _renderOptions = [:]
            if let overTrans = IAKitPreferences.overridesTransformer {
                self._renderOptions!["overrideTransformer"] = overTrans.rawValue
            }
            if let overToke = IAKitPreferences.overridesTokenizer {

                self._renderOptions!["overrideSmoothing"] = overToke.shortLabel
            }
            
        }
        
        self.iaString?.thumbSize = self.thumbSizesForAttachments
        self.attributedText = self._iaString?.convertToNSAttributedString(withOptions: _renderOptions)
    }
    
    ///Allows iaDelegate to control interaction with textAttachment. Defaults to true
    public func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        if let iaTV = textView as? IATextView, textAttachment = textAttachment as? IATextAttachment {
            return iaDelegate?.iaTextView?(iaTV, shouldInteractWithTextAttachment: textAttachment, inRange: characterRange) ?? true
        }
        return true
    }
    
    public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return true
    }
    
    //MARK:- Copy
    
    override public func copy(sender: AnyObject?){
        let pb = UIPasteboard.generalPasteboard()
        let range = self.selectedRange.toRange()!
        let copiedIA = self.iaString!.iaSubstringFromRange(range)
        let copiedText = copiedIA.text
        let iaArchive = IAStringArchive.archive(copiedIA)
        
        var pbItem:[String:AnyObject] = [:]
        pbItem[UTITypes.PlainText] = copiedText
        pbItem[UTITypes.IAStringArchive] = iaArchive
        pb.addItems([pbItem])
    }

     

    struct UTITypes {
        static let PlainText = "public.utf8-plain-text"
        static let RTFD = "com.apple.flat-rtfd"
        static let IAStringArchive = "com.mckeemaker.IAStringArchive"
    }
    
}

///Since the IATextView and IATextEditor must subscribe to their own UITextView delegate in order to manage some of the important functionality internally, the IATextViewDelegate is used to expose certain delegate functionality to the outside world. Note: implementing functions intended for IATextEditor in a delegate of an iaTextView will do nothing.
@objc public protocol IATextViewDelegate:class {
    optional func iaTextView(iaTextView: IATextView, shouldInteractWithTextAttachment textAttachment: IATextAttachment, inRange characterRange: NSRange) -> Bool
    ///Pass in the view controller that will present the UIImagePicker or nil if it shouldn't be presented.
    //optional func iaTextEditorRequestsPresentationOfImagePicker(iaTextEditor:IATextEditor)->UIViewController?
}

*/

