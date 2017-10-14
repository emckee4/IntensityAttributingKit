//
//  IAKeyboard.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/25/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//
import UIKit

///The IAKeyboard provides the primary means for inputing intensity attributed text. It displays a configurable set of PressureKeys and ExpandingPressureKeys (via the KeyboardLayoutView) and packages/forwards their event data to the delegate IACompositeTextEditor. The IAKeyboard also handles the autocaps and suggestion bar content generation when it is active and in the foreground (as the system keyboard does for itself when presented).
class IAKeyboard: UIInputViewController, KeyboardViewDelegate, SuggestionBarDelegate {
    
    static var singleton:IAKeyboard = IAKeyboard(nibName: nil, bundle: nil)
        
    weak var delegate:IAKeyboardDelegate!
    
    var keyboardView:KeyboardLayoutView!
    
    weak var shiftKey:LockingKey? {
        return keyboardView?.shiftKey
    }
    
    var shiftKeyIsSelected:Bool {
        return shiftKey?.isSelected ?? false
    }
    
    var currentKeyset = AvailableIAKeysets.BasicEnglish {
        didSet{currentKeyPageNumber = 0}
    }
    var currentKeyPageNumber = 0 {
        didSet{currentKeyPageNumber >= currentKeyset.totalKeyPages ? currentKeyPageNumber = 0: ()}
    }
    var backgroundColor:UIColor = IAKitPreferences.visualPreferences.kbBackgroundColor //UIColor(white: 0.55, alpha: 1.0)
    
    var keyboardSuggestionBarIsEnabled:Bool {return true}

    
    var textChecker:UITextChecker!
    fileprivate let puncCharset = CharacterSet(charactersIn: ".?!")
    
    ///If the last space inserted was inserted as a result of a suggestion insertion then we will remove it when inserting certain punctuation
    fileprivate var softSpace:Bool = false
    ///Value is set true by textWillChange, causing selectionDidChange to be ignored until textDidChange fires.
    fileprivate var textChangeInProgress = false
    //MARK:- View lifecyle functions
    
    override func loadView() {
        keyboardView = KeyboardLayoutView(frame: CGRect.zero, inputViewStyle: .keyboard)
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.backgroundColor = self.backgroundColor
        inputView = keyboardView
        keyboardView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textChecker = UITextChecker()
        self.inputView?.layer.rasterizationScale = UIScreen.main.scale
        self.inputView?.layer.shouldRasterize = true
        updateKeyMapping()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //if verticalStackView.hidden {verticalStackView.hidden = false}
        if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
            keyboardView.setConstraintsForOrientation(.landscapeRight)
        } else {
            keyboardView.setConstraintsForOrientation(.portrait)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareKeyboardForAppearance()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.width > size.height {
            keyboardView.setConstraintsForOrientation(.landscapeRight)
        } else {
            keyboardView.setConstraintsForOrientation(.portrait)
        }
        super.viewWillTransition(to: size, with: coordinator)
    }

    fileprivate var disableRasterizationUntil: TimeInterval = 0
    func preventRasterizationForDuration(_ duration:Double){
        let until = ProcessInfo.processInfo.systemUptime + duration
        guard until > disableRasterizationUntil else {return}  //check if we don't need to do anything because we're already rasterizing for the duration
        let ms:Int64 = Int64(duration * 1000) + 10
        self.inputView!.layer.shouldRasterize = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(ms * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: {
            guard ProcessInfo.processInfo.systemUptime >= self.disableRasterizationUntil else {return}
            self.inputView?.layer.shouldRasterize = true
        })
    }
   
    //MARK:- Key actions
    
    func backspaceKeyPressed(){
        textDocumentProxy.deleteBackward()
        //self.delegate?.iaKeyboardDeleteBackwards?(self)
    }
    ///cycles the pages of the current keyset
    func swapKeysetPageButtonPressed(){
        currentKeyPageNumber += 1
        updateKeyMapping()
    }
    
    ///All control elements adopting the KeyControl protocol deliver their user interaction events through this function
    func pressureKeyPressed(_ sender: PressureControl, actionName: String, intensity: Int) {
        //self.intensity = intensity
        preventRasterizationForDuration(5.0)
        UIDevice.current.playInputClick()
        var insertionText:String!
        if shiftKey?.isSelected == true{
            shiftKey?.deselect(overrideSelectedLock: false)
            updateKeyMapping()
            //self.textDocumentProxy.insertText(actionName.uppercaseString)
            insertionText = actionName.uppercased()
        } else {
            insertionText = actionName
        }
        
        
        if softSpace == true && actionName.utf16.count == 1 && puncCharset.contains(UnicodeScalar(actionName.utf16.first!)!) {
            ///replace the softSpace with the punctuation
            if let iaTE = delegate as? IACompositeTextEditor {
                if iaTE.selectedRange?.isEmpty == true && iaTE.selectedRange!.lowerBound > 0{
                    let newIndex = iaTE.selectedRange!.lowerBound - 1
                    iaTE.selectedRange = newIndex..<newIndex
                    insertionText = insertionText + " "
                }
            }
        }
        self.delegate?.iaKeyboard(self, insertTextAtCursor: insertionText, intensity: intensity)
    }
    
    
    override func textWillChange(_ textInput: UITextInput?) {
        textChangeInProgress = true
    }
    
