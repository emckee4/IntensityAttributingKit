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
    
    func iaKeyboard(iaKeyboard:IAKeyboard, insertTextAtCursor text: String, intensity: Int) {
        let cursorLoc = self.selectedRange.location + text.utf16.count
        let replacementIA = self.iaString!.emptyCopy()
        replacementIA.insertAtPosition(text, position: 0, intensity: intensity, attributes: self.baseAttributes)
        //self.iaString!.replaceRange(replacementIA, range: self.selectedRange.toRange()!)
        //self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: replacementIA.convertToNSAttributedString())
        self.iaString!.replaceRangeUpdatingTextStorage(replacementIA, range: self.selectedRange.toRange()!, textStorage: self.textStorage)
        self.selectedRange = NSRange(location: cursorLoc, length: 0)
        iaKeyboard.autoCapsIfNeeded()
        //updateSuggestionsBar()  //This is called automatically when selectedRange is updated
    }
    
    func updateSuggestionsBar(){
        //guard text != " " else {return} //handle space
        rangeForSuggestionReplacement = nil
        guard let iaKB = (self.inputViewController as? IAKeyboard) where iaKB.suggestionBarActive == true else {return}
        guard let textPosition = selectedTextRange?.start where selectedTextRange?.empty  == true && tokenizer.isPosition(textPosition, atBoundary: .Word, inDirection: 0) else {
            iaKB.updateSuggestions([])
            return
        }
        
        let lang = self.textInputMode?.primaryLanguage ?? NSLocale.preferredLanguages().first!
        guard let wordRange = self.tokenizer.rangeEnclosingPosition(textPosition, withGranularity: UITextGranularity.Word, inDirection: 1) else {iaKB.updateSuggestions([]);return}

        let start:Int = self.offsetFromPosition(self.beginningOfDocument, toPosition: wordRange.start)
        let length:Int = self.offsetFromPosition(wordRange.start, toPosition: wordRange.end)
        ///The above is more likely to correspond with a String's native index than with an nsrange/utf16 range, but we will use it as is for now
        
        let wordNSRange = NSMakeRange(start, length)
        rangeForSuggestionReplacement = wordNSRange
        let completions:[String]! = textChecker.completionsForPartialWordRange(wordNSRange, inString: self.text, language: lang) as? [String]
        let suggestions:[String]! = textChecker.guessesForWordRange(wordNSRange, inString: self.text, language: lang) as? [String]
        var mixedSuggestions:[String] = []
        if (completions != nil && !completions.isEmpty) ||  (suggestions != nil && !suggestions.isEmpty) {
            for i in 0..<10 {
                if completions?.count > i {mixedSuggestions.append(completions[i])}
                if suggestions?.count > i {mixedSuggestions.append(suggestions[i])}
                if mixedSuggestions.count >= 10 {break}
            }
        }
        //if completions != nil {print("completions: \(completions)")}
        //if suggestions != nil {print("suggestions: \(suggestions)")}
        iaKB.updateSuggestions(mixedSuggestions)
        
    }
    
    func iaKeyboard(iaKeyboard: IAKeyboard, suggestionSelected text: String, intensity: Int) {
        //print("suggestions selected: \(text)")
        let repCharCount = text.characters.count
        guard repCharCount > 0 else {return}
        guard let repRange = rangeForSuggestionReplacement?.toRange() else {return}

        let replacementIA = self.iaString!.emptyCopy()
        replacementIA.insertAtPosition(text, position: 0, intensity: intensity, attributes: self.baseAttributes)
        self.iaString!.replaceRangeUpdatingTextStorage(replacementIA, range: repRange, textStorage: self.textStorage)
        self.selectedRange = NSRange(location: repRange.startIndex + replacementIA.length, length: 0)
        iaKeyboard.autoCapsIfNeeded()
        
    }
    
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
    

    override public func deleteBackward() {
        if selectedRange.length > 0 {
            let nextCursor = NSMakeRange(self.selectedRange.location,0)
            self.iaString!.removeRange(selectedRange.toRange()!)
            self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: NSAttributedString())
            self.selectedRange = nextCursor
        } else if selectedRange.location > 0 {
            
            let remRange = (self.iaString!.text as NSString).rangeOfComposedCharacterSequencesForRange(NSMakeRange(selectedRange.location - 1, 0)).toRange()!
            //let remRange = (self.selectedRange.location - 1)..<self.selectedRange.location
            //self.iaString!.removeRange(remRange)
            //self.textStorage.replaceCharactersInRange(remRange.nsRange, withAttributedString: NSAttributedString())
            self.iaString!.replaceRangeUpdatingTextStorage(self.iaString!.emptyCopy(), range: remRange, textStorage: self.textStorage)
            self.selectedRange = NSMakeRange(remRange.startIndex, 0)
        } else {
            return
        }
        (self.inputViewController as? IAKeyboard)?.autoCapsIfNeeded()
        
        if iaKeyboardIsShowing() {
            updateSuggestionsBar()
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
        let optionsVC = IAKitSettingsTableViewController()
        let modalContainer = ModalContainerViewController()
        modalContainer.addChildViewController(optionsVC)
        modalContainer.dismissalCompletionBlock = {self.becomeFirstResponder()}
        editorDelegate?.iaTextEditorRequestsPresentation(self, shouldPresentVC: modalContainer)
        
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
        ///modify the intensities in the selected range
        if self.selectedRange.length > 0 {
            self.iaString!.intensities.replaceRange(self.selectedRange.toRange()!, with: Array(count: self.selectedRange.length, repeatedValue: value))
            let nsReplacement = self.iaString!.iaSubstringFromRange(self.selectedRange.toRange()!).convertToNSAttributedString()
            self.textStorage.replaceCharactersInRange(self.selectedRange, withAttributedString: nsReplacement)
        }
        
    }
    
    public func requestTokenizerChange(toValue: IAStringTokenizing) {
        self.setIATokenizer(toValue)
    }
    
    func iaKeyboardIsShowing() -> Bool {
        return self.keyboardIsIAKeyboard ?? false
    }
    
}