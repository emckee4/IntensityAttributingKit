//
//  IATextEditor.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/31/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

public class IATextEditor: IATextView {
    
    
    internal(set) var baseAttributes:IABaseAttributes = IABaseAttributes(size: IAKitOptions.singleton.defaultTextSize)
    
    internal(set) var currentTransformer:IntensityTransformers = IAKitOptions.singleton.defaultScheme {
        didSet {if currentTransformer != oldValue && self.inputAccessoryViewController != nil {
            self.iaAccessory.setTransformKeyForScheme(withName: currentTransformer.transformer.schemeName)
            }
        }
    }
    
    internal(set) var defaultIntensity:Int = IAKitOptions.singleton.defaultIntensity {
        didSet {iaAccessory.updateDisplayedIntensity(defaultIntensity)}
    }
    
    
    //var intensityChangesDynamically = true
    
    
    weak public var editorDelegate:IATextEditorDelegate?
    
    //define IAKeyboardDelegate: directly modify the store, bypassing UITextView accessors
    
    //IAAccessoryDelegate: allows accessory to access and modify attributes
    
    //internal delegate can be used for tracking changes attempted by the system keyboard
    
    
    private var iaAccessory:IAAccessoryVC {
        return IAKitOptions.singleton.accessory
    }
    
    private var iaKeyboardVC:IAKeyboard {
        return IAKitOptions.singleton.keyboard
    }
    
    
    private var _inputVC:UIInputViewController?
    override public var inputViewController:UIInputViewController? {
        set {self._inputVC = newValue}
        get {return self._inputVC}
    }
    
    override public var inputAccessoryViewController:UIInputViewController? {
        get {return self.iaAccessory}
    }
    
    ///returns true if IAKeyboard is presented by this, false if system keyboard, and nil if this is not first responder
    var keyboardIsIAKeyboard:Bool?{
        guard self.isFirstResponder() else {return nil}
        return inputViewController == iaKeyboardVC
    }
    
    //////////
    
    public override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            //iaAccessory = IAKitOptions.singleton.accessory
            iaAccessory.delegate = self
            //iaKeyboardVC = IAKitOptions.singleton.keyboard
            _inputVC = iaKeyboardVC
            self.iaAccessory.setTransformKeyForScheme(withName: currentTransformer.transformer.schemeName)
            self.iaAccessory.setTokenizerKeyValue(self.iaString!.preferedSmoothing)
            iaKeyboardVC.delegate = self
            return true
        }
        return false
    }
    public override func resignFirstResponder() -> Bool {
        if super.resignFirstResponder() {
            //iaAccessory.delegate = nil
            //iaAccessory = nil
            //iaKeyboardVC = nil
            return true
        }
        return false
    }
    
    internal override func setupPressureTextView(){
        self.editable = true
        self.keyboardDismissMode = .Interactive
        //iaAccessory?.delegate = self
        self.inputViewController = iaKeyboardVC
        self.delegate = self
        self.layer.cornerRadius = 10.0
        self.textContainerInset = UIEdgeInsetsMake(7.0, 2.0, 7.0, 2.0)
        currentTransformer = IAKitOptions.singleton.defaultScheme
        self.allowsEditingTextAttributes = true
        self.setIAString(IAString())
        self.setFlatAtts()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuNotificationReceived:", name: UIMenuControllerDidShowMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuNotificationReceived:", name: UIMenuControllerDidHideMenuNotification, object: nil)
    }
    //////////////
    
