//
//  IATextView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/25/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

class IATextView: UITextView, UITextViewDelegate {
    
    
    var currentAttributes:IntensityAttributes!

    var currentTransformer:IntensityTransforming! {
        guard let schemeName = currentAttributes?.currentScheme else {return nil}
        return availableIntensityTransformers[schemeName]
    }
    
    ///tells the shouldChangeTextInRange delegate to ignore the next insertion because it's coming from an insert action (like paste) and includes text
    private var didInsert:Bool = false
    
    
    
    private var _inputVC:UIInputViewController?
    override var inputViewController:UIInputViewController? {
        set {self._inputVC = newValue}
        get {return self._inputVC}
    }
    
    
    private var _inputAccessoryVC:UIInputViewController?
    override var inputAccessoryViewController:UIInputViewController? {
        set {self._inputAccessoryVC = newValue}
        get {return self._inputAccessoryVC}
    }
    
    //    lazy var pressureAccessoryVC:PressureAccessory = {
    //        return PressureAccessory(nibName: nil, bundle: nil)
    //    }()
    
    lazy var pressureKeyboardVC:UIInputViewController = {
        return IAKeyboard(nibName: nil, bundle: nil)//HodorKBVC(nibName: nil, bundle: nil)
    }()
    
    var sliderVal:Float! = 0.6//{
    //        get {return pressureAccessoryVC.slider.value}
    //        set {pressureAccessoryVC.slider.value = newValue}
    //    }
    
    
    
    
    
    //MARK:-inits
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPressureTextView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPressureTextView()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    private func setupPressureTextView(){
        //        pressureAccessoryVC.delegate = self
        //        pressureAccessoryVC.view.backgroundColor = UIColor.blackColor()
        //        pressureAccessoryVC.view.translatesAutoresizingMaskIntoConstraints = false
        //        self.inputAccessoryViewController = pressureAccessoryVC
        self.inputViewController = pressureKeyboardVC
        self.delegate = self
        self.layer.cornerRadius = 10.0
        self.textContainerInset = UIEdgeInsetsMake(7.0, 2.0, 7.0, 2.0)
        self.currentAttributes = IntensityAttributes(intensity: sliderVal, size: 18.0)
        currentAttributes.currentScheme = "WeightScheme"//"TextColorScheme"
        typingAttributes = currentTransformer.typingAttributesForScheme(currentAttributes)
        self.allowsEditingTextAttributes = true
        
        
    }
    
    func keyboardChangeButtonPressed() {
        if self.inputViewController == nil {
            self.inputViewController = pressureKeyboardVC
        } else {
            self.inputViewController = nil
        }
        self.reloadInputViews()
    }
    
    
    
    //    func optionButtonPressed() {
    //        print(attributedText)
    //        print(attributedText.length)
    //    }
    
    //    override func replaceRange(range: UITextRange, withText text: String) {
    //        if shouldChangeTextInRange(range, replacementText: text) {
    //            if let iaKB = inputViewController as? IAKeyboard where iaKB.lastKeyAvgIntensity > 0 && iaKB.lastKeyPeakIntensity > 0 {
    //                self.typingAttributes[NSFontAttributeName] = fontForIntensity(iaKB.lastKeyAvgIntensity!)
    //                self.typingAttributes["IntensityAttributed"] = iaKB.lastKeyAvgIntensity!
    //                iaKB.lastKeyAvgIntensity = nil
    //                iaKB.lastKeyPeakIntensity = nil
    //            } else {
    //                self.typingAttributes[NSFontAttributeName] = fontForIntensity(self.sliderVal)
    //                self.typingAttributes["IntensityAttributed"] = self.sliderVal
    //            }
    //
    //        }
    //    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard !didInsert else {didInsert = false; return false}
        //print("should change: range: \(range), text: \(text)")
        //let stringRange = textView.text.rangeFromNSRange(range)
        //print("stringRange \(stringRange!)")
        
