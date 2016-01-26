//
//  IATextView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/25/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

public class IATextView: UITextView, UITextViewDelegate {
    
    weak public var iaDelegate:IATextViewDelegate?

    public var thumbSizesForAttachments: ThumbSize = .Medium
    
    private(set) public var iaString:IAIntermediate?
    
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
    }
    
    
    ///Prefered method for setting stored IAText for display. By default this assumes text has been prerendered and only needs bounds set on its images. If needsRendering is set as true then this will render according to whatever its included schemeName is.
    public func setIAString(iaString:IAIntermediate, overrideRenderOptions renderOptions:[String:AnyObject]? = nil){
        self.iaString = iaString
        self.attributedText = iaString.convertToNSAttributedString(withOptions: renderOptions)
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
        super.copy()
        let pb = UIPasteboard.generalPasteboard()
        let copiedText = attributedText.attributedSubstringFromRange(selectedRange)
        let archive = NSKeyedArchiver.archivedDataWithRootObject(copiedText)
        let pbDict = pb.items.first as? NSMutableDictionary ?? NSMutableDictionary()
        pbDict.setValue(archive, forKey: UTITypes.IntensityArchive)
        if pb.items.count > 0 {
            pb.items[0] = pbDict
        } else {
            pb.items.append(pbDict)
        }
    }

     

    struct UTITypes {
        static let PlainText = "public.utf8-plain-text"
        static let RTFD = "com.apple.flat-rtfd"
        static let IntensityArchive = "com.mckeemaker.IntensityAttributedTextArchive"
    }
    
}

///Since the IATextView and IATextEditor must subscribe to their own UITextView delegate in order to manage some of the important functionality internally, the IATextViewDelegate is used to expose certain delegate functionality to the outside world. Note: implementing functions intended for IATextEditor in a delegate of an iaTextView will do nothing.
@objc public protocol IATextViewDelegate:class {
    optional func iaTextView(iaTextView: IATextView, shouldInteractWithTextAttachment textAttachment: IATextAttachment, inRange characterRange: NSRange) -> Bool
    ///Pass in the view controller that will present the UIImagePicker or nil if it shouldn't be presented.
    //optional func iaTextEditorRequestsPresentationOfImagePicker(iaTextEditor:IATextEditor)->UIViewController?
}



