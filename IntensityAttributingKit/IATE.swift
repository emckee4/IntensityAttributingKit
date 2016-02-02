//
//  IATE.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/31/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

public class IATE: IATextView {
    
    
    private(set) var baseAttributes:IABaseAttributes = IABaseAttributes(size: IAKitOptions.singleton.defaultTextSize)
    
    private(set) var currentTransformer:IntensityTransformers = IAKitOptions.singleton.defaultScheme
    
    private(set) var defaultIntensity:Int = IAKitOptions.singleton.defaultIntensity
    
    
    var intensityChangesDynamically = true
    
    
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

    
    //////////
    
    public override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            //iaAccessory = IAKitOptions.singleton.accessory
            iaAccessory.delegate = self
            //iaKeyboardVC = IAKitOptions.singleton.keyboard
            _inputVC = iaKeyboardVC
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
        //iaAccessory?.delegate = self
        self.inputViewController = iaKeyboardVC
        self.delegate = self
        self.layer.cornerRadius = 10.0
        self.textContainerInset = UIEdgeInsetsMake(7.0, 2.0, 7.0, 2.0)
        currentTransformer = IAKitOptions.singleton.defaultScheme
        self.allowsEditingTextAttributes = true
        self.setIAString(IAString())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuNotificationReceived:", name: UIMenuControllerDidShowMenuNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "menuNotificationReceived:", name: UIMenuControllerDidHideMenuNotification, object: nil)
    }
    //////////////
    
    func updateBaseAttributes(){
        ///check the typingAttributes, and if they've changed, update the baseAtts accordingly
        //TODO:Implement updateBaseAttributes
        print("Need to:Implement updateBaseAttributes")
    }
    

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //////////////
    
    override public var selectedRange:NSRange {
        didSet{print("didSet selectedRange: \(selectedRange)")}
    }
    
    private var lastSystemTextChange:(range:NSRange,text:String)?
    
    ///We adopt the UIViewDelegate ourselves to implement this one function internally
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        print("shouldChangeTextInRange: \(text), \(range)")
//        guard text != "" else {return true}
//        var thisIntensity:Float!
//        var retainedAttributes:[String:AnyObject]!
//        if let paragraphStyle = typingAttributes[NSParagraphStyleAttributeName] {
//            retainedAttributes = [NSParagraphStyleAttributeName:paragraphStyle]
//        }
//        if let iaKB = inputViewController as? IAKeyboard where iaKB.intensity != nil && iaKB.intensity > 0 {
//            thisIntensity = iaKB.intensity
//            iaKB.intensity = nil
//        } else if text.utf16.count > 0 && range.length > 0 { //range replacement uses average of text being replaced if not already attributed
//            thisIntensity = attributedText.averageIntensityForRange(range)
//        } else {
//            thisIntensity = self.defaultIntensity
//        }
//        
//        currentAttributes = currentTransformer.transformer.updateIntensityAttributesInScheme(lastIntensityAttributes: currentAttributes, providedAttributes: typingAttributes, intensity: thisIntensity)
//        
//        typingAttributes = currentTransformer.transformer.typingAttributesForScheme(currentAttributes,retainedKeys: retainedAttributes)
//        
//        //range replaces may be from autocorrect, potentially leaving unattributed text afterwards. By setting attributeDictForRangeReplace, this will be checked and fixed if necessary.
//        if text.utf16.count > 0 && range.length > 0 {
//            attributeDictForRangeReplace = typingAttributes
//        }
//
        if let last = lastSystemTextChange {
            lastSystemTextChange = (range:range,text:text)
            if last.range.location == range.location && last.range.length == range.length && last.text == text {
                print("repeated found")
                return false
            }
        } else {
            lastSystemTextChange = (range:range,text:text)
        }
        let selectedLoc = self.selectedRange.location + text.utf16.count
        
        if text.utf16.count == 0 {
            self.iaString!.removeRange(range.intRange)
        } else if range.length == 0 {
            self.iaString!.insertAtPosition(text, position: range.location, intensity: defaultIntensity, attributes: baseAttributes)
        } else {
            let repIA = IAString(text: text, intensity: defaultIntensity, attributes: baseAttributes)
            self.iaString!.replaceRange(repIA, range: range.intRange)
        }
        renderIAString()
        //set selected range?
        self.selectedRange = NSRange(location: selectedLoc, length: 0)
        return false
    }
    

    
    public func textViewDidChange(textView: UITextView) {
        print("textViewDidChange: \(self.typingAttributes)")
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
                let range = self.selectedRange.intRange
                //if in selected range are one thing, toggle it, else set all to whatever true
                if changes.b {
                    let currentVal = (self.iaString!.getAttributeValueForRange(.Bold, range: range) as? Bool) ?? false
                    self.iaString!.setAttributeValueForRange(!currentVal, attrName: .Bold, range: range)
                }
                if changes.i {
                    let currentVal = (self.iaString!.getAttributeValueForRange(.Italic, range: range) as? Bool) ?? false
                    self.iaString!.setAttributeValueForRange(!currentVal, attrName: .Italic, range: range)
                }
                if changes.u {
                    let currentVal = (self.iaString!.getAttributeValueForRange(.Underline, range: range) as? Bool) ?? false
                    self.iaString!.setAttributeValueForRange(!currentVal, attrName: .Underline, range: range)
                }
                if changes.s {
                    let currentVal = (self.iaString!.getAttributeValueForRange(.Strikethrough, range: range) as? Bool) ?? false
                    self.iaString!.setAttributeValueForRange(!currentVal, attrName: .Strikethrough, range: range)
                }
                
                self.renderIAString()
            }
            print("typing atts after rerender: \(self.typingAttributes)")
        }
        
        
        //lastAtts = self.typingAttributes
        
