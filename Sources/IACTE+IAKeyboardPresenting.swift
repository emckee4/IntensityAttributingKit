//
//  IACTE+IAKeyboardPresenting.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/19/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation



///IAKeyboardDelegate conformance. Most of these are self explanatory. The keyboard uses the UIKeyInput deleteBackwards function for backspace while using its custom iaKeyboard:insertTextAtCursor: function here for insertion.
extension IACompositeTextEditor:IAKeyboardDelegate {
    
    func iaKeyboard(_ iaKeyboard:IAKeyboard, insertTextAtCursor text:String, intensity:Int){
        guard selectedTextRange != nil else {return}
        let insertionIAString = IAString(text: text, intensity: intensity, attributes: baseAttributes)
        replaceIAStringRange(insertionIAString, range: selectedRange!)
    }
    
    ///Handles replacement of marked text after a suggestion is chosen from the IAKeyboard SuggestionView
    func iaKeyboard(_ iaKeyboard:IAKeyboard, suggestionSelected text:String, intensity:Int)->Bool{
        if markedRange != nil {
            let rep = IAString(text: text + " ", intensity: intensity, attributes: iaString.getBaseAttributesForRange(markedRange!))
            replaceIAStringRange(rep, range: markedRange!, closeSelectedRange: true)
            unmarkText()
            return true
        } else {
            let insertionIAString = IAString(text: text, intensity: intensity, attributes: baseAttributes)
            replaceIAStringRange(insertionIAString, range: selectedRange!)
            return false
        }
    }

    
    ///returns true if IAKeyboard is presented by this, false if system keyboard, and nil if this is not first responder
    var keyboardIsIAKeyboard:Bool?{
        guard self.isFirstResponder else {return nil}
        return inputViewController == IAKitPreferences.keyboard
    }
    
    func swapKB(){
        if self.inputViewController == nil {
            self._inputVC = IAKitPreferences.keyboard
            IAKitPreferences.keyboard.prepareKeyboardForAppearance()
            IAKitPreferences.accessory.updateAccessoryLayout(true)
        } else {
            unmarkText()
            self._inputVC = nil
            IAKitPreferences.accessory.updateAccessoryLayout(false)
        }
        self.reloadInputViews()
        
    }

    func prepareToBecomeFirstResponder(){
        let iaAccessory = IAKitPreferences.accessory
        let iaKeyboard = IAKitPreferences.keyboard
        
        
        iaKeyboard.delegate = self
        iaAccessory.delegate = self
        if selectedTextRange == nil {
            selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
        }
        
        if selectedRange?.isEmpty == true {
            selectionView.updateSelections(caretRect: caretRectForIAPosition(selectedIATextRange!.iaStart))
        }
        
        
        
        iaAccessory.setTransformKeyForScheme(iaString.baseOptions.renderScheme)
        iaAccessory.setTokenizerKeyValue(self.iaString!.baseOptions.preferedSmoothing)
        
        iaAccessory.updateAccessoryLayout(true)
        iaKeyboard.updateSuggestionBar()
        iaKeyboard.inputView!.layer.shouldRasterize = true
        RawIntensity.touchInterpreter.activate()
    }
    
}

///IAAccessory delegate conformance. Most of these are pretty self explanatory.
extension IACompositeTextEditor: IAAccessoryDelegate {
    
    func accessoryKeyboardChangeButtonPressed(_ accessory:IAAccessoryVC!){
        swapKB()
    }
    
    func accessoryOptionButtonPressed(_ accessory:IAAccessoryVC!){
        guard let presentingVC = delegate?.iaTextEditorRequestsPresentationOfOptionsVC?(self) else {return}
        let optionsVC = IAKitSettingsTableViewController()
        let modalContainer = IACardModalViewController()
        modalContainer.contentViewController = optionsVC
        presentingVC.present(modalContainer, animated: true, completion: nil)
    }
    
    func accessoryRequestsPickerLaunch(_ accessory:IAAccessoryVC!,pickerName:String){
        switch pickerName{
        case "photo":
            launchPhotoPicker()
        case "video":
            launchVideoPicker()
        case "location":
            launchLocationPicker()
        default:
            print("bad action name for accessoryRequestsPcikerLaunch")
        }
    }
    
    func accessoryUpdatedDefaultIntensity(_ accessory:IAAccessoryVC!, withValue value:Int){
        self.currentIntensity = value
        ///modify the intensities in the selected range
        if selectedRange != nil && self.selectedRange?.isEmpty == false {
            iaString.setIntensityValueForRange(selectedRange!, toValue: value)
            //this triggers the recomputing/redrawing the text in the range
            replaceIAStringRange(iaString.iaSubstringFromRange(selectedRange!), range: selectedRange!)
        }
        
    }
    
    ///Return true to inform the iaAccessory that it should center the button associated with the transformer.
    func accessoryRequestsTransformerChange(_ accessory:IAAccessoryVC!, toTransformer:IntensityTransformers)->Bool{
        guard toTransformer != iaString.baseOptions.renderScheme else {return true}
        self.iaString.baseOptions.renderScheme = toTransformer
        rerenderIAString(recalculateStrings: true)
        if iaString.baseOptions.animatesIfAvailable && toTransformer.isAnimatable {
            self.startAnimation()
        }
        return true
    }
    
    func accessoryRequestsSmoothingChange(_ accessory:IAAccessoryVC!, toValue:IAStringTokenizing)->Bool{
        guard toValue != iaString.baseOptions.preferedSmoothing else {return true}
        self.iaString.baseOptions.preferedSmoothing = toValue
        rerenderIAString(recalculateStrings: true)
        return true
    }
    
    func iaKeyboardIsShowing()->Bool{
        return keyboardIsIAKeyboard ?? false
    }

    
}