        //        let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)  //existing
        //        var newText:NSAttributedString!
        //        if let lightKB = inputViewController as? LightKBVC where lightKB.lastKeyAvgIntensity > 0 && lightKB.lastKeyPeakIntensity > 0{
        //            let attributes:[String:AnyObject] = [NSFontAttributeName: fontForIntensity(lightKB.lastKeyAvgIntensity!)]
        //            newText = NSAttributedString(string: text, attributes: attributes)
        //            lightKB.lastKeyAvgIntensity = nil
        //            lightKB.lastKeyPeakIntensity = nil
        //        } else {
        //            newText = NSAttributedString(string: text, attributes: attributesForCurrentSettings())
        //        }
        //
        //
        //        attributedText.replaceCharactersInRange(range, withAttributedString: newText)
        //
        //        textView.attributedText = attributedText
        //        return false
        //print("\ntypeing attributes before update \n\(pruneAttributes(typingAttributes))")
        
        var thisIntensity:Float!
        
        if let iaKB = inputViewController as? IAKeyboard where iaKB.lastKeyAvgIntensity > 0 && iaKB.lastKeyPeakIntensity > 0 {
            //            self.typingAttributes[NSFontAttributeName] = fontForIntensity(iaKB.lastKeyAvgIntensity!)
            //            self.typingAttributes["IntensityAttributed"] = iaKB.lastKeyAvgIntensity!
            thisIntensity = iaKB.lastKeyAvgIntensity
            iaKB.lastKeyAvgIntensity = nil
            iaKB.lastKeyPeakIntensity = nil
        } else {
            //            self.typingAttributes[NSFontAttributeName] = fontForIntensity(self.sliderVal)
            //            self.typingAttributes["IntensityAttributed"] = self.sliderVal
            thisIntensity = self.sliderVal
        }
        
        currentAttributes = currentTransformer.updateIntensityAttributesInScheme(lastIntensityAttributes: currentAttributes, providedAttributes: typingAttributes, intensity: thisIntensity)
        
        typingAttributes = currentTransformer.typingAttributesForScheme(currentAttributes)
        
        
        