//        if attributeDictForRangeReplace != nil {
//            let modRanges = attributedText.getNonIARanges()
//            if  modRanges.count > 0 {
//                let newAttString = NSMutableAttributedString(attributedString: attributedText)
//                for modRange in  modRanges{
//                    newAttString.setAttributes(attributeDictForRangeReplace, range: modRange)
//                }
//                self.attributedText = newAttString
//            }
//            attributeDictForRangeReplace = nil
//        }
//        checkText()
    }
    
    
    ////////


    
    
    
    
    
    ///
    func renderIAString(){
        //TODO: remimplement: should
        self.setIAString(self.iaString!)
    }
    

    
}


public protocol IATextEditorDelegate:class {
    ///The default implementation of this will present the view controller using the delegate adopter
    func iaTextEditorRequestsPresentation(iaTextEditor:IATE, shouldPresentVC:UIViewController)
    
}
public extension IATextEditorDelegate  {
    public func iaTextEditorRequestsPresentation(iaTextEditor:IATE, shouldPresentVC:UIViewController){
        guard let vc = self as? UIViewController else {return}
        vc.presentViewController(shouldPresentVC, animated: true) { () -> Void in
            
        }
    }
}


///IAKeyboardDelegate implementation
extension IATE:IAKeyboardDelegate {
    
    func iaKeyboard(insertTextAtCursor text: String, intensity: Int) {
        let cursorLoc = self.selectedRange.location + text.utf16.count
        updateBaseAttributes()
        let baseAtts = self.baseAttributes
        if self.selectedRange.length == 0 {
            //insert
            self.iaString!.insertAtPosition(text, position: self.selectedRange.location, intensity: intensity, attributes: baseAtts)
        } else {
            //replaceRange
            let rep = IAString(text: text, intensity: intensity, attributes: baseAtts)
            self.iaString!.replaceRange(rep, range: self.selectedRange.toRange()!)
        }
        //rerender, update cursor position
        renderIAString()
        self.selectedRange = NSRange(location: cursorLoc, length: 0)
    }
    
    func iaKeyboardDeleteBackwards() {
        let nextLoc = self.selectedRange.location > 0 ? self.selectedRange.location - 1 : 0
        if self.selectedRange.length == 0 && self.selectedRange.location > 0{
            //insert
            self.iaString!.removeRange((self.selectedRange.location - 1)..<self.selectedRange.location)
        } else if self.selectedRange.length > 0 {
            self.iaString!.removeRange(self.selectedRange.intRange)
        } else {
            return
        }
        renderIAString()
        self.selectedRange = NSMakeRange(nextLoc, 0)
    }
    
}




///IAAccessoryDelegate implementation
extension IATE: IAAccessoryDelegate {
    
    func keyboardChangeButtonPressed(){
        if self.inputViewController == nil {
            self.inputViewController = iaKeyboardVC
        } else {
            self.inputViewController = nil
        }
        self.reloadInputViews()
    }
    
    //func defaultIntensityUpdated(withValue value:Float)
    func optionButtonPressed(){
        guard editorDelegate != nil else {return}
        //guard presentingVC != nil else {return}
        let alert = UIAlertController(title: "Options", message: "Choose your intensity mapper:", preferredStyle: .ActionSheet)
        if self.traitCollection.forceTouchCapability == UIForceTouchCapability.Available {
            for fim in ForceIntensityMappingFunctions.AvailableFunctions.availableForceOnlyNames {
                alert.addAction(UIAlertAction(title: fim, style: .Default, handler: { (action) -> Void in
                    let newMapping = ForceIntensityMappingFunctions.AvailableFunctions(rawValue: fim)
                    IAKitOptions.singleton.forceIntensityMapping = newMapping
                    IAKitOptions.singleton.saveOptions()
                    RawIntensity.forceIntensityMapping = newMapping!.namedFunction
                }))
            }
        } else {
            for fim in ForceIntensityMappingFunctions.AvailableFunctions.availableForceOnlyNames {
                let disabledAction = UIAlertAction(title: fim, style: .Default, handler: nil)
                alert.addAction(disabledAction)
                disabledAction.enabled = false
            }
        }
        for fim in ForceIntensityMappingFunctions.AvailableFunctions.availableDurationOnlyNames {
            alert.addAction(UIAlertAction(title: fim, style: .Default, handler: { (action) -> Void in
                let newMapping = ForceIntensityMappingFunctions.AvailableFunctions(rawValue: fim)
                IAKitOptions.singleton.forceIntensityMapping = newMapping
                IAKitOptions.singleton.saveOptions()
                RawIntensity.forceIntensityMapping = newMapping!.namedFunction
            }))
        }
        editorDelegate?.iaTextEditorRequestsPresentation(self, shouldPresentVC: alert)
        
    }
    func requestTransformerChange(toTransformerWithName name:String){
        self.currentTransformer = IntensityTransformers(rawValue: name)!
        self.iaString!.renderScheme = currentTransformer
        renderIAString()
    }
    //weak var presentingVC:UIViewController? {get}
    func requestPickerLaunch(){
        //TODO:move logic from IAAccessory to here. Call The editor's delegate to offer presentation of the picker
        launchPicker()
    }
    
    
}

///Enhanced copy/paste/UIMenu functionality
extension IATE {
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
        print("attempted paste")
    }
    
    
}








