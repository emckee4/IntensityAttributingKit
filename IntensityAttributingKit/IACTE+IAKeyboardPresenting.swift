//
//  IACTE+IAKeyboardPresenting.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/19/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation




extension IACompositeTextEditor:IAKeyboardDelegate {
    
    func iaKeyboard(iaKeyboard:IAKeyboard, insertTextAtCursor text:String, intensity:Int){
        guard selectedTextRange != nil else {return}
        let insertionIAString = IAString(text: text, intensity: intensity, attributes: baseAttributes)
        replaceIAStringRange(insertionIAString, range: selectedRange!)
    }
    
    
    func iaKeyboard(iaKeyboard:IAKeyboard, suggestionSelected text:String, intensity:Int)->Bool{
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
        guard self.isFirstResponder() else {return nil}
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
            selectedTextRange = textRangeFromPosition(endOfDocument, toPosition: endOfDocument)
        }
        
        if selectedRange?.isEmpty == true {
            selectionView.updateSelections(caretRect: caretRectForIAPosition(selectedIATextRange!.iaStart))
        }
        
        
        
        iaAccessory.setTransformKeyForScheme(iaString.baseOptions.renderScheme)
        iaAccessory.setTokenizerKeyValue(self.iaString!.baseOptions.preferedSmoothing)
        
        iaAccessory.updateAccessoryLayout(true)
        updateSuggestionsBar()
        iaKeyboard.inputView!.layer.shouldRasterize = true
        RawIntensity.touchInterpreter.activate()
    }
    
    func updateSuggestionsBar(){
        print("updateSuggestionsBar")
    }
    
    
    
    
    
}


extension IACompositeTextEditor: IAAccessoryDelegate {
    
    func accessoryKeyboardChangeButtonPressed(accessory:IAAccessoryVC!){
        swapKB()
    }
    
    func accessoryOptionButtonPressed(accessory:IAAccessoryVC!){
        guard delegate?.iaTextEditorRequestsPresentationOfOptionsVC?(self) == true else {return}
        let optionsVC = IAKitSettingsTableViewController()
        let modalContainer = ModalContainerViewController()
        modalContainer.addChildViewController(optionsVC)
        modalContainer.dismissalCompletionBlock = {self.becomeFirstResponder()}
        self.window?.rootViewController?.presentViewController(modalContainer, animated: true, completion: nil)
    }
    
    ///Return true to inform the iaAccessory that it should center the button associated with the transformer.
    func accessoryRequestsTransformerChange(accessory:IAAccessoryVC!, toTransformer:IntensityTransformers)->Bool{
        guard toTransformer != iaString.baseOptions.renderScheme else {return true}
        self.iaString.baseOptions.renderScheme = toTransformer
        rerenderIAString()
        if iaString.baseOptions.animatesIfAvailable && toTransformer.isAnimatable {
            self.startAnimation()
        }
        return true
    }
    
    func accessoryRequestsPickerLaunch(accessory:IAAccessoryVC!){
        launchPhotoPicker() //the check of the IATE delegate for whether to present the picker is called in launchPhotoPicker
    }
    
    func accessoryUpdatedDefaultIntensity(accessory:IAAccessoryVC!, withValue value:Int){
        self.currentIntensity = value
        ///modify the intensities in the selected range
        if selectedRange != nil && self.selectedRange?.isEmpty == false {
            iaString.setIntensityValueForRange(selectedRange!, toValue: value)
            //this triggers the recomputing/redrawing the text in the range
            replaceIAStringRange(iaString.iaSubstringFromRange(selectedRange!), range: selectedRange!)
        }
        
    }
    
    func accessoryRequestsSmoothingChange(accessory:IAAccessoryVC!, toValue:IAStringTokenizing)->Bool{
        guard toValue != iaString.baseOptions.preferedSmoothing else {return true}
        self.iaString.baseOptions.preferedSmoothing = toValue
        rerenderIAString()
        return true
    }
    
    func iaKeyboardIsShowing()->Bool{
        return keyboardIsIAKeyboard ?? false
    }

    
}