    override func selectionDidChange(_ textInput: UITextInput?) {
        softSpace = false
        guard textChangeInProgress == false else {return}
        updateSuggestionBar()
        autoCapsIfNeeded()
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        guard delegate?.keyboardIsIAKeyboard ?? false else {return}
        updateSuggestionBar()
        autoCapsIfNeeded()
    }
    
    
    func prepareKeyboardForAppearance(){
        self.shiftKey?.deselect(overrideSelectedLock: true)
        softSpace = false
        updateSuggestionBar()
        autoCapsIfNeeded()
        updateKeyMapping()
    }
    
    
    func autoCapsIfNeeded(){
        guard let editor = delegate as? IACompositeTextEditor, editor.selectedRange != nil else {return}
        guard editor.hasText && editor.selectedRange!.lowerBound > 0 else {
            self.shiftKey?.isSelected = true; updateKeyMapping();return
        }
        let preceedingTextStart = max(editor.selectedRange!.lowerBound - 4, 0)
        let preceedingText = editor.text(in: IATextRange(range: preceedingTextStart..<editor.selectedRange!.lowerBound))!
        
        ///Returns true if the reversed text begins with whitespace characters, then is followed by puncuation, false otherwise. (e.g. "X. " would return true while "sfs", "s  ", or "X." would return false.
        func easierThanRegex(_ text:String)->Bool{
            guard text.isEmpty == false else {return false}
            guard let last = text.utf16.last, let lastScalar = UnicodeScalar(last),  CharacterSet.whitespacesAndNewlines.contains(lastScalar) else {return false}
            for rChar in preceedingText.utf16.reversed() {
                guard let rCharScalar = UnicodeScalar(rChar) else {return false}
                if CharacterSet.whitespacesAndNewlines.contains(rCharScalar) {
                    continue
                } else if puncCharset.contains(rCharScalar) {
                    return true
                } else {
                    return false
                }
            }
            return false
        }
        if  easierThanRegex(preceedingText){
            self.shiftKey?.isSelected = true
            updateKeyMapping()
        } else {
            self.shiftKey?.deselect(overrideSelectedLock: false)
            updateKeyMapping()
            return
        }
    }
    
    func updateSuggestionBar(){
        guard suggestionBarActive else {return}
        let suggestionsBar = keyboardView.suggestionsBar
        if let editor = delegate as? IACompositeTextEditor, editor.selectedRange != nil {
            let lang = self.textInputMode?.primaryLanguage ?? Locale.preferredLanguages.first!
            if editor.selectedRange!.isEmpty {
                //get range and text for correction
                let iaPosition = editor.selectedIATextRange!.iaStart
                
                if editor.tokenizer.isPosition(iaPosition, withinTextUnit: .word, inDirection: 0) {
                    //we're inside of a word but not at its end. Consider trying corrections
                    suggestionsBar?.updateSuggestions([])
                    editor.unmarkText()
                } else if let rangeOfCurrentWord = editor.tokenizer.rangeEnclosingPosition(iaPosition, with: .word, inDirection: 1) as? IATextRange { //editor.tokenizer.isPosition(iaPosition, withinTextUnit: .Word, inDirection: 1)
                    //the pos should be within a text unit and at its end --- we will highlight here
                    
                    var suggestions:[String]!
                    if rangeOfCurrentWord.nsrange().length > 2 {
                        suggestions = (textChecker.guesses(forWordRange: rangeOfCurrentWord.nsrange(),in: editor.iaString.text, language: lang) ?? [])
                    }
//                    if suggestions == nil {
//                        suggestions = (textChecker.completionsForPartialWordRange(rangeOfCurrentWord.nsrange(), inString: editor.iaString.text, language: lang) as? [String])
//                    }
                    
                    if suggestions?.isEmpty == false {
                        editor.markedTextRange = rangeOfCurrentWord
                        suggestionsBar?.updateSuggestions(suggestions)
                    } else {
                        suggestionsBar?.updateSuggestions([])
                        editor.unmarkText()
                    }
                } else {
                    //we should be in some whitespace, so no highlighting
                    suggestionsBar?.updateSuggestions([])
                    editor.unmarkText()
                }
                
            } else { //selected range is non empty
                //check if selected range starts/ends on word boundaries. If so we can make suggestions.
                if editor.tokenizer.isPosition(editor.selectedIATextRange!.iaStart, atBoundary: .word, inDirection: 1) &&
                    editor.tokenizer.isPosition(editor.selectedIATextRange!.iaEnd, atBoundary: .word, inDirection: 0) {
                    let suggestions:[String] = (textChecker.completions(forPartialWordRange: editor.selectedRange!.nsRange, in: editor.iaString.text, language: lang)) ?? []
                    suggestionsBar?.updateSuggestions(suggestions)
                } else {
                    //we aren't cleanly on boundaries so we won't be making suggestions
                    suggestionsBar?.updateSuggestions([])
                }
                editor.unmarkText()
            }
        } else {
            //we either have a nil delegate or nil selectedRange on the editor
            suggestionsBar?.updateSuggestions([])
        }
    }
    
    func shiftKeyPressed(_ sender:LockingKey!){
        updateKeyMapping()
    }

    fileprivate func updateKeyMapping(){
        keyboardView.setKeyset(currentKeyset, pageNumber: currentKeyPageNumber, shiftSelected: shiftKey?.isSelected ?? false)
    }
    
    func suggestionSelected(_ suggestionBar: SuggestionBarView!, suggestionString: String, intensity: Int) {
        softSpace = delegate?.iaKeyboard(self, suggestionSelected: suggestionString, intensity: intensity) ?? false
    }
    
    var suggestionBarActive:Bool {
        get{return !keyboardView.suggestionsBar.isHidden}
        set{keyboardView.suggestionsBar.isHidden = !newValue}
    }
    
}




