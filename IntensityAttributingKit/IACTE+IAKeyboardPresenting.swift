//
//  IACTE+IAKeyboardPresenting.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/19/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation




extension IACompositeTextEditor:IAKeyboardDelegate {
    
    //private var iaAccessory:IAAccessoryVC {return IAKitPreferences.accessory}
    //private var iaKeyboard:IAKeyboard {return IAKitPreferences.keyboard}
    
    override public var inputViewController:UIInputViewController? {
        set {self._inputVC = newValue}
        get {return self._inputVC}
    }
    
    override public var inputAccessoryViewController:UIInputViewController? {
        get {return IAAccessoryVC.singleton}
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
            self._inputVC = nil
            IAKitPreferences.accessory.updateAccessoryLayout(false)
        }
        self.reloadInputViews()
        self.updateSuggestionsBar()
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
        selectionView.hideCursor()
        RawIntensity.touchInterpreter.deactivate()
        return true
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
        guard delegate?.iaTextEditorRequestsPresentationOfOptionsVC(self) == true else {return}
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

