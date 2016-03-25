//
//  IATextEditor.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/31/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

public class IATextEditor: IATextView {
    
    
    internal(set) var baseAttributes:IABaseAttributes = IABaseAttributes(size: IAKitOptions.defaultTextSize)
    
    internal(set) var currentTransformer:IntensityTransformers = IAKitOptions.defaultTransformer {
        didSet {if currentTransformer != oldValue && self.inputAccessoryViewController != nil {
            self.iaAccessory.setTransformKeyForScheme(withName: currentTransformer.transformer.schemeName)
            }
        }
    }
    
    internal(set) var defaultIntensity:Int = IAKitOptions.defaultIntensity {
        didSet {iaAccessory.updateDisplayedIntensity(defaultIntensity)}
    }
    
    var textChecker:UITextChecker!
    ///Range of the current word for which suggestions are being made by the iaKeyboard suggestionBar
    var rangeForSuggestionReplacement:NSRange?
    
    weak public var editorDelegate:IATextEditorDelegate?
    
    //define IAKeyboardDelegate: directly modify the store, bypassing UITextView accessors
    //IAAccessoryDelegate: allows accessory to access and modify attributes
    //internal delegate can be used for tracking changes attempted by the system keyboard
    
    
    private var iaAccessory:IAAccessoryVC {
        return IAKitOptions.accessory
    }
    
