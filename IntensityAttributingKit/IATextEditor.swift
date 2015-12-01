//
//  IATextEditor.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/30/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit



public class IATextEditor: IATextView, IAAccessoryDelegate, UITextViewDelegate {
    
    
    var currentAttributes:IntensityAttributes! {
        didSet{if let schemeName = currentAttributes?.currentScheme where IntensityTransformers(rawValue: schemeName) != nil {
            iaAccessory?.setTransformKeyForScheme(withName: schemeName)
            }
            defaultIntensity = currentAttributes.intensity
        }
    }
    
    override var currentTransformer:IntensityTransformers! {
        get {
            guard let schemeName = currentAttributes?.currentScheme else {return nil}
            return IntensityTransformers(rawValue: schemeName)
        }
        set {
            currentAttributes?.currentScheme = newValue.rawValue
        }
    }
    
    var defaultIntensity:Float {
        get {return iaAccessory?.intensityAdjuster.defaultIntensity ?? IAKitOptions.singleton.defaultIntensity}
        set {
            if iaAccessory != nil && !iaAccessory!.intensityAdjuster.defaultLocked {
                iaAccessory!.intensityAdjuster.defaultIntensity = newValue
            }
        }
    }
    
    
    //Mark:- Input view controllers (keyboard and accessory)
    
    private var _inputVC:UIInputViewController?
    override public var inputViewController:UIInputViewController? {
        set {self._inputVC = newValue}
        get {return self._inputVC}
    }
//
//    
    private var iaAccessory:IAAccessoryVC?
    