//    func updateBaseAttributes(){
//        ///check the typingAttributes, and if they've changed, update the baseAtts accordingly
//        //TODO:Implement updateBaseAttributes
//        print("Need to:Implement updateBaseAttributes")
//        
//    }
    

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //////////////
    
    override public var selectedRange:NSRange {
        didSet{
            if selectedRange != oldValue {
                var attsLoc:Int!
                if selectedRange.length > 0 { //gets atts from the last element in the range
                    attsLoc = selectedRange.location + selectedRange.length - 1
                } else if selectedRange.location > 0 { //gets atts from the preceeding element
                    attsLoc = selectedRange.location - 1
                } else {
                    return
                }
                if attsLoc != nil {
                    self.baseAttributes = self.iaString!.baseAttributes[attsLoc]
                    self.defaultIntensity = self.iaString!.intensities[attsLoc]
                }
            }
        }
    }
    
    
    private var lastSystemTextChange:(range:NSRange,text:String)?
    
    ///We adopt the UIViewDelegate ourselves to implement this one function internally
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let last = lastSystemTextChange {
            lastSystemTextChange = (range:range,text:text)
            if last.range.location == range.location && last.range.length == range.length && last.text == text {
                return false
            }
        } else {
            lastSystemTextChange = (range:range,text:text)
        }
        let selectedLoc = self.selectedRange.location + text.utf16.count
        let newIA:IAString = self.iaString!.emptyCopy()
        
        ///Handling replacement:
        let replacementAtts = range.length > 0 ? extractBaseAttsForRange(range) : baseAttributes
        var repIntensity:Int!
        if range.length > 0 && text.utf16.count > 0 { //&& self.intensityChangesDynamically
            ///we replace with averages of the replaced range
            repIntensity = self.iaString!.intensities[range.intRange].reduce(0, combine: +) / range.length
            
        } else {
            repIntensity = defaultIntensity
        }
        
        newIA.insertAtPosition(text, position: 0, intensity: repIntensity, attributes: replacementAtts)
        
        self.iaString!.replaceRange(newIA, range: range.intRange)
        let nsAttSub = newIA.convertToNSAttributedString()
        self.textStorage.replaceCharactersInRange(range, withAttributedString: nsAttSub)

        
        //renderIAString()
        //set selected range?
        self.selectedRange = NSRange(location: selectedLoc, length: 0)
        return false
    }
    

    
    public func textViewDidChange(textView: UITextView) {
        if self.isFirstResponder() && UIMenuController.sharedMenuController().menuVisible {
            let changes = self.compareTypingAtts()
            self.setFlatAtts()
            //effect changes on selected range
            guard changes.b || changes.i || changes.u || changes.s else {return}
                //toggle currentAttributes
            if changes.b {self.baseAttributes.bold = !self.baseAttributes.bold}
            if changes.i {self.baseAttributes.italic = !self.baseAttributes.italic}
            if changes.u {self.baseAttributes.underline = !self.baseAttributes.underline}
            if changes.s {self.baseAttributes.strikethrough = !self.baseAttributes.strikethrough}
            if selectedRange.length > 0 {
                let iaSub = self.iaString!.iaSubstringFromRange(self.selectedRange.intRange)
                let fullRange = 0..<iaSub.length
                //if in selected range are one thing, toggle it, else set all to whatever true
                if changes.b {
                    let currentVal = (iaSub.getAttributeValueForRange(.Bold, range: fullRange) as? Bool) ?? false
                    iaSub.setAttributeValueForRange(!currentVal, attrName: .Bold, range: fullRange)
                }
                if changes.i {
                    let currentVal = (iaSub.getAttributeValueForRange(.Italic, range: fullRange) as? Bool) ?? false
                    iaSub.setAttributeValueForRange(!currentVal, attrName: .Italic, range: fullRange)
                }
                if changes.u {
                    let currentVal = (iaSub.getAttributeValueForRange(.Underline, range: fullRange) as? Bool) ?? false
                    iaSub.setAttributeValueForRange(!currentVal, attrName: .Underline, range: fullRange)
                }
                if changes.s {
                    let currentVal = (iaSub.getAttributeValueForRange(.Strikethrough, range: fullRange) as? Bool) ?? false
                    iaSub.setAttributeValueForRange(!currentVal, attrName: .Strikethrough, range: fullRange)
                }
                self.iaString!.replaceRange(iaSub, range: self.selectedRange.intRange)
                self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: iaSub.convertToNSAttributedString())
            }
        }
    }
    
    
    ////////


    
    func swapKB(){
        if self.inputViewController == nil {
            self.inputViewController = iaKeyboardVC
            iaKeyboardVC.prepareKeyboardForAppearance()
        } else {
            self.inputViewController = nil
        }
        self.iaAccessory.layoutForBounds()
        self.reloadInputViews()
    }
    
    ///Sets the IATextEditor to an empty IAString and resets properties to the IAKitOptions defaults
    public func resetEditor(){
        self.setIAString(IAString())
        defaultIntensity = IAKitOptions.singleton.defaultIntensity
        baseAttributes = IABaseAttributes(size: IAKitOptions.singleton.defaultTextSize)
        self.setFlatAtts()
    }
    
    ///
    func renderIAString(){
        //TODO: remimplement: should
        self.setIAString(self.iaString!)
    }
    
    ///Scans for urls and may perform other actions to prepare an IAString for export
    public func finalizeIAString()->IAString {
        self.iaString!.scanLinks()
        return self.iaString!
    }
    
    func setIATokenizer(tokenizer:IAStringTokenizing){
        if self.iaString?.preferedSmoothing != tokenizer {
            self.iaString?.preferedSmoothing = tokenizer
            if self.iaAccessory == self.inputAccessoryViewController {
                self.iaAccessory.setTokenizerKeyValue(tokenizer)
            }
            self.renderIAString()
        }
    }
    
