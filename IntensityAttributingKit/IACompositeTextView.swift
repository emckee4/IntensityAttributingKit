//
//  IACompositeTextView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/29/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

public class IACompositeTextView: IACompositeBase {

    public weak var delegate:IATextViewDelegate?
    
    var tapGestureRecognizer:UITapGestureRecognizer!
    
    //private(set) public var selected:Bool = false
    
//    var overridingTransformer:IntensityTransformers? = IAKitPreferences.overridesTransformer
//    var overridingSmoother:IAStringTokenizing? = IAKitPreferences.overridesTokenizer
    
    
    
    override func setupGestureRecognizers(){
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(IACompositeTextView.tapDetected(_:)))
        
        self.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    public func setIAString(iaString:IAString!, withCacheIdentifier:String? = nil){
        if withCacheIdentifier == nil {
            super.setIAString(iaString)
        } else {
            print("setIAString using cache identifier not yet implemented")
            
            
        }
    }
    
    
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    public convenience init(){
        self.init(frame:CGRectZero)
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
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
    
    
//    public override func selectAll(sender: AnyObject?) {
//        guard selectable == true else {return}
//        self.selected = true
//        self.becomeFirstResponder()
//        //use entire view as selection rect:
//        selectionView.updateSelections([self.bounds], caretRect: nil, markEnds: false)
//        // present menu
//        if sender is UITapGestureRecognizer {
//            let targetRect = CGRectMake(self.bounds.midX, self.bounds.midY, 10, 10)
//            let menu = UIMenuController.sharedMenuController()
//            menu.update()
//            menu.setTargetRect(targetRect, inView: selectionView)
//            menu.setMenuVisible(true, animated: true)
//        }
//    }
//    
//    func deselect(){
//        selected = false
//        selectionView.clearSelection()
//        UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
//    }
//    
//    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
//        if action == #selector(NSObject.copy(_:)) && self.iaString?.length > 0{
//            return true
//        }
//        return super.canPerformAction(action, withSender: sender)
//    }
//    
//    public override func copy(sender: AnyObject?) {
//        UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
//        guard iaString != nil && iaString.length > 0 else {return}
//        
//        let pb = UIPasteboard.generalPasteboard()
//        let copiedText = iaString.text
//        let iaArchive = IAStringArchive.archive(iaString.copy(true))
//        var pbItem:[String:AnyObject] = [:]
//        pbItem[UTITypes.PlainText] = copiedText
//        pbItem[UTITypes.IAStringArchive] = iaArchive
//        pb.addItems([pbItem])
//    }
    
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




