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
        self.typingAttributes = [NSFontAttributeName:UIFont.systemFontOfSize(baseAttributes.cSize)]
        self.layoutManager.allowsNonContiguousLayout = false
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
    

    
//    public func textViewDidChange(textView: UITextView) {
//
//    }
    
    
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

    
    public override func toggleBoldface(sender: AnyObject?) {
        self.baseAttributes.bold = !self.baseAttributes.bold
        if selectedRange.length > 0 {
            let rangeIsBold = (self.iaString!.getAttributeValueForRange(.Bold, range: selectedRange.intRange) as? Bool) ?? false
            self.iaString!.setAttributeValueForRange(!rangeIsBold, attrName: .Bold, range: selectedRange.intRange)
            self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: self.iaString!.iaSubstringFromRange(selectedRange.intRange).convertToNSAttributedString())
        }
        
    }
    
    public override func toggleItalics(sender: AnyObject?) {
        self.baseAttributes.italic = !self.baseAttributes.italic
        if selectedRange.length > 0 {
            let rangeIsBold = (self.iaString!.getAttributeValueForRange(.Italic, range: selectedRange.intRange) as? Bool) ?? false
            self.iaString!.setAttributeValueForRange(!rangeIsBold, attrName: .Italic, range: selectedRange.intRange)
            self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: self.iaString!.iaSubstringFromRange(selectedRange.intRange).convertToNSAttributedString())
        }
    }
    
    public override func toggleUnderline(sender: AnyObject?) {
        self.baseAttributes.underline = !self.baseAttributes.underline
        if selectedRange.length > 0 {
            let rangeIsBold = (self.iaString!.getAttributeValueForRange(.Underline, range: selectedRange.intRange) as? Bool) ?? false
            self.iaString!.setAttributeValueForRange(!rangeIsBold, attrName: .Underline, range: selectedRange.intRange)
            self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: self.iaString!.iaSubstringFromRange(selectedRange.intRange).convertToNSAttributedString())
        }
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







