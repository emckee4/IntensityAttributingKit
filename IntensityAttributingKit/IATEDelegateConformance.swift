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
        updateBaseAttributes()
        let baseAtts = self.baseAttributes
        if self.selectedRange.length == 0 {
            //insert
            self.iaString!.insertAtPosition(text, position: self.selectedRange.location, intensity: intensity, attributes: baseAtts)
        } else {
            //replaceRange
            let rep = IAString(text: text, intensity: intensity, attributes: baseAtts)
            self.iaString!.replaceRange(rep, range: self.selectedRange.toRange()!)
        }
        //rerender, update cursor position
        renderIAString()
        self.selectedRange = NSRange(location: cursorLoc, length: 0)
    }
    
    func iaKeyboardDeleteBackwards() {
        let nextLoc = self.selectedRange.location > 0 ? self.selectedRange.location - 1 : 0
        if self.selectedRange.length == 0 && self.selectedRange.location > 0{
            //insert
            self.iaString!.removeRange((self.selectedRange.location - 1)..<self.selectedRange.location)
        } else if self.selectedRange.length > 0 {
            self.iaString!.removeRange(self.selectedRange.intRange)
        } else {
            return
        }
        renderIAString()
        self.selectedRange = NSMakeRange(nextLoc, 0)
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
    
    
}