//
//  IATEDelegateConformance.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/3/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit



///IAKeyboardDelegate implementation
extension IATextEditor:IAKeyboardDelegate {
    
    func iaKeyboard(insertTextAtCursor text: String, intensity: Int) {
        let cursorLoc = self.selectedRange.location + text.utf16.count
        let replacementIA = self.iaString!.emptyCopy()
        replacementIA.insertAtPosition(text, position: 0, intensity: intensity, attributes: self.baseAttributes)
        self.iaString!.replaceRange(replacementIA, range: self.selectedRange.toRange()!)
        self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: replacementIA.convertToNSAttributedString())
        
        self.selectedRange = NSRange(location: cursorLoc, length: 0)

    }
    
    func iaKeyboardDeleteBackwards() {
        if selectedRange.length > 0 {
            let nextCursor = NSMakeRange(self.selectedRange.location,0)
            self.iaString!.removeRange(selectedRange.intRange)
            self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: NSAttributedString())
            self.selectedRange = nextCursor
        } else if selectedRange.location > 0 {
            let remRange = (self.selectedRange.location - 1)..<self.selectedRange.location
            self.iaString!.removeRange(remRange)
            self.textStorage.replaceCharactersInRange(remRange.nsRange, withAttributedString: NSAttributedString())
            self.selectedRange = NSMakeRange(remRange.startIndex, 0)
        } else {
            return
        }
    }
    
}




///IAAccessoryDelegate implementation
extension IATextEditor: IAAccessoryDelegate {
    
    func keyboardChangeButtonPressed(){
        swapKB()
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
    
    func defaultIntensityUpdated(withValue value:Int){
        self.defaultIntensity = value
    }
    
    ///The user has pressed the iaAccessory lock intensity button. Return true if the change in states should be accepted and reflected by the indicator.
    func iaAccessoryDidSetIntensityLock(toValue: Bool) {
        self.intensityChangesDynamically = toValue
    }

    
    
}