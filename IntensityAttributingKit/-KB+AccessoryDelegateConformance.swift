//
//  KB+AccessoryDelegateConformance.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/7/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

//import Foundation




///IAKeyboardDelegate implementation
//extension IACompositeTextEditor:IAKeyboardDelegate {
//    
//    func iaKeyboard(iaKeyboard:IAKeyboard, insertTextAtCursor text: String, intensity: Int) {
//        guard let range = selectedRange else {return}
//        let rep = IAString(text: text, intensity: intensity, attributes: self.baseAttributes)
//        replaceIAStringRange(rep, range: range)
//        iaKeyboard.autoCapsIfNeeded()
//    }
//    
//    func updateSuggestionsBar(){
//        //guard text != " " else {return} //handle space
//        rangeForSuggestionReplacement = nil
//        guard let iaKB = (self.inputViewController as? IAKeyboard) where iaKB.suggestionBarActive == true else {return}
//        guard let textPosition = selectedTextRange?.start where selectedTextRange?.empty  == true && tokenizer.isPosition(textPosition, atBoundary: .Word, inDirection: 0) else {
//            iaKB.updateSuggestions([])
//            return
//        }
//        
//        let lang = self.textInputMode?.primaryLanguage ?? NSLocale.preferredLanguages().first!
//        guard let wordRange = self.tokenizer.rangeEnclosingPosition(textPosition, withGranularity: UITextGranularity.Word, inDirection: 1) else {iaKB.updateSuggestions([]);return}
//        
//        let start:Int = self.offsetFromPosition(self.beginningOfDocument, toPosition: wordRange.start)
//        let length:Int = self.offsetFromPosition(wordRange.start, toPosition: wordRange.end)
//        ///The above is more likely to correspond with a String's native index than with an nsrange/utf16 range, but we will use it as is for now
//        
//        let wordNSRange = NSMakeRange(start, length)
//        rangeForSuggestionReplacement = wordNSRange
//        let completions:[String]! = textChecker.completionsForPartialWordRange(wordNSRange, inString: self.text, language: lang) as? [String]
//        let suggestions:[String]! = textChecker.guessesForWordRange(wordNSRange, inString: self.text, language: lang) as? [String]
//        var mixedSuggestions:[String] = []
//        if (completions != nil && !completions.isEmpty) ||  (suggestions != nil && !suggestions.isEmpty) {
//            for i in 0..<10 {
//                if completions?.count > i {mixedSuggestions.append(completions[i])}
//                if suggestions?.count > i {mixedSuggestions.append(suggestions[i])}
//                if mixedSuggestions.count >= 10 {break}
//            }
//        }
//        //if completions != nil {print("completions: \(completions)")}
//        //if suggestions != nil {print("suggestions: \(suggestions)")}
//        iaKB.updateSuggestions(mixedSuggestions)
//        
//    }
    
//    func iaKeyboard(iaKeyboard: IAKeyboard, suggestionSelected text: String, intensity: Int) {
//        //print("suggestions selected: \(text)")
//        let repCharCount = text.characters.count
//        guard repCharCount > 0 else {return}
//        guard let repRange = rangeForSuggestionReplacement?.toRange() else {return}
//        
//        let replacementIA = self.iaString!.emptyCopy()
//        replacementIA.insertAtPosition(text, position: 0, intensity: intensity, attributes: self.baseAttributes)
//        self.iaString!.replaceRangeUpdatingTextStorage(replacementIA, range: repRange, textStorage: self.textStorage)
//        self.selectedRange = NSRange(location: repRange.startIndex + replacementIA.length, length: 0)
//        iaKeyboard.autoCapsIfNeeded()
//        
//    }
    
    //
    //    func iaKeyboardDeleteBackwards(iaKeyboard:IAKeyboard) {
    //        if selectedRange.length > 0 {
    //            let nextCursor = NSMakeRange(self.selectedRange.location,0)
    //            self.iaString!.removeRange(selectedRange.toRange()!)
    //            self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: NSAttributedString())
    //            self.selectedRange = nextCursor
    //        } else if selectedRange.location > 0 {
    //
    //            let remRange = (self.iaString!.text as NSString).rangeOfComposedCharacterSequencesForRange(NSMakeRange(selectedRange.location - 1, 0)).toRange()!
    //            //let remRange = (self.selectedRange.location - 1)..<self.selectedRange.location
    //            //self.iaString!.removeRange(remRange)
    //            //self.textStorage.replaceCharactersInRange(remRange.nsRange, withAttributedString: NSAttributedString())
    //            self.iaString!.replaceRangeUpdatingTextStorage(self.iaString!.emptyCopy(), range: remRange, textStorage: self.textStorage)
    //            self.selectedRange = NSMakeRange(remRange.startIndex, 0)
    //        } else {
    //            return
    //        }
    //        iaKeyboard.autoCapsIfNeeded()
    //    }
    
    
