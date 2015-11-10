//
//  IATextView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/25/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

public class IATextView: UITextView, UITextViewDelegate, IAAccessoryDelegate {
    
    
    var currentAttributes:IntensityAttributes! {
        didSet{if let schemeName = currentAttributes?.currentScheme where IntensityTransformers(rawValue: schemeName) != nil {
            iaAccessory.setTransformKeyForScheme(withName: schemeName)
            }
        }
    }

    var currentTransformer:IntensityTransforming! {
        guard let schemeName = currentAttributes?.currentScheme else {return nil}
        return IntensityTransformers(rawValue: schemeName)?.transformer ?? nil
    }

    var defaultIntensity:Float {
        get {return iaAccessory.intensityAdjuster.defaultIntensity}
        set {if !iaAccessory.intensityAdjuster.defaultLocked {iaAccessory.intensityAdjuster.defaultIntensity = newValue}}
    }
    
    //Mark:- Input view controllers (keyboard and accessory)
    
    private var _inputVC:UIInputViewController?
    override public var inputViewController:UIInputViewController? {
        set {self._inputVC = newValue}
        get {return self._inputVC}
    }
    
    
    private lazy var iaAccessory:IAAccessoryVC = {
        return IAAccessoryVC(nibName: nil, bundle: nil)
    }()
    override public var inputAccessoryViewController:UIInputViewController? {
        //set {self.iaAccessory = newValue!}
        get {return self.iaAccessory}
    }
    
    lazy var pressureKeyboardVC:UIInputViewController = {
        return IAKeyboard(nibName: nil, bundle: nil)
    }()
    

    
    ///display max size for images displayed in text
    var preferedImageDisplaySize = CGSize(width: 200, height: 200)
    ///images pasted in from other programs will have their original size modified to fit within this size, maintaining aspect fit
    var resizePastedImagesToMaxSize = CGSize(width: 500, height: 500)
    
    
    
    //MARK:-inits and setup
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPressureTextView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPressureTextView()
    }
    

    private func setupPressureTextView(){
        iaAccessory.delegate = self
        self.inputViewController = pressureKeyboardVC
        self.delegate = self
        self.layer.cornerRadius = 10.0
        self.textContainerInset = UIEdgeInsetsMake(7.0, 2.0, 7.0, 2.0)
        self.currentAttributes = IntensityAttributes(intensity: defaultIntensity, size: 18.0)
        currentAttributes.currentScheme = "WeightScheme"//"HueGYRScheme" //this should draw from global prefs
        typingAttributes = currentTransformer.typingAttributesForScheme(currentAttributes)
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
        
        currentAttributes = currentTransformer.updateIntensityAttributesInScheme(lastIntensityAttributes: currentAttributes, providedAttributes: typingAttributes, intensity: thisIntensity)
        
        typingAttributes = currentTransformer.typingAttributesForScheme(currentAttributes,retainedKeys: retainedAttributes)
        
        
        return true
    }
    
    
    //MARK:- IAAccessoryDelegate functions
    
    func keyboardChangeButtonPressed() {
        if self.inputViewController == nil {
            self.inputViewController = pressureKeyboardVC
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
        typingAttributes = currentTransformer.typingAttributesForScheme(currentAttributes)
    }
    
    func optionButtonPressed() {
        print("option pressed")
    }
    
    
    
    
    //MARK:- Copy & Paste + helpers
    
    
    override public func copy(sender: AnyObject?){
        super.copy()
        let pb = UIPasteboard.generalPasteboard()
        let pbDict = pb.items.first as! NSMutableDictionary
        
        let copiedText = attributedText.attributedSubstringFromRange(selectedRange)
        let archive = NSKeyedArchiver.archivedDataWithRootObject(copiedText)
        pbDict.setValue(archive, forKey: UTITypes.IntensityArchive)
        pb.items[0] = pbDict
    }

    
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
                let attString = NSMutableAttributedString( attributedString: NSAttributedString(image: image, intensityAttributes: currentAttributes, displayMaxSize: preferedImageDisplaySize, scaleToMaxSize: resizePastedImagesToMaxSize) )
                pasteText = attString
            }
            
        }
        if pasteText != nil {
            print(pasteText)
            pasteText.applyStoredImageConstraints(maxDisplayedSize: CGSize(width: 200, height: 200))
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
    
/*
    ///With the current construction of the copy&paste functions I haven't found any cases where this is necessary again
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if sender is UIMenuController && action == Selector("paste:") {
            let pb = UIPasteboard.generalPasteboard()
            if pb.image != nil {
                return true
            }
            if pb.pasteboardTypes().contains(UTITypes.IntensityArchive){
                return true
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }
*/
    private struct UTITypes {
        static let PlainText = "public.utf8-plain-text"
        static let RTFD = "com.apple.flat-rtfd"
        static let IntensityArchive = "com.mckeemaker.IntensityAttributedTextArchive"
    }
    
}






