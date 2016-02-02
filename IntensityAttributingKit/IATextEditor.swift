//
//  IATextEditor.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/30/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//
/*
import UIKit



public class IATextEditor: IATextView, IAAccessoryDelegate {
    
//    var currentAttributes:IntensityAttributes! {
//        didSet{if let schemeName = currentAttributes?.currentScheme where IntensityTransformers(rawValue: schemeName) != nil {
//            iaAccessory.setTransformKeyForScheme(withName: schemeName)
//            }
//            defaultIntensity = currentAttributes.intensity
//        }
//    }
//    
//    override var currentTransformer:IntensityTransformers! {
//        get {
//            guard let schemeName = currentAttributes?.currentScheme else {return nil}
//            return IntensityTransformers(rawValue: schemeName)
//        }
//        set {
//            currentAttributes?.currentScheme = newValue.rawValue
//        }
//    }
//    
//    var defaultIntensity:Float {
//        get {return iaAccessory.intensityAdjuster.defaultIntensity }
//        set {
//            if !iaAccessory.intensityAdjuster.defaultLocked {
//                iaAccessory.intensityAdjuster.defaultIntensity = newValue
//            }
//        }
//    }
    
    var currentAttributes:IABaseAttributes = IABaseAttributes() //should load default base attributes
    
    var currentTransformer:IntensityTransformers = IntensityTransformers.WeightScheme //should load default transformer
    
    var defaultIntensity:Int = 40//should load default intensity
    
    //Mark:- Input view controllers (keyboard and accessory)
    
    private var _inputVC:UIInputViewController?
    override public var inputViewController:UIInputViewController? {
        set {self._inputVC = newValue}
        get {return self._inputVC}
    }
//
//    
    private var iaAccessory:IAAccessoryVC {
        return IAKitOptions.singleton.accessory
    }
    
    private var iaKeyboardVC:IAKeyboard {
        return IAKitOptions.singleton.keyboard
    }
    
    override public var inputAccessoryViewController:UIInputViewController? {
        get {return self.iaAccessory}
    }
    
    ///This is the viewcontroller which is/will display the IATextEditor. We need to keep a week reference so that the accessory can present a UIPhotoPicker in the correct view hierarchy. This violates MVC but makes the IntensityAttributingKit more self contained.
    public weak var presentingVC:UIViewController?
//
//    lazy var pressureKeyboardVC:UIInputViewController = {
//        return IAKeyboard(nibName: nil, bundle: nil)
//    }()
    
    /**When replacing a range via autocorrect, the shouldChangeTextInRange function is triggered but the typing attributes that are set are not used for the main text string that is inserted, except for the space that is inserted afterwards. This creates a non-IA string which is problematic. The workaround is that when shouldChangeTextInRange sees a replacement of length > 0 text on a length > 0 range, it will set this value so that at the conclusion of insert sequence (textViewDidChange), this attribute dictionary will be applied to any non-IA text in the attributedText. Fixing this in a less hacky way would require largely rebuilding a UITextView from scratch since some of the functions which must be modified seem to be final.*/
    private var attributeDictForRangeReplace:[String:AnyObject]?
    
    
//    let types:NSTextCheckingType = [
//        .Orthography,   //1
//        .Spelling,      //2
//        .Grammar,       //4
//        .Date,          //8
//        .Address,       //16
//        .Link,          //32
//        .Quote,         //64
//        .Dash,          //128
//        .Replacement,   //256
//        .Correction,    //512
//        .RegularExpression, //1024
//        .PhoneNumber,       //2048
//        .TransitInformation //4096
//    ]  // sum = 8191
    let detector = try! NSDataDetector(types: 8191)
    
    func checkText(){
        let modified = NSMutableAttributedString(attributedString: self.attributedText)
        var changes = false
        detector.enumerateMatchesInString(self.text, options: .WithTransparentBounds, range: NSRange(location: 0, length: (self.text as NSString).length)) { (result, flags, stop) -> Void in
            if let result = result {
                changes = true
                print("result: \(result.resultType)")
                if result.URL != nil {
                    print("url result: \(result.URL!)")
                    
                    modified.addAttribute(NSLinkAttributeName, value: result.URL!, range: result.range)
                }
            } else {
                print("Nil result")
            }
        }
        
        if changes {
            self.attributedText = modified
        }
    }
    
    
    public override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            //iaAccessory = IAKitOptions.singleton.accessory
            iaAccessory.delegate = self
            //iaKeyboardVC = IAKitOptions.singleton.keyboard
            _inputVC = iaKeyboardVC
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
        self.currentAttributes = IntensityAttributes(intensity: defaultIntensity, size: IAKitOptions.singleton.defaultTextSize)
        currentTransformer = IAKitOptions.singleton.defaultScheme
        typingAttributes = currentTransformer.transformer
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
        } else if text.utf16.count > 0 && range.length > 0 { //range replacement uses average of text being replaced if not already attributed
            thisIntensity = attributedText.averageIntensityForRange(range)
        } else {
            thisIntensity = self.defaultIntensity
        }
        
        currentAttributes = currentTransformer.transformer.updateIntensityAttributesInScheme(lastIntensityAttributes: currentAttributes, providedAttributes: typingAttributes, intensity: thisIntensity)
        
        typingAttributes = currentTransformer.transformer.typingAttributesForScheme(currentAttributes,retainedKeys: retainedAttributes)
        
        //range replaces may be from autocorrect, potentially leaving unattributed text afterwards. By setting attributeDictForRangeReplace, this will be checked and fixed if necessary.
        if text.utf16.count > 0 && range.length > 0 {
            attributeDictForRangeReplace = typingAttributes
        }
        
        return true
    }
    
    public func textViewDidChange(textView: UITextView) {
        if attributeDictForRangeReplace != nil {
            let modRanges = attributedText.getNonIARanges()
            if  modRanges.count > 0 {
                let newAttString = NSMutableAttributedString(attributedString: attributedText)
                for modRange in  modRanges{
                    newAttString.setAttributes(attributeDictForRangeReplace, range: modRange)
                }
                self.attributedText = newAttString
            }
            attributeDictForRangeReplace = nil
        }
        checkText()
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
    
    func imageChosen(image: UIImage!) {
        if let image = image {
            let attString = NSMutableAttributedString( attributedString: NSAttributedString(image: image, intensityAttributes: currentAttributes, thumbSize:thumbSizesForAttachments, scaleToMaxSize: IAKitOptions.singleton.maxSavedImageDimensions) )
            //attString.applyStoredImageConstraints(maxDisplayedSize: preferedImageDisplaySize)
            insertAttributedStringAtCursor(attString.transformWithRenderScheme(currentAttributes!.currentScheme))
        }
        self.becomeFirstResponder()
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
        guard presentingVC != nil else {return}
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
        
        presentingVC?.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///This can be call by the owning VC upon applicationDidBecomeActive in order to restore potentially lost connections
    public func resumeLastState(owningVC:UIViewController?){
        self.presentingVC = owningVC
        if self.isFirstResponder() {
            iaAccessory.delegate = self
        }
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
                let attString = NSMutableAttributedString( attributedString: NSAttributedString(image: image, intensityAttributes: currentAttributes, thumbSize: thumbSizesForAttachments, scaleToMaxSize: IAKitOptions.singleton.maxSavedImageDimensions) )
                pasteText = attString
            }
            
        }
        if pasteText != nil {
            //pasteText.applyStoredImageConstraints(maxDisplayedSize: preferedImageDisplaySize)
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
*/