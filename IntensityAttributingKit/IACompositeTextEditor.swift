//
//  IACompositeTextEditor.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/19/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

public class IACompositeTextEditor:IACompositeBase, UITextInput {
    
    
    weak var delegate:IACompositeTextEditorDelegate?
    
    lazy var baseAttributes:IABaseAttributes = {return IABaseAttributes(size:IAKitPreferences.defaultTextSize)}()
    var currentIntensity:Int = IAKitPreferences.defaultIntensity
    
    var _inputVC:UIInputViewController?
    
    
    
    var selectedRange:Range<Int>?
    var markedRange:Range<Int>?
    
    //TODO: Gesture recognizers
    
    
    
    override func setupGestureRecognizers() {
        
    }
    
    
    
    
    
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
            updateSelectionLayer() //FIXME: This may be better off as a check for change
        }
    }
    
    var selectedIATextRange:IATextRange? {
        get {guard selectedRange != nil else {return nil}
            return IATextRange(range: selectedRange!)
        }
        set {
            selectedRange = newValue?.range()
            updateSelectionLayer() //FIXME: This may be better off as a check for change
        }
    }
    
    public var markedTextRange: UITextRange? {
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
        didSet{print("markedTextStyle was set to value: \(markedTextStyle)")}
    }
    
    
    
    
    
    
    
    
    
    //TODO:Copy/paste/ touch based selection
    
    
    
    //MARK:-base editing functions
    
    ///This function performs a range replace on the iaString and updates affected portions ofthe provided textStorage with the new values. This can be complicated because a replaceRange on an IAString with a multi-character length tokenizer (ie anything but character length) can affect a longer range of the textStorage than is replaced in the IAString. This function tries to avoid modifying longer stretches than is necessary.
    internal func replaceIAStringRange(replacement:IAString, range:Range<Int>){
        guard replacement.length > 0 || !range.isEmpty else {return}
        //guard replacement.length > 0 else {deleteIAStringRange(range); return}
        
        self.iaString.replaceRange(replacement, range: range)
        let modRange = range.startIndex ..< (range.startIndex + replacement.length)
        
        let (extendedModRange,topAttString,botAttString) = self.iaString.convertRangeToLayeredAttStringExtendingBoundaries(modRange, withOverridingOptions: IAKitPreferences.iaStringOverridingOptions)
        
        
        topTV.textStorage.beginEditing()
        //first we perform a replace range to line up the indices.
        topTV.textStorage.replaceCharactersInRange(range.nsRange, withString: replacement.text)
        topTV.textStorage.replaceCharactersInRange(extendedModRange.nsRange, withAttributedString: topAttString)
        topTV.textStorage.endEditing()
        
        if botAttString != nil && bottomTV.hidden == false{
            bottomTV.textStorage.beginEditing()
            //first we perform a replace range to line up the indices.
            bottomTV.textStorage.replaceCharactersInRange(range.nsRange, withString: replacement.text)
            bottomTV.textStorage.replaceCharactersInRange(extendedModRange.nsRange, withAttributedString: topAttString)
            bottomTV.textStorage.endEditing()
        }
        if replacement.attachmentCount > 0 {
            refreshImageLayer()
        } else if iaString.attachmentCount > 0 {
            repositionImageViews()
        }
        //update selection:
        let newTextPos = positionFromPosition(beginningOfDocument, offset: (range.startIndex + replacement.length) )!
        selectedTextRange = textRangeFromPosition(newTextPos, toPosition: newTextPos)
        
        inputDelegate?.textDidChange(self)
    }
    
    ///Performs similarly to replaceRange:iaString, deleting text form the store and updating the displaying textStorage to match, taking into account the interaction between the range deletion and tokenizer to determine and execute whatever changes need to be made.
    internal func deleteIAStringRange(range:Range<Int>){
        guard !range.isEmpty else {return}
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
        
        if rangeContainedAttachments {
            refreshImageLayer()
        } else if iaString.attachmentCount > 0 {
            repositionImageViews()
        }
        
        let newTextPos = positionFromPosition(beginningOfDocument, offset: range.startIndex )!
        selectedTextRange = textRangeFromPosition(newTextPos, toPosition: newTextPos)
        
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
    
    ///Sets the IATextEditor to an empty IAString and resets properties to the IAKitPreferences defaults. This should be called while the editor is not first responder.
    public func resetEditor(){
        self.setIAString(IAString())
        currentIntensity = IAKitPreferences.defaultIntensity
        baseAttributes = IABaseAttributes(size: IAKitPreferences.defaultTextSize)
        self.iaString.baseOptions.preferedSmoothing = IAKitPreferences.defaultTokenizer
        self.iaString.baseOptions.renderScheme = IAKitPreferences.defaultTransformer
    }
 
    ///Updates the selection layer if needed.
    func updateSelectionLayer(){
        
    }

    
    
    
}





public protocol IACompositeTextEditorDelegate:class {
    ///The default implementation of this will present the view controller using the delegate adopter
    func iaTextEditorRequestsPresentationOfOptionsVC(iaTextEditor:IACompositeTextEditor)->Bool
    func iaTextEditorRequestsPresentationOfContentPicker(iaTextEditor:IACompositeTextEditor)->Bool
}