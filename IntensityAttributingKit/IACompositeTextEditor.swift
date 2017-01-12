//
//  IACompositeTextEditor.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/19/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

/** The IACompositeTextEditor is the primary means of creating and interacting with IAStrings. Unlike IACompositeTextViews, this editor conforms to UITextInput as well as the protocols of the IAKeyboard and IAAccessory, allowing input and editing with both the custom keyboard and system/3rd party keyboards. IACompositeTextEditor is derived from IACompositeBase but is much heavier weight than the simpler stripped down IACompositeTextView.
 
*/
public class IACompositeTextEditor:IACompositeBase, UITextInput {
    
    public weak var delegate:IACompositeTextEditorDelegate?
    
    ///The baseAttributes hold the attirbutes for the selected text or text at the insertion point
    lazy var _baseAttributes:IABaseAttributes = {return IABaseAttributes(size:IAKitPreferences.defaultTextSize)}()
    var baseAttributes:IABaseAttributes {
        get{return _baseAttributes}
        set{let attsNeedUpdate = _baseAttributes != newValue && selectedRange?.count > 0
            _baseAttributes = newValue
            if attsNeedUpdate {attributesUpdated()}
            }
    }
    var _currentIntensity:Int = IAKitPreferences.defaultIntensity {
        didSet{
            (self.inputAccessoryViewController as? IAAccessoryVC)?.updateDisplayedIntensity(currentIntensity)
        }
    }
    var currentIntensity:Int {
        get{return _currentIntensity}
        set{let attsNeedUpdate = currentIntensity != newValue && selectedRange?.count > 0
            _currentIntensity = newValue
            if attsNeedUpdate{attributesUpdated()}
            }
    }
    
    var _inputVC:UIInputViewController?

    //TODO: Gesture recognizers
    
    var tapGR:UITapGestureRecognizer!
    var doubleTapGR:UITapGestureRecognizer!
    var longPressGR:UILongPressGestureRecognizer!
    
    ///This is the initial start/end containing IATextSelectionRect used by the longPressGR during selection dragging gestures. This should only be non-nil when a longPress is in progress which is changing/dragging the text selection. This will need to be related to the longPressDragStartingPoint in order to ensure the correct amount of relative motion is represented.
    var longPressDragStartingSelectionRect:IATextSelectionRect?
    ///This point is the location of the beginning of a longPress that drags the edge of a text selection. This is related to the longPressDragStartingSelectionRect to determine relative distance dragged.
    var longPressDragStartingPoint:CGPoint?
    

    var magnifyingLoup:IAMagnifyingLoup!
    
    
    //MARK:- Stored properties for UITextInput protocol
    //UITextInput functions are in a separate file.
    public var inputDelegate: UITextInputDelegate?
    public lazy var tokenizer: UITextInputTokenizer =  UITextInputStringTokenizer(textInput: self)
    public var beginningOfDocument: UITextPosition  {
        get{return IATextPosition(0)}
    }
    
    public var endOfDocument: UITextPosition  {
        get{return IATextPosition(iaString.length)}
    }
    
    var documentRange:IATextRange {
        return IATextRange(range:0..<iaString.length)
    }

    public var selectedTextRange: UITextRange? {
        get {guard selectedRange != nil else {return nil}
            return IATextRange(range: selectedRange!)
        }
        set {
            if newValue == nil {
                selectedRange = nil
            } else if let iaNewVal = newValue as? IATextRange {
                selectedRange = iaNewVal.range()
            } else {
                print("selectedTextRange received non IATextRange object")
            }
        }
    }
    
    var selectedIATextRange:IATextRange? {
        get {guard selectedRange != nil else {return nil}
            return IATextRange(range: selectedRange!)
        }
        set {
            selectedRange = newValue?.range()
        }
    }
    
    public internal(set) var markedTextRange: UITextRange? {
        get {guard markedRange != nil else {return nil}
            return IATextRange(range: markedRange!)
        }
        set {
            if newValue == nil {
                markedRange = nil
            } else if let iaNewVal = newValue as? IATextRange {
                markedRange = iaNewVal.range()
            } else {
                print("markedTextRange received non IATextRange object")
            }
        }
    }
    
    public var markedTextStyle: [NSObject : AnyObject]? {
        didSet{print("markedTextStyle was set to value: \(markedTextStyle). ")
            
        }
    }
    
