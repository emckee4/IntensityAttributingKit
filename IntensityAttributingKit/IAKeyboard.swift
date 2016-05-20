//
//  IAKeyboard.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/25/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//
import UIKit

class IAKeyboard: UIInputViewController, KeyboardViewDelegate, SuggestionBarDelegate {
    
    static var singleton:IAKeyboard = IAKeyboard(nibName: nil, bundle: nil)
        
    weak var delegate:IAKeyboardDelegate!
    
    var keyboardView:KeyboardLayoutView!
    
    weak var shiftKey:LockingKey? {
        return keyboardView?.shiftKey
    }
    
    var shiftKeyIsSelected:Bool {
        return shiftKey?.selected ?? false
    }
    
    var currentKeyset = AvailableIAKeysets.BasicEnglish {
        didSet{currentKeyPageNumber = 0}
    }
    var currentKeyPageNumber = 0 {
        didSet{currentKeyPageNumber >= currentKeyset.totalKeyPages ? currentKeyPageNumber = 0: ()}
    }
    var backgroundColor:UIColor = UIColor(white: 0.55, alpha: 1.0)
    
    var keyboardSuggestionBarIsEnabled:Bool {return true}

    
    var textChecker:UITextChecker!
    private let puncCharset = NSCharacterSet(charactersInString: ".?!")
    
    ///If the last space inserted was inserted as a result of a suggestion insertion then we will remove it when inserting certain punctuation
    private var softSpace:Bool = false
    ///Value is set true by textWillChange, causing selectionDidChange to be ignored until textDidChange fires.
    private var textChangeInProgress = false
    //MARK:- View lifecyle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textChecker = UITextChecker()
        
        keyboardView = KeyboardLayoutView(frame: CGRectZero, inputViewStyle: .Keyboard)
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        //inputView?.addSubview(keyboardView)
        inputView = keyboardView
        keyboardView.topAnchor.constraintEqualToAnchor(inputView?.topAnchor).active = true
        keyboardView.bottomAnchor.constraintEqualToAnchor(inputView?.bottomAnchor).active = true
        keyboardView.leftAnchor.constraintEqualToAnchor(inputView?.leftAnchor).active = true
        keyboardView.rightAnchor.constraintEqualToAnchor(inputView?.rightAnchor).active = true
        inputView?.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.delegate = self
        
