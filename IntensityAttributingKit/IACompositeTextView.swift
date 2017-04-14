//
//  IACompositeTextView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/29/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

/*
 IACompositeTextView implements very little beyond what is implemented by IACompositeBase. It's intended as a lighter alternative to IACompositeTextEditor for cases where only viewing and basic interaction (copy, view links, attachments) are needed.
 
 */
open class IACompositeTextView: IACompositeBase {

    open weak var delegate:IATextViewDelegate?
    
    var tapGestureRecognizer:UITapGestureRecognizer!
    var longPressGestureRecognizer:UILongPressGestureRecognizer!
    
    override func setupGestureRecognizers(){
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(IACompositeTextView.tapDetected(_:)))
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(IACompositeTextView.longPressDetected(_:)))
        
        self.addGestureRecognizer(tapGestureRecognizer)
        self.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    ///This isn't yet implemented differently than the ordinary setIAString, though it's intended to allow for some caching of layout information in situations where an IAString is repeatedly redrawn in IACompositeTextViews (e.g. in a table view).
    open func setIAString(_ iaString:IAString!, withCacheIdentifier:String){
        //print("setIAString using cache identifier not yet implemented")
        ///cache should store some rendering info and probably some sizing info, eg previously calculated size for size values. any change to the data or default renderings should invalidate the cache. (Changing global prefs should probably emit a notification of such)
        super.setIAString(iaString)
    }
    
    
    override func setupIATV() {
        super.setupIATV()
        NotificationCenter.default.addObserver(self, selector: #selector(IACompositeTextView.menuWillHide(_:)), name: NSNotification.Name.UIMenuControllerWillHideMenu, object: nil)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    public convenience init(){
        self.init(frame:CGRect.zero)
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    ///Tap on an attachment or url will cause those to be passed to the delegate. Tap elsewhere deselects.
    func tapDetected(_ sender:UITapGestureRecognizer!){
        if sender?.state == .ended {
            let location = sender.location(in: topTV)
            guard let touchIndex = topTV.characterIndexAtPoint(location) else {deselect(); return}  //or make this select all/deselect all
            if let attachment = iaString.attachments[touchIndex] {
                self.delegate?.iaTextView?(self, userInteractedWithAttachment: attachment, inRange: NSMakeRange(touchIndex, 1))
                return
            } else if let (url, urlRange) = iaString.urlAtIndex(touchIndex) {
                self.delegate?.iaTextView?(self, userInteractedWithURL: url, inRange: urlRange.nsRange)
            } else {
                self.deselect()
            }
        }
    }

    ///A longpress will select all
    func longPressDetected(_ sender:UILongPressGestureRecognizer!){
        if sender?.state == .began {
            let location = sender.location(in: topTV)
            guard let touchIndex = topTV.characterIndexAtPoint(location) else {deselect(); return}  //or make this select all/deselect all
            //if let attachment = iaString.attachments[touchIndex] {
            if iaString.attachments[touchIndex] != nil{
                //self.delegate?.iaTextView?(self, userInteractedWithAttachment: attachment, inRange: NSMakeRange(touchIndex, 1))
                selectedRange = touchIndex..<(touchIndex + 1)
                _ = presentMenu(nil)
            } else if let (_, urlRange) = iaString.urlAtIndex(touchIndex) {
                //self.delegate?.iaTextView?(self, userInteractedWithURL: url, inRange: urlRange.nsRange)
                selectedRange = urlRange
                _ = presentMenu(nil)
            } else {
                self.selectAll(sender)
            }
        }
    }
    
    open override var canBecomeFirstResponder : Bool {
        return true
    }

    func menuWillHide(_ notification:Notification!){
        deselect()
    }
    
}





///Since the IATextView and IATextEditor must subscribe to their own UITextView delegate in order to manage some of the important functionality internally, the IATextViewDelegate is used to expose certain delegate functionality to the outside world. Note: implementing functions intended for IATextEditor in a delegate of an iaTextView will do nothing.
@objc public protocol IATextViewDelegate:class {
    //optional func iaTextView(iaTextView: IACompositeTextView, shouldInteractWithTextAttachment textAttachment: IATextAttachment, inRange characterRange: NSRange) -> Bool
    ///Pass in the view controller that will present the UIImagePicker or nil if it shouldn't be presented.
    //optional func iaTextEditorRequestsPresentationOfImagePicker(iaTextEditor:IATextEditor)->UIViewController?
    
    @objc optional func iaTextView(_ atTextView: IACompositeTextView, userInteractedWithAttachment attachment:IATextAttachment, inRange: NSRange)
    @objc optional func iaTextView(_ atTextView: IACompositeTextView, userInteractedWithURL URL: URL, inRange characterRange: NSRange)
}