    public override func setIAString(iaString: IAString!) {
        self.selectedRange = nil
        self.markedRange = nil
        super.setIAString(iaString)
    }
    
    
    override func setupIATV(){
        super.setupIATV()
        if magnifyingLoup == nil {
            magnifyingLoup = IAMagnifyingLoup(viewToMagnify:containerView)
            self.addSubview(magnifyingLoup)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleLifecycleChange(_:)), name: UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleLifecycleChange(_:)), name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
        self.selectable = true
    }
    
    
    deinit{NSNotificationCenter.defaultCenter().removeObserver(self)}
    
    //MARK:-base editing functions
    
    ///This function performs a range replace on the iaString and updates affected portions ofthe provided textStorage with the new values. This can be complicated because a replaceRange on an IAString with a multi-character length tokenizer (ie anything but character length) can affect a longer range of the textStorage than is replaced in the IAString. This function tries to avoid modifying longer stretches than is necessary. If closeSelectedRange is true then the selectedRange will become the insertion point at the end of the newly updated range. If it is false then the selectedRange will be the newly inserted range.
    internal func replaceIAStringRange(replacement:IAString, range:Range<Int>, closeSelectedRange:Bool = true){
        guard replacement.length > 0  || !range.isEmpty else {return} 
        let transitioningFromEmptyToContent:Bool = iaString.text.isEmpty
        inputViewController?.textWillChange(self)
        //guard replacement.length > 0 else {deleteIAStringRange(range); return}
        
        self.iaString.replaceRange(replacement, range: range)
        let modRange = range.startIndex ..< (range.startIndex + replacement.length)
        
        let (extendedModRange,topAttString,botAttString) = self.iaString.convertRangeToLayeredAttStringExtendingBoundaries(modRange, withOverridingOptions: IAKitPreferences.iaStringOverridingOptions)
        
        
        topTV.textStorage.beginEditing()
        //first we perform a replace range to line up the indices.
        topTV.textStorage.replaceCharactersInRange(range.nsRange, withString: replacement.text)
        topTV.textStorage.replaceCharactersInRange(extendedModRange.nsRange, withAttributedString: topAttString)
        topTV.textStorage.endEditing()
        topTV.invalidateIntrinsicContentSize()
        if botAttString != nil {
            if bottomTV.hidden {
                bottomTV.hidden = false
            }
            bottomTV.textStorage.beginEditing()
            //first we perform a replace range to line up the indices.
            bottomTV.textStorage.replaceCharactersInRange(range.nsRange, withString: replacement.text)
            bottomTV.textStorage.replaceCharactersInRange(extendedModRange.nsRange, withAttributedString: botAttString!)
            bottomTV.textStorage.endEditing()
        }
        if replacement.attachmentCount > 0 {
            refreshImageLayer()
        } else if iaString.attachmentCount > 0 {
            repositionImageViews()
        }
        //update selection:
        
        if closeSelectedRange {
            let offset = range.startIndex + replacement.length
            let newTextPos = positionFromPosition(beginningOfDocument, offset: offset )!
            selectedTextRange = textRangeFromPosition(newTextPos, toPosition: newTextPos)
        } else {
            selectedRange = modRange
        }

        
        //inputDelegate?.textDidChange(self)
        markedRange = nil // let the textDidChange method in IAKeyboard update the marked range
        inputViewController?.textDidChange(self)
        
        if transitioningFromEmptyToContent {
            startAnimation()
        }
    }
    
    ///Performs similarly to replaceRange:iaString, deleting text form the store and updating the displaying textStorage to match, taking into account the interaction between the range deletion and tokenizer to determine and execute whatever changes need to be made.
    internal func deleteIAStringRange(range:Range<Int>){
        guard !range.isEmpty else {return}
        inputDelegate?.textWillChange(self)
        let rangeContainedAttachments:Bool = iaString.rangeContainsAttachments(range)
        
        if iaString.checkRangeIsIndependentInRendering(range, overridingOptions: IAKitPreferences.iaStringOverridingOptions) {
            //range is independent, nothing needs to be recalculated by us.
            iaString.removeRange(range)
            topTV.textStorage.deleteCharactersInRange(range.nsRange)
            if bottomTV.hidden == false {
                bottomTV.textStorage.deleteCharactersInRange(range.nsRange)
            }
        } else {
            // Deleting the range will affect the rendering of surrounding text, so we need to modify an extended range
            replaceIAStringRange(iaString.emptyCopy(), range: range)
            return
        }
        topTV.invalidateIntrinsicContentSize()
        if rangeContainedAttachments {
            refreshImageLayer()
        } else if iaString.attachmentCount > 0 {
            //this should only run if the imageviews are located after the deletion point
            repositionImageViews()
        }
        
        let newTextPos = positionFromPosition(beginningOfDocument, offset: range.startIndex )!
        selectedTextRange = textRangeFromPosition(newTextPos, toPosition: newTextPos)
        markedRange = nil
        inputDelegate?.textDidChange(self)
    }
    
    ///Creates a copy and scans for urls and may perform other actions to prepare an IAString for export.
    public func finalizeIAString(updateDefaults:Bool = true)->IAString {
        let result = iaString.copy()
        result.scanLinks()
        if updateDefaults {
            IAKitPreferences.defaultTokenizer = self.iaString.baseOptions.preferedSmoothing
            IAKitPreferences.defaultTransformer = self.iaString.baseOptions.renderScheme
        }
        return result
    }
    
    ///Sets the IATextEditor to an empty IAString and resets properties to the IAKitPreferences defaults. Resigns as first responder.
    public func resetEditor(){
        if self.isFirstResponder() {
            self.resignFirstResponder()
        }
        self.setIAString(IAString())
        currentIntensity = IAKitPreferences.defaultIntensity
        baseAttributes = IABaseAttributes(size: IAKitPreferences.defaultTextSize)
        self.iaString.baseOptions.preferedSmoothing = IAKitPreferences.defaultTokenizer
        self.iaString.baseOptions.renderScheme = IAKitPreferences.defaultTransformer
    }

    
    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        switch action {
        case #selector(paste(_:)):
            return (_selectedRange != nil && pasteboardHasIACompatibleData())
        case #selector(copy(_:)):
            return (_selectedRange != nil && _selectedRange!.isEmpty == false)
        case #selector(selectAll(_:)):
            if _selectedRange != nil && _selectedRange!.count == iaString.length {
                return false //filter out cases where we've already selected all
            }
            return iaString.length > 0
        case #selector(delete(_:)):
            return false
        case #selector(cut(_:)):
            return (_selectedRange != nil && _selectedRange!.isEmpty == false)
        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    ///Tests if the general UIPasteboard has data which can be pasted into the IATextEditor
    func pasteboardHasIACompatibleData()->Bool{
        let pb = UIPasteboard.generalPasteboard()
        guard let lastItem = pb.items.last else {return false}
        if (lastItem[UTITypes.PlainText] as? String) != nil {
            return true
        } else if pb.image != nil {
            return true
        } else if pb.URL != nil {
            return true
        } else if (lastItem[UTITypes.IAStringArchive] as? NSData) != nil {
                return true
        } else {
            return false
        }
    }
    
    public override func paste(sender: AnyObject?) {
        guard selectedRange != nil else {return}
        let pb = UIPasteboard.generalPasteboard()
        var newIA:IAString?
        guard let lastItem = pb.items.last else {return}
        if let iaData = lastItem[UTITypes.IAStringArchive] as? NSData {
            newIA = IAStringArchive.unarchive(iaData)
        }
        if newIA == nil {
            if let plainText = lastItem[UTITypes.PlainText] as? String {
                newIA = IAString(text: plainText, intensity: currentIntensity, attributes: baseAttributes)
            } else if let image = pb.image {
                newIA = IAString()
                let attachment = IAImageAttachment(withImage: image)
                newIA!.insertAttachmentAtPosition(attachment, position: 0, intensity: currentIntensity, attributes: baseAttributes)
            } else if let url = pb.URL {
                newIA = IAString(text: String(url), intensity: currentIntensity, attributes: baseAttributes)
            }
        }
        guard newIA != nil else {return}

        replaceIAStringRange(newIA!, range: selectedRange!)
    }
    
    public override func delete(sender: AnyObject?) {
        guard selectedRange?.count > 0 else {return}
        deleteIAStringRange(selectedRange!)
    }
    
    public override func cut(sender: AnyObject?) {
        guard selectedRange?.count > 0 else {return}
        self.copy(sender)
        deleteIAStringRange(selectedRange!)
    }
    
    ///Updates the baseAttributes and currentIntensity to match the averages of the range or position behind the insertion point. Triggers updateSelectionLayer(). This is automatically called in a didSet on selectionRange but can be avoided by directly modifying _selectedRange
    override func selectedRangeChanged() {
        //update current intensity and baseAttributes
        if markedRange != nil {
            if _selectedRange == nil {
                markedRange = nil
            } else if _selectedRange!.startIndex > markedRange!.endIndex || _selectedRange!.endIndex < markedRange!.startIndex {
                markedRange = nil
            }
        }
        if _selectedRange != nil {
            if _selectedRange!.isEmpty {
                if _selectedRange!.startIndex == 0 {
                    if iaString.length > 0 {
                        //use the attributes of whatever follows else dont change attributes
                        _baseAttributes = iaString.baseAttributes[0]
                        _currentIntensity = iaString.intensities[0]
                    }
                    inputViewController?.selectionDidChange(self)
                    super.selectedRangeChanged()
                    return
                } else {
                    //if our empty selection range is not at zero then we use the values at the previous index
                    _baseAttributes = iaString.baseAttributes[_selectedRange!.startIndex - 1]
                    _currentIntensity = iaString.intensities[_selectedRange!.startIndex - 1]
                }
            } else {
                //selected range is not empty, so baseAttributes and intensities are derived from the _selectedRange. We update the stored intensity and base values without
                _currentIntensity = iaString.getAverageIntensityForRange(_selectedRange!)
                _baseAttributes = iaString.getBaseAttributesForRange(_selectedRange!)
            }
        }
        inputViewController?.selectionDidChange(self)
        super.selectedRangeChanged()
    }
    
    ///Applies changes in attributes to a selected range's text.
    func attributesUpdated(){
        if selectedRange?.count > 0 {
            let subString = iaString.iaSubstringFromRange(selectedRange!)
            subString.setIntensityValueForRange(selectedRange!, toValue: currentIntensity)
            subString.baseAttributes.setValueForRange(baseAttributes, range: selectedRange!)
            replaceIAStringRange(subString, range: selectedRange!, closeSelectedRange: false)
        }
    }

    
    public override func toggleBoldface(sender: AnyObject?) {
        self.baseAttributes.bold = !self.baseAttributes.bold
    }
    
    public override func toggleItalics(sender: AnyObject?) {
        self.baseAttributes.italic = !self.baseAttributes.italic
    }
    
    public override func toggleUnderline(sender: AnyObject?) {
        self.baseAttributes.underline = !self.baseAttributes.underline
    }
    
    @objc private func handleLifecycleChange(notification:NSNotification!){
        guard let notiName = notification?.name else {return}
        if notiName == UIApplicationWillEnterForegroundNotification && self.isFirstResponder(){
            self.prepareToBecomeFirstResponder()
        } else if notiName == UIApplicationWillResignActiveNotification {
            RawIntensity.touchInterpreter.deactivate()
        }
    }
    
    
    override public var inputViewController:UIInputViewController? {
        set {self._inputVC = newValue}
        get {return self._inputVC}
    }
    
    override public var inputAccessoryViewController:UIInputViewController? {
        get {return IAAccessoryVC.singleton}
    }
    
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override public func becomeFirstResponder() -> Bool {
        _inputVC = IAKitPreferences.keyboard
        guard super.becomeFirstResponder() else {return false}
        prepareToBecomeFirstResponder()
        return true
    }
    
    override public func resignFirstResponder() -> Bool {
        guard super.resignFirstResponder() else {return false}
        IAKitPreferences.keyboard.inputView!.layer.shouldRasterize = true
        unmarkText()
        selectionView.hideCursor()
        RawIntensity.touchInterpreter.deactivate()
        return true
    }

    
    override func setupGestureRecognizers() {
        tapGR = UITapGestureRecognizer(target: self, action: #selector(self.singleTapGestureUpdate(_:)))
        tapGR.numberOfTapsRequired = 1
        tapGR.numberOfTouchesRequired = 1
        tapGR.delegate = self
        
        doubleTapGR = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapGestureUpdate(_:)))
        doubleTapGR.numberOfTapsRequired = 2
        doubleTapGR.numberOfTouchesRequired = 1
        doubleTapGR.delegate = self
        
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGestureUpdate(_:)))
        longPressGR.numberOfTapsRequired = 0
        longPressGR.numberOfTouchesRequired = 1
        longPressGR.minimumPressDuration = 0.5
        longPressGR.allowableMovement = 20
        longPressGR.delegate = self
        
        
        self.addGestureRecognizer(tapGR)
        self.addGestureRecognizer(doubleTapGR)
        self.addGestureRecognizer(longPressGR)
    }


}





@objc public protocol IACompositeTextEditorDelegate:class {
    ///The default implementation of this will present the view controller using the delegate adopter
    optional func iaTextEditorRequestsPresentationOfOptionsVC(iaTextEditor:IACompositeTextEditor)->Bool
    optional func iaTextEditorRequestsPresentationOfContentPicker(iaTextEditor:IACompositeTextEditor)->Bool
}