        self.inputView?.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.inputView?.layer.shouldRasterize = true
        updateKeyMapping()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //if verticalStackView.hidden {verticalStackView.hidden = false}
        if UIScreen.mainScreen().bounds.width > UIScreen.mainScreen().bounds.height {
            keyboardView.setConstraintsForOrientation(.LandscapeRight)
        } else {
            keyboardView.setConstraintsForOrientation(.Portrait)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        prepareKeyboardForAppearance()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if size.width > size.height {
            keyboardView.setConstraintsForOrientation(.LandscapeRight)
        } else {
            keyboardView.setConstraintsForOrientation(.Portrait)
        }
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    private var disableRasterizationUntil: NSTimeInterval = 0
    func preventRasterizationForDuration(duration:Double){
        let until = NSProcessInfo.processInfo().systemUptime + duration
        guard until > disableRasterizationUntil else {return}  //check if we don't need to do anything because we're already rasterizing for the duration
        let ms:Int64 = Int64(duration * 1000) + 10
        self.inputView!.layer.shouldRasterize = false
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, ms * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue(), {
            guard NSProcessInfo.processInfo().systemUptime >= self.disableRasterizationUntil else {return}
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
        currentKeyPageNumber++
        updateKeyMapping()
    }
    
    ///All control elements adopting the KeyControl protocol deliver their user interaction events through this function
    func pressureKeyPressed(sender: PressureControl, actionName: String, intensity: Int) {
        //self.intensity = intensity
        preventRasterizationForDuration(5.0)
        UIDevice.currentDevice().playInputClick()
        var insertionText:String!
        if shiftKey?.selected == true{
            shiftKey?.deselect(overrideSelectedLock: false)
            updateKeyMapping()
            //self.textDocumentProxy.insertText(actionName.uppercaseString)
            insertionText = actionName.uppercaseString
        } else {
            insertionText = actionName
        }
        
        
        if softSpace == true && actionName.utf16.count == 1 && puncCharset.characterIsMember(actionName.utf16.first!) {
            ///replace the softSpace with the punctuation
            if let iaTE = delegate as? IACompositeTextEditor {
                if iaTE.selectedRange?.isEmpty == true && iaTE.selectedRange!.startIndex > 0{
                    let newIndex = iaTE.selectedRange!.startIndex - 1
                    iaTE.selectedRange = newIndex..<newIndex
                    insertionText = insertionText + " "
                }
            }
        }
        self.delegate?.iaKeyboard(self, insertTextAtCursor: insertionText, intensity: intensity)
    }
    
    
    override func textWillChange(textInput: UITextInput?) {
        textChangeInProgress = true
    }
    
    override func selectionDidChange(textInput: UITextInput?) {
        softSpace = false
        guard textChangeInProgress == false else {return}
        updateSuggestionBar()
        autoCapsIfNeeded()
    }
    
    override func textDidChange(textInput: UITextInput?) {
        guard delegate?.keyboardIsIAKeyboard ?? false else {return}
        updateSuggestionBar()
        autoCapsIfNeeded()
    }
    
    
    func prepareKeyboardForAppearance(){
        self.shiftKey?.deselect(overrideSelectedLock: true)
        softSpace = false
        updateKeyMapping()
        autoCapsIfNeeded()
    }
    
    
    func autoCapsIfNeeded(){
        guard let editor = delegate as? IACompositeTextEditor where editor.selectedRange != nil else {return}
        guard editor.hasText() && editor.selectedRange!.startIndex > 0 else {
            self.shiftKey?.selected = true; updateKeyMapping();return
        }
        let preceedingTextStart = max(editor.selectedRange!.startIndex - 4, 0)
        let preceedingText = editor.textInRange(IATextRange(range: preceedingTextStart..<editor.selectedRange!.startIndex))!
        
        ///Returns true if the reversed text begins with whitespace characters, then is followed by puncuation, false otherwise. (e.g. "X. " would return true while "sfs", "s  ", or "X." would return false.
        func easierThanRegex(text:String)->Bool{
            guard text.isEmpty == false else {return false}
            guard NSCharacterSet.whitespaceAndNewlineCharacterSet().characterIsMember(text.utf16.last!) else {return false}
            for rChar in preceedingText.utf16.reverse() {
                if NSCharacterSet.whitespaceAndNewlineCharacterSet().characterIsMember(rChar) {
                    continue
                } else if puncCharset.characterIsMember(rChar) {
                    return true
                } else {
                    return false
                }
            }
            return false
        }
        if  easierThanRegex(preceedingText){
            self.shiftKey?.selected = true
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
        if let editor = delegate as? IACompositeTextEditor where editor.selectedRange != nil {
            let lang = self.textInputMode?.primaryLanguage ?? NSLocale.preferredLanguages().first!
            if editor.selectedRange!.isEmpty {
                //get range and text for correction
                let iaPosition = editor.selectedIATextRange!.iaStart
                
                if editor.tokenizer.isPosition(iaPosition, withinTextUnit: .Word, inDirection: 0) {
                    //we're inside of a word but not at its end. Consider trying corrections
                    suggestionsBar.updateSuggestions([])
                    editor.unmarkText()
                } else if let rangeOfCurrentWord = editor.tokenizer.rangeEnclosingPosition(iaPosition, withGranularity: .Word, inDirection: 1) as? IATextRange { //editor.tokenizer.isPosition(iaPosition, withinTextUnit: .Word, inDirection: 1)
                    //the pos should be within a text unit and at its end --- we will highlight here
                    
                    var suggestions:[String]!
                    if rangeOfCurrentWord.nsrange().length > 2 {
                        suggestions = textChecker.guessesForWordRange(rangeOfCurrentWord.nsrange(),inString: editor.iaString.text, language: lang) as? [String]
                    }
//                    if suggestions == nil {
//                        suggestions = (textChecker.completionsForPartialWordRange(rangeOfCurrentWord.nsrange(), inString: editor.iaString.text, language: lang) as? [String])
//                    }
                    
                    if suggestions?.isEmpty == false {
                        editor.markedTextRange = rangeOfCurrentWord
                        suggestionsBar.updateSuggestions(suggestions)
                    } else {
                        suggestionsBar.updateSuggestions([])
                        editor.unmarkText()
                    }
                } else {
                    //we should be in some whitespace, so no highlighting
                    suggestionsBar.updateSuggestions([])
                    editor.unmarkText()
                }
                
            } else { //selected range is non empty
                //check if selected range starts/ends on word boundaries. If so we can make suggestions.
                if editor.tokenizer.isPosition(editor.selectedIATextRange!.iaStart, atBoundary: .Word, inDirection: 1) &&
                    editor.tokenizer.isPosition(editor.selectedIATextRange!.iaEnd, atBoundary: .Word, inDirection: 0) {
                    let suggestions:[String] = (textChecker.completionsForPartialWordRange(editor.selectedRange!.nsRange, inString: editor.iaString.text, language: lang) as? [String]) ?? []
                    suggestionsBar.updateSuggestions(suggestions)
                } else {
                    //we aren't cleanly on boundaries so we won't be making suggestions
                    suggestionsBar.updateSuggestions([])
                }
                editor.unmarkText()
            }
            
            /*
            e var $pos2 = editor.selectedIATextRange!.iaStart
            e var $tok2 = editor.tokenizer
            
            e $tok.isPosition($pos2, atBoundary: .Word, inDirection: 0)
            e $tok.isPosition($pos2, withinTextUnit: .Word, inDirection: 0)
            e $tok.rangeEnclosingPosition($pos2, withGranularity: .Word, inDirection: 0)
            e $tok.positionFromPosition($pos2, toBoundary: .Word, inDirection: 1) as! IATextPosition
        */
        } else {
            //we either have a nil delegate or nil selectedRange on the editor
            suggestionsBar.updateSuggestions([])
        }
    }
    
    func shiftKeyPressed(sender:LockingKey!){
        updateKeyMapping()
    }

    private func updateKeyMapping(){
        keyboardView.setKeyset(currentKeyset, pageNumber: currentKeyPageNumber, shiftSelected: shiftKey?.selected ?? false)
    }
    
    func suggestionSelected(suggestionBar: SuggestionBarView!, suggestionString: String, intensity: Int) {
        softSpace = delegate?.iaKeyboard(self, suggestionSelected: suggestionString, intensity: intensity) ?? false
    }
    
    var suggestionBarActive:Bool {
        get{return !keyboardView.suggestionsBar.hidden}
        set{keyboardView.suggestionsBar.hidden = !newValue}
    }
    
}