    private var iaKeyboardVC:IAKeyboard {
        return IAKitOptions.keyboard
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
            _inputVC = iaKeyboardVC
            prepareToBecomeFirstResponder()
            return true
        }
        return false
    }
    
    func prepareToBecomeFirstResponder(){
        //iaAccessory = IAKitOptions.singleton.accessory
        iaAccessory.delegate = self
        //iaKeyboardVC = IAKitOptions.singleton.keyboard
        self.iaAccessory.setTransformKeyForScheme(withName: currentTransformer.transformer.schemeName)
        self.iaAccessory.setTokenizerKeyValue(self.iaString!.preferedSmoothing)
        iaKeyboardVC.delegate = self
        iaAccessory.updateAccessoryLayout(true)
        updateSuggestionsBar()
        iaKeyboardVC.inputView!.layer.shouldRasterize = true
        RawIntensity.touchInterpreter.activate()
    }
    
    public override func resignFirstResponder() -> Bool {
        if super.resignFirstResponder() {
            //iaAccessory.delegate = nil
            //iaAccessory = nil
            //iaKeyboardVC = nil
            iaKeyboardVC.inputView!.layer.shouldRasterize = true
            RawIntensity.touchInterpreter.deactivate()
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
        currentTransformer = IAKitOptions.defaultTransformer
        self.allowsEditingTextAttributes = true
        self.setIAString(IAString())
        self.iaString!.renderScheme = currentTransformer
        self.iaString!.preferedSmoothing = IAKitOptions.defaultTokenizer
        
        self.typingAttributes = [NSFontAttributeName:UIFont.systemFontOfSize(baseAttributes.cSize)]
        self.layoutManager.allowsNonContiguousLayout = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLifecycleChange:", name: UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLifecycleChange:", name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
        textChecker = UITextChecker()
    }
    deinit{NSNotificationCenter.defaultCenter().removeObserver(self)}
    
    //////////////
    
    override public var selectedRange:NSRange {
        didSet{
            if selectedRange != oldValue {
                updateSuggestionsBar()
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
    
    ///This is used to track a quirk in quicktype text input described below.
    private var lastSystemTextChange:(range:NSRange,text:String)?
 
    ///We adopt the UIViewDelegate ourselves to implement this one function internally. The system quicktype keyboard seems to use a private API at times when interacting with UITextView subclasses. Without using this function we have no way to intercept the replacement of words with suggestions from the suggestion bar.
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let last = lastSystemTextChange {
            lastSystemTextChange = (range:range,text:text)
            if last.range.location == range.location && last.range.length == range.length && last.text == text {
                return false
            }
        } else {
            lastSystemTextChange = (range:range,text:text)
        }
        guard text.characters.count > 0  else {
            self.deleteBackward()
            return false
        }
        let selectedLoc = self.selectedRange.location + text.utf16.count
        let newIA:IAString = self.iaString!.emptyCopy()
        
        ///Handling replacement:
        let replacementAtts = range.length > 0 ? extractBaseAttsForRange(range) : baseAttributes
        var repIntensity:Int!
        if range.length > 0 && text.utf16.count > 0 { //&& self.intensityChangesDynamically
            ///we replace with averages of the replaced range
            repIntensity = self.iaString!.intensities[range.toRange()!].reduce(0, combine: +) / range.length
            
        } else {
            repIntensity = defaultIntensity
        }
        
        newIA.insertAtPosition(text, position: 0, intensity: repIntensity, attributes: replacementAtts)
        
        self.iaString!.replaceRange(newIA, range: range.toRange()!)
        let nsAttSub = newIA.convertToNSAttributedString()
        self.textStorage.replaceCharactersInRange(range, withAttributedString: nsAttSub)

        
        //renderIAString()
        //set selected range?
        self.selectedRange = NSRange(location: selectedLoc, length: 0)
        return false
    }
    
    
    func swapKB(){
        if self.inputViewController == nil {
            self.inputViewController = iaKeyboardVC
            iaKeyboardVC.prepareKeyboardForAppearance()
            iaAccessory.updateAccessoryLayout(true)
        } else {
            self.inputViewController = nil
            iaAccessory.updateAccessoryLayout(false)
        }
        
        self.reloadInputViews()
        self.updateSuggestionsBar()
    }
    
    ///Sets the IATextEditor to an empty IAString and resets properties to the IAKitOptions defaults
    public func resetEditor(){
        self.setIAString(IAString())
        defaultIntensity = IAKitOptions.defaultIntensity
        baseAttributes = IABaseAttributes(size: IAKitOptions.defaultTextSize)
        
        self.iaString!.preferedSmoothing = IAKitOptions.defaultTokenizer
        self.iaString!.renderScheme = IAKitOptions.defaultTransformer
    }
    
//    ///Ignores overrideRenderOptions
    public override func setIAString(iaString: IAString, withCacheIdentifier: String? = nil, overrideRenderOptions renderOptions: [String : AnyObject]? = nil) {
        self.iaString = iaString
    }
    
    func renderIAString(){
        //TODO: remimplement: should
        self.setIAString(self.iaString!)
    }
    
    ///Scans for urls and may perform other actions to prepare an IAString for export
    public func finalizeIAString()->IAString {
        self.iaString!.scanLinks()
        IAKitOptions.defaultTokenizer = self.iaString!.preferedSmoothing
        IAKitOptions.defaultTransformer = self.currentTransformer
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
    
}






///Enhanced copy/paste/UIMenu functionality
extension IATextEditor {

    
    public override func toggleBoldface(sender: AnyObject?) {
        self.baseAttributes.bold = !self.baseAttributes.bold
        if selectedRange.length > 0 {
            let rangeIsBold = (self.iaString!.getAttributeValueForRange(.Bold, range: selectedRange.toRange()!) as? Bool) ?? false
            self.iaString!.setAttributeValueForRange(!rangeIsBold, attrName: .Bold, range: selectedRange.toRange()!)
            self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: self.iaString!.iaSubstringFromRange(selectedRange.toRange()!).convertToNSAttributedString())
        }
        
    }
    
    public override func toggleItalics(sender: AnyObject?) {
        self.baseAttributes.italic = !self.baseAttributes.italic
        if selectedRange.length > 0 {
            let rangeIsBold = (self.iaString!.getAttributeValueForRange(.Italic, range: selectedRange.toRange()!) as? Bool) ?? false
            self.iaString!.setAttributeValueForRange(!rangeIsBold, attrName: .Italic, range: selectedRange.toRange()!)
            self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: self.iaString!.iaSubstringFromRange(selectedRange.toRange()!).convertToNSAttributedString())
        }
    }
    
    public override func toggleUnderline(sender: AnyObject?) {
        self.baseAttributes.underline = !self.baseAttributes.underline
        if selectedRange.length > 0 {
            let rangeIsBold = (self.iaString!.getAttributeValueForRange(.Underline, range: selectedRange.toRange()!) as? Bool) ?? false
            self.iaString!.setAttributeValueForRange(!rangeIsBold, attrName: .Underline, range: selectedRange.toRange()!)
            self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: self.iaString!.iaSubstringFromRange(selectedRange.toRange()!).convertToNSAttributedString())
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
        let range = nsrange.toRange()!
        let size = (self.iaString!.getAttributeValueForRange(.Size, range: nsrange.toRange()!) as? Int) ?? self.baseAttributes.size
        var newBase = IABaseAttributes(size: size )
        newBase.bold = (self.iaString!.getAttributeValueForRange(.Bold, range: range) as? Bool) ?? self.baseAttributes.bold
        newBase.italic = (self.iaString!.getAttributeValueForRange(.Italic, range: range) as? Bool) ?? self.baseAttributes.italic
        newBase.underline = (self.iaString!.getAttributeValueForRange(.Underline, range: range) as? Bool) ?? self.baseAttributes.underline
        newBase.strikethrough = (self.iaString!.getAttributeValueForRange(.Strikethrough, range: range) as? Bool) ?? self.baseAttributes.strikethrough
        return newBase
    }
    
    func handleLifecycleChange(notification:NSNotification!){
        guard let notiName = notification?.name else {return}
        if notiName == UIApplicationWillEnterForegroundNotification && self.isFirstResponder(){
            self.prepareToBecomeFirstResponder()
        } else if notiName == UIApplicationWillResignActiveNotification {
            RawIntensity.touchInterpreter.deactivate()
        }
    }
}