    private var iaKeyboardVC:IAKeyboard?
//    override public var inputAccessoryViewController:UIInputViewController? {
//        //set {self.iaAccessory = newValue!}
//        get {return self.iaAccessory}
//    }
//    
//    lazy var pressureKeyboardVC:UIInputViewController = {
//        return IAKeyboard(nibName: nil, bundle: nil)
//    }()
    
    
    public override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            iaAccessory = IAKitOptions.singleton.accessory
            iaAccessory?.delegate = self
            iaKeyboardVC = IAKitOptions.singleton.keyboard
            return true
        }
        return false
    }
    public override func resignFirstResponder() -> Bool {
        if super.resignFirstResponder() {
            iaAccessory?.delegate = nil
            iaAccessory = nil
            iaKeyboardVC = nil
            return true
        }
        return false
    }
    
    internal override func setupPressureTextView(){
        self.editable = true
        iaAccessory?.delegate = self
        self.inputViewController = iaKeyboardVC
        self.delegate = self
        self.layer.cornerRadius = 10.0
        self.textContainerInset = UIEdgeInsetsMake(7.0, 2.0, 7.0, 2.0)
        self.currentAttributes = IntensityAttributes(intensity: defaultIntensity, size: IAKitOptions.singleton.defaultTextSize)
        currentTransformer = IAKitOptions.singleton.defaultScheme
        typingAttributes = currentTransformer.transformer.typingAttributesForScheme(currentAttributes)
        self.allowsEditingTextAttributes = true
    }
    
    //MARK:- shouldChangeTextInRange()
    
    ///We adopt the UIViewDelegate ourselves to implement this one function internally
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard text != "" else {return true}
        var thisIntensity:Float!
        var retainedAttributes:[String:AnyObject]!
        if let paragraphStyle = typingAttributes[NSParagraphStyleAttributeName] {
            retainedAttributes = [NSParagraphStyleAttributeName:paragraphStyle]
        }
        if let iaKB = inputViewController as? IAKeyboard where iaKB.intensity != nil && iaKB.intensity > 0 {
            thisIntensity = iaKB.intensity
            iaKB.intensity = nil
        } else {
            thisIntensity = self.defaultIntensity
        }
        
        currentAttributes = currentTransformer.transformer.updateIntensityAttributesInScheme(lastIntensityAttributes: currentAttributes, providedAttributes: typingAttributes, intensity: thisIntensity)
        
        typingAttributes = currentTransformer.transformer.typingAttributesForScheme(currentAttributes,retainedKeys: retainedAttributes)
        
        
        return true
    }
    
    
    
    
    //MARK:- IAAccessoryDelegate functions
    
    func keyboardChangeButtonPressed() {
        if self.inputViewController == nil {
            self.inputViewController = iaKeyboardVC
        } else {
            self.inputViewController = nil
        }
        self.reloadInputViews()
    }
    
    func cameraButtonPressed() {
        print("camera button pressed...")
    }
    
    //    func defaultIntensityUpdated(withValue value:Float) {
    //
    //    }
    
    func requestTransformerChange(toTransformerWithName name:String){
        guard let _ = IntensityTransformers(rawValue: name) else {return}
        currentAttributes.currentScheme = name
        attributedText = attributedText.transformWithRenderScheme(name)
        typingAttributes = currentTransformer.transformer.typingAttributesForScheme(currentAttributes)
    }
    
    func optionButtonPressed() {
        print("option pressed")
    }
    
    
    
    //MARK:- Copy & Paste + helpers
    
    
    
    override public func cut(sender: AnyObject?) {
        let copiedText = attributedText.attributedSubstringFromRange(selectedRange)
        let archive = NSKeyedArchiver.archivedDataWithRootObject(copiedText)
        super.cut(sender)
        
        let pb = UIPasteboard.generalPasteboard()
        let pbDict = pb.items.first as! NSMutableDictionary
        pbDict.setValue(archive, forKey: UTITypes.IntensityArchive)
        pb.items[0] = pbDict
    }
    
    override public func delete(sender: AnyObject?) {
        deleteBackward()
    
    }
    
    
    ///Pasting of RTFD isn't supported at the moment.
    public override func paste(sender: AnyObject?) {
        let pb = UIPasteboard.generalPasteboard()
        var pasteText:NSMutableAttributedString!
        if let intensityData = pb.items[0][UTITypes.IntensityArchive] as? NSData {
            let raw = NSKeyedUnarchiver.unarchiveObjectWithData(intensityData) as! NSAttributedString
            pasteText = NSMutableAttributedString(attributedString: raw)
            
        }
        //  For RTF paste to work: need to go through all of RTFD and apply IA image size attributes and perform risizing like NSAttributedString(image...) does
        //        else if let rtfdData = pb.items[0][UTITypes.RTFD] as? NSData {
        //            let rawAttString = try? NSMutableAttributedString(data: rtfdData, options: [NSDocumentTypeDocumentAttribute:NSRTFDTextDocumentType], documentAttributes: nil)
        //            if rawAttString != nil {
        //                //strip existing attributes except attachment atts, apply typing attributes
        //                rawAttString!.applyIntensityAttributes(currentAttributes)
        //
        //            }
        //        }
        if pasteText == nil {
            if let pbString = pb.string where pbString.utf16.count > 0 {
                let attString = NSMutableAttributedString(string: pbString)
                attString.applyIntensityAttributes(currentAttributes)
                pasteText = attString
            }
        }
        if pasteText == nil {
            if let image = pb.image {
                let attString = NSMutableAttributedString( attributedString: NSAttributedString(image: image, intensityAttributes: currentAttributes, displayMaxSize: preferedImageDisplaySize, scaleToMaxSize: IAKitOptions.singleton.maxSavedImageDimensions) )
                pasteText = attString
            }
            
        }
        if pasteText != nil {
            pasteText.applyStoredImageConstraints(maxDisplayedSize: preferedImageDisplaySize)
            insertAttributedStringAtCursor(pasteText.transformWithRenderScheme(currentAttributes!.currentScheme))
        }
    }
    /// utility broken out of the paste function
    private func insertAttributedStringAtCursor(attString:NSAttributedString){
        let originalSelectedRange = selectedRange
        let currentText = NSMutableAttributedString(attributedString: attributedText)
        currentText.replaceCharactersInRange(selectedRange, withAttributedString: attString)
        attributedText = currentText
        selectedRange.length = 0
        selectedRange.location = originalSelectedRange.location + attString.length
    }
    
    
    ///With the current construction of the copy&paste functions I haven't found any cases where this is necessary again
    override public func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        //        if sender is UIMenuController && action == Selector("paste:") {
        //            let pb = UIPasteboard.generalPasteboard()
        //            if pb.image != nil {
        //                return true
        //            }
        //            if pb.pasteboardTypes().contains(UTITypes.IntensityArchive){
        //                return true
        //            }
        //        }
        if sender is UIMenuController && action == Selector("delete:") {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }

    
    
    
}