        return true
    }
    
    
    
    
    func attributesForCurrentSettings()->[String:AnyObject]{
        var attributes:[String:AnyObject] = [:]
        attributes[NSFontAttributeName] = fontForIntensity(self.sliderVal)
        return attributes
    }
    
    
    func fontForIntensity(intensity:Float)->UIFont{
        let bin = Int(floor(min(intensity, 0.99) * Float(weightArray.count)))
        print("intensity: \(intensity) => bin: \(bin)")
        return UIFont.systemFontOfSize(18.0, weight: weightArray[bin])
        
    }
    
    
    lazy var defaultFont:UIFont = {
        return UIFont.systemFontOfSize(18.0, weight: UIFontWeightRegular)
    }()
    
    let weightArray = [
        UIFontWeightUltraLight,
        UIFontWeightThin,
        UIFontWeightLight,
        UIFontWeightRegular,
        UIFontWeightMedium,
        UIFontWeightSemibold,
        UIFontWeightBold,
        UIFontWeightHeavy,
        UIFontWeightBlack
    ]
    
    
    
    /*
    
    override func cut(sender: AnyObject?) {
    
    copy(nil)
    delete(nil)
    }
    
    override func copy(sender: AnyObject?) {
    let pb = UIPasteboard.generalPasteboard()
    let copiedText = attributedText.attributedSubstringFromRange(selectedRange)
    var itemDict:[String:AnyObject] = [:]
    //let dataRepresentation = NSKeyedArchiver.archivedDataWithRootObject(cutItem)
    if let utf8Rep = try? copiedText.dataFromRange(NSMakeRange(0, copiedText.length), documentAttributes: [NSDocumentTypeDocumentAttribute:NSPlainTextDocumentType]) {
    itemDict[UTITypes.PlainText] = utf8Rep
    }
    
    if let rtfd = try? copiedText.dataFromRange(NSMakeRange(0, copiedText.length), documentAttributes: [NSDocumentTypeDocumentAttribute:NSRTFDTextDocumentType]){
    itemDict[UTITypes.RTFD] = rtfd
    }
    let intensityAttributed = NSKeyedArchiver.archivedDataWithRootObject(copiedText)
    itemDict[UTITypes.IntensityArchive] = intensityAttributed
    pb.items = [itemDict]
    }
    
    override func delete(sender: AnyObject?) {
    let oldRange = selectedRange
    let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
    mutableAttributedString.deleteCharactersInRange(selectedRange)
    attributedText = mutableAttributedString
    selectedRange.length = 0
    selectedRange.location = oldRange.location
    
    }
    
    
    override func paste(sender: AnyObject?) {
    let pb = UIPasteboard.generalPasteboard()
    var pasteText:NSAttributedString!
    if let intensityData = pb.items[0][UTITypes.IntensityArchive] as? NSData {
    pasteText = NSKeyedUnarchiver.unarchiveObjectWithData(intensityData) as! NSAttributedString
    
    } else if let rtfdData = pb.items[0][UTITypes.RTFD] as? NSData {
    pasteText = try? NSMutableAttributedString(data: rtfdData, options: [NSDocumentTypeDocumentAttribute:NSRTFDTextDocumentType], documentAttributes: nil)
    if pasteText != nil {
    applyCurrentAttributesToString(&pasteText!)
    }
    }
    if pasteText == nil {
    if let pbString = pb.string where pbString.utf16.count > 0 {
    pasteText = NSMutableAttributedString(string: pbString)
    }
    if pasteText != nil {
    applyCurrentAttributesToString(&pasteText!)
    }
    }
    
    if pasteText == nil {
    if let image = pb.image {
    insertImageAtCursor(image)
    return
    }
    
    }
    
    if pasteText != nil {
    insertAttributedStringAtCursor(pasteText)
    }
    
    
    
    }
    
    func insertImageAtCursor(image:UIImage){
    
    let attachement = NSTextAttachment()//NSTextAttachment(data: UIImageJPEGRepresentation(image, 0.9), ofType: "kUTTypeJPEG")
    
    attachement.image = image//image.resizeWithMaxWidthAndHeight(maxWidth: 300.0, maxHeight: 300.0)
    let displaySize = image.resizeWithMaxWidthAndHeight(maxWidth: 300.0, maxHeight: 300.0).size
    attachement.bounds = CGRect(origin: CGPointZero, size: displaySize)
    var attString = NSAttributedString(attachment: attachement)
    applyCurrentAttributesToString(&attString)
    print("attstring")
    print(attString.string.utf16)
    insertAttributedStringAtCursor(attString)
    }
    
    //
    func applyCurrentAttributesToString(inout text:NSAttributedString){
    if text is NSMutableAttributedString {
    //need to apply current slider as intensity to all, should apply default font, etc to all
    
    } else {
    var attStringCopy = NSMutableAttributedString(attributedString: text)
    
    
    
    }
    }
    
    ///Enabling the pasting of images from the pasteboard
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
    
    
    func insertAttributedStringAtCursor(attString:NSAttributedString){
    let ReplacementCharacter = "\u{FFFC}".utf16.first!
    for i in attString.string.utf16.generate() {
    if i != ReplacementCharacter{
    didInsert = true
    }
    }
    
    let originalSelectedRange = selectedRange
    let currentText = NSMutableAttributedString(attributedString: attributedText)
    currentText.replaceCharactersInRange(selectedRange, withAttributedString: attString)
    attributedText = currentText
    selectedRange.length = 0
    selectedRange.location = originalSelectedRange.location + attString.length
    }
    
    private struct UTITypes {
    static let PlainText = "public.utf8-plain-text"
    static let RTFD = "com.apple.flat-rtfd"
    static let IntensityArchive = "com.mckeemaker.IntensityAttributedTextArchive"
    }
    */
}


extension IATextView {
    //diags
    //    override var typingAttributes:[String:AnyObject] {
    //        get {return super.typingAttributes}
    //        set {if newValue.keys.map({$0}) != super.typingAttributes.keys.map({$0}) || newValue[NSFontAttributeName] as? UIFont != super.typingAttributes[NSFontAttributeName] as? UIFont {
    //
    //            print("\n__________________\ntypingAttributes changed- \nold: \(pruneAttributes(super.typingAttributes))  \nnewvalues: \(pruneAttributes(newValue)))")}; super.typingAttributes = newValue}
    //    }
    
    //    override var typingAttributes:[String:AnyObject] {
    //        didSet{print("did set: oldValue: \n \(pruneAttributes(oldValue))\nNewValue:\n\(pruneAttributes(typingAttributes))")}
    //    }
    //
    //    func pruneAttributes(atts:[String:AnyObject])->[String:AnyObject]{
    //        var prunedAttributes:[String:AnyObject] = atts
    //        prunedAttributes.removeValueForKey(NSParagraphStyleAttributeName)
    //        return prunedAttributes
    //    }
}