//    override public func deleteBackward() {
//        if selectedRange.length > 0 {
//            let nextCursor = NSMakeRange(self.selectedRange.location,0)
//            self.iaString!.removeRange(selectedRange.toRange()!)
//            self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: NSAttributedString())
//            self.selectedRange = nextCursor
//        } else if selectedRange.location > 0 {
//            
//            let remRange = (self.iaString!.text as NSString).rangeOfComposedCharacterSequencesForRange(NSMakeRange(selectedRange.location - 1, 0)).toRange()!
//            //let remRange = (self.selectedRange.location - 1)..<self.selectedRange.location
//            //self.iaString!.removeRange(remRange)
//            //self.textStorage.replaceCharactersInRange(remRange.nsRange, withAttributedString: NSAttributedString())
//            self.iaString!.replaceRangeUpdatingTextStorage(self.iaString!.emptyCopy(), range: remRange, textStorage: self.textStorage)
//            self.selectedRange = NSMakeRange(remRange.startIndex, 0)
//        } else {
//            return
//        }
//        (self.inputViewController as? IAKeyboard)?.autoCapsIfNeeded()
//        
//        if iaKeyboardIsShowing() {
//            updateSuggestionsBar()
//        }
//    }
    
    
//}




///IAAccessoryDelegate implementation
//extension IACompositeTextEditor: IAAccessoryDelegate {
//    
//    func accessoryKeyboardChangeButtonPressed(accessory:IAAccessoryVC!){
//        swapKB()
//    }
//    
//    //func defaultIntensityUpdated(withValue value:Float)
//    func accessoryOptionButtonPressed(accessory:IAAccessoryVC!){
//        guard editorDelegate != nil else {return}
//        let optionsVC = IAKitSettingsTableViewController()
//        let modalContainer = ModalContainerViewController()
//        modalContainer.addChildViewController(optionsVC)
//        modalContainer.dismissalCompletionBlock = {self.becomeFirstResponder()}
//        editorDelegate?.iaTextEditorRequestsPresentation(self, shouldPresentVC: modalContainer)
//    }
//    
////    func requestTransformerChange(accessory:IAAccessoryVC!, toTransformerWithName name:String){
////        guard let newTransformer = IntensityTransformers(rawValue: name) else {return}
////        accessory.setTransformKeyForScheme(withName: newTransformer.rawValue)
////        guard newTransformer != iaString.baseOptions.renderScheme else {return}
////        iaString.baseOptions.renderScheme = newTransformer
////        rerenderIAString()
////    }
//    func accessoryRequestsTransformerChange(accessory: IAAccessoryVC!, toTransformer: IntensityTransformers) -> Bool {
//        if toTransformer != iaString.baseOptions.renderScheme {
//            iaString.baseOptions.renderScheme = toTransformer
//            rerenderIAString()
//        }
//        return true
//    }
//    
////    //weak var presentingVC:UIViewController? {get}
////    func requestPickerLaunch(){
////        //TODO:move logic from IAAccessory to here. Call The editor's delegate to offer presentation of the picker
////        launchPicker()
////    }
//    func accessoryRequestsPickerLaunch(accessory: IAAccessoryVC!) {
//        launchPicker()
//    }
//    
////    func defaultIntensityUpdated(withValue value:Int){
////        self.defaultIntensity = value
////        ///modify the intensities in the selected range
////        if self.selectedRange.length > 0 {
////            self.iaString!.intensities.replaceRange(self.selectedRange.toRange()!, with: Array(count: self.selectedRange.length, repeatedValue: value))
////            let nsReplacement = self.iaString!.iaSubstringFromRange(self.selectedRange.toRange()!).convertToNSAttributedString()
////            self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: nsReplacement)
////        }
////        
////    }
//    func accessoryUpdatedDefaultIntensity(accessory: IAAccessoryVC!, withValue value: Int) {
//        //case: selection is empty: update current intensity
//        if self.selectedRange == nil || self.selectedRange!.isEmpty {
//            currentIntensity = value
//        } else {
//            //case: selection is not empty: update ranges intensity
//            //TODO: case: selection is not empty: update ranges intensity
//        }
//    }
//    
//    func accessoryRequestsSmoothingChange(accessory: IAAccessoryVC!, toValue: IAStringTokenizing) -> Bool {
//        if toValue != self.iaString.baseOptions.preferedSmoothing {
//            self.iaString.baseOptions.preferedSmoothing = toValue
//            rerenderIAString()
//        }
//        return true
//    }
//    
//    func iaKeyboardIsShowing() -> Bool {
//        return self.keyboardIsIAKeyboard ?? false
//    }
//}
/*
 func accessoryKeyboardChangeButtonPressed(accessory:IAAccessoryVC!)
 
 func accessoryOptionButtonPressed(accessory:IAAccessoryVC!)
 
 func accessoryRequestsTransformerChange(accessory:IAAccessoryVC!, toTransformer:IntensityTransformers)->Bool
 
 func accessoryRequestsPickerLaunch(accessory:IAAccessoryVC!)
 
 func accessoryUpdatedDefaultIntensity(withValue value:Int)
 
 func accessoryRequestsSmoothingChange(accessory:IAAccessoryVC!, toValue:IAStringTokenizing)->Bool
 
 func iaKeyboardIsShowing()->Bool
 */