//    public func textViewDidChangeSelection(textView: UITextView) {
//        if self.iaKeyboardVC == self.inputViewController && self.isFirstResponder() {
//            iaKeyboardVC.selectionDidChange(self)
//        }
//    }
}






///Enhanced copy/paste/UIMenu functionality
extension IATextEditor {
    //observe UIMenuControllerWillShow
    func menuNotificationReceived(notification:NSNotification){
        print(notification.name)
        guard self.isFirstResponder() else {return}
        if notification.name == UIMenuControllerDidShowMenuNotification {
            //set flat attributes
            self.setFlatAtts()
        } else if notification.name == UIMenuControllerDidHideMenuNotification {
            
        }
        
    }
    
    ///Sets the typing attributes to a base value so that changes can be compared
    func setFlatAtts(){
        self.typingAttributes = [NSFontAttributeName:UIFont.systemFontOfSize(20.0)]
    }
    
    ///returns a tupple indicating which values have changes relative to the flatAtts
    func compareTypingAtts()->(b:Bool,i:Bool,u:Bool,s:Bool){
        var results = (b:false,i:false,u:false,s:false)
        let atts = self.typingAttributes
        if let font = atts[NSFontAttributeName] as? UIFont {
            let traits = font.fontDescriptor().symbolicTraits
            if traits.contains(.TraitBold) {results.b = true}
            if traits.contains(.TraitItalic) {results.i = true}
        }
        if let underline = (atts[NSUnderlineStyleAttributeName] as? Int) where underline != 0 {results.u = true}
        if let strikethrough = (atts[NSStrikethroughStyleAttributeName] as? Int) where strikethrough != 0 {results.s = true}
        return results
    }
    
    
    
    
    public override func paste(sender: AnyObject?) {
        let pb = UIPasteboard.generalPasteboard()
        var newIA:IAString?
        guard let lastItem = pb.items.last as? [String:AnyObject] else {return}
        if let iaData = lastItem[UTITypes.IAStringArchive] as? NSData {
            newIA = IAStringArchive.unarchive(iaData)
        }
        if newIA == nil {
            if let plainText = lastItem[UTITypes.PlainText] as? String {
                newIA = IAString(text: plainText, intensity: defaultIntensity, attributes: baseAttributes)
            } else if let image = pb.image {
                newIA = IAString()
                let attachment = IATextAttachment()
                attachment.image = image
                newIA!.insertAttachmentAtPosition(attachment, position: 0, intensity: defaultIntensity, attributes: baseAttributes)
            } else if let url = pb.URL {
                newIA = IAString(text: String(url), intensity: defaultIntensity, attributes: baseAttributes)
            }
        }
        guard newIA != nil else {return}
        let newLoc = NSMakeRange(self.selectedRange.location + newIA!.length, 0)
        self.iaString!.replaceRange(newIA!, range: self.selectedRange.toRange()!)
        self.iaString!.thumbSize = self.thumbSizesForAttachments
        self.renderIAString()
        self.selectedRange = newLoc
    }
    
    public override func delete(sender: AnyObject?) {
        guard let range = selectedRange.toRange() where range.count > 0 else {return}
        self.iaString!.removeRange(range)
        self.renderIAString()
        self.selectedRange = NSMakeRange(range.startIndex, 0)
    }
    
    public override func cut(sender: AnyObject?) {
        self.copy(sender)
        self.delete(sender)
    }
    
    override public func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if sender is UIMenuController && action == Selector("delete:") {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
//    public func setPerUnitSmoothing(smoothing:NSStringEnumerationOptions){
//        self.iaString!.preferedSmoothing = smoothing
//        renderIAString()
//    }
    
    
    ///extracts the common atts for a specified range, defaulting to false or last when atts vary
    private func extractBaseAttsForRange(nsrange:NSRange)->IABaseAttributes{
        let range = nsrange.intRange
        let size = (self.iaString!.getAttributeValueForRange(.Size, range: nsrange.intRange) as? Int) ?? self.baseAttributes.size
        var newBase = IABaseAttributes(size: size )
        newBase.bold = (self.iaString!.getAttributeValueForRange(.Bold, range: range) as? Bool) ?? self.baseAttributes.bold
        newBase.italic = (self.iaString!.getAttributeValueForRange(.Italic, range: range) as? Bool) ?? self.baseAttributes.italic
        newBase.underline = (self.iaString!.getAttributeValueForRange(.Underline, range: range) as? Bool) ?? self.baseAttributes.underline
        newBase.strikethrough = (self.iaString!.getAttributeValueForRange(.Strikethrough, range: range) as? Bool) ?? self.baseAttributes.strikethrough
        return newBase
    }
}







