//
//  IAKeyboard.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/25/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//
import UIKit

class IAKeyboard: UIInputViewController, PressureKeyActionDelegate, SuggestionBarDelegate {
    
    static var singleton:IAKeyboard = IAKeyboard(nibName: nil, bundle: nil)
        
    weak var delegate:IAKeyboardDelegate!
    
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
    var suggestionsBar:SuggestionBarView!
    
    var textChecker:UITextChecker!
    private let puncCharset = NSCharacterSet(charactersInString: ".?!")
    
    ///If the last space inserted was inserted as a result of a suggestion insertion then we will remove it when inserting certain punctuation
    private var softSpace:Bool = false
    ///Value is set true by textWillChange, causing selectionDidChange to be ignored until textDidChange fires.
    private var textChangeInProgress = false
    

    
    //MARK:- UI visual constants

    private let kKeyBackgroundColor = UIColor.lightGrayColor()
    private let kKeyHeight:CGFloat = 40.0
    private let kStandardKeySpacing:CGFloat = 4.0
    private let kStackInset:CGFloat = 2.0
    private let kKeyCornerRadius:CGFloat = 4.0
    
    private var verticalStackView:UIStackView!
    private var qwertyStackView:UIStackView!
    private var asdfStackView:UIStackView!
    private var zxcvStackView:UIStackView!
    private var bottomStackView:UIStackView!
    
    //MARK:- Retained Constraints
    private var portraitOnlyConstraints:[NSLayoutConstraint] = []
    private var landscapeOnlyConstraints:[NSLayoutConstraint] = []
    
    //MARK:- Controls
    private var standardPressureKeys:[PressureKey] = []
    private var shiftKey:LockingKey!
    private var backspace:UIButton!
    private var swapKeysetButton:UIButton!
    private var returnKey:PressureView!
    private var spacebar:PressureKey!
    private var expandingPuncKey:ExpandingPressureKey!
    
    
    private lazy var bundle:NSBundle = { return NSBundle(forClass: self.dynamicType) }()
    
    //MARK:- View lifecyle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        suggestionsBar = SuggestionBarView(frame: CGRectZero)
        suggestionsBar.translatesAutoresizingMaskIntoConstraints = false
        suggestionsBar.delegate = self
        suggestionBarActive = IAKitPreferences.spellingSuggestionsEnabled
        setupQwertyRow()
        setupAsdfRow()
        setupZxcvRow()
        setupBottomRow()
        setupVerticalStackView()
        setupKeyConstraints()
        self.inputView?.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.inputView?.layer.shouldRasterize = true
        
        updateKeyMapping()
        textChecker = UITextChecker()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if verticalStackView.hidden {verticalStackView.hidden = false}
        if UIScreen.mainScreen().bounds.width > UIScreen.mainScreen().bounds.height {
            prepareForLandscape()
        } else {
            prepareForPortrait()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        prepareKeyboardForAppearance()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if size.width > size.height {
            prepareForLandscape()
        } else {
            prepareForPortrait()
        }
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
//    private var rasterizeUntil: NSTimeInterval = 0
//    ///Sets
//    func rasterizeWithDuration(duration:Double){
//        let until = NSProcessInfo.processInfo().systemUptime + duration
//        guard until > rasterizeUntil else {return}  //check if we don't need to do anything because we're already rasterizing for the duration
//        let ms:Int64 = Int64(duration * 1000) + 10
//        self.inputView!.layer.shouldRasterize = true
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, ms * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue(), {
//            guard NSProcessInfo.processInfo().systemUptime >= self.rasterizeUntil else {return}
//            self.inputView?.layer.shouldRasterize = false
//        })
//    }
    
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
    
    
    ///MARK:- Keyboard initial layout functions
    private func setupQwertyRow(){
        qwertyStackView = generateHorizontalStackView()
        for i in 0..<10 {
            let key = setupPressureKey(i + 1000)
            qwertyStackView.addArrangedSubview(key)
            standardPressureKeys.append(key)
        }
    }
    
    private func setupAsdfRow(){
        asdfStackView = generateHorizontalStackView()
        
        let leftPlaceholder = UIView()
        leftPlaceholder.tag = 2100
        let rightPlaceholder = UIView()
        rightPlaceholder.tag = 2101
        asdfStackView.addArrangedSubview(leftPlaceholder)
        for i in 0..<10 {
            let key = setupPressureKey(i + 2000)
            asdfStackView.addArrangedSubview(key)
            standardPressureKeys.append(key)
        }
        asdfStackView.addArrangedSubview(rightPlaceholder)
        let placeholderWidth = leftPlaceholder.widthAnchor.constraintEqualToAnchor(rightPlaceholder.widthAnchor) //local placeholders, any orientation
        placeholderWidth.priority = 999
        placeholderWidth.active = true
    }
    
    
    private func setupZxcvRow(){
        zxcvStackView = generateHorizontalStackView()
        
        shiftKey = LockingKey()
        shiftKey.tag = 3900

        let imageEdgeInsets = UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0)
        shiftKey.translatesAutoresizingMaskIntoConstraints = false
        shiftKey.setImage(UIImage(named: "caps1", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal )
        shiftKey.imageEdgeInsets = imageEdgeInsets
        shiftKey.imageView!.contentMode = .ScaleAspectFit
        shiftKey.layer.cornerRadius = kKeyCornerRadius
        shiftKey.backgroundColor = kKeyBackgroundColor
        shiftKey.setImage(UIImage(named: "caps2", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Selected)
        shiftKey.addTarget(self, action: "shiftKeyPressed", forControlEvents: .TouchUpInside)
        
        zxcvStackView.addArrangedSubview(shiftKey)
        
        let leftPlaceholder = UIView()
        leftPlaceholder.tag = 3100
        let rightPlaceholder = UIView()
        rightPlaceholder.tag = 3101
        zxcvStackView.addArrangedSubview( leftPlaceholder)
        
        for i in 0..<8 {
            let key = setupPressureKey(i + 3001)
            zxcvStackView.addArrangedSubview(key)
            standardPressureKeys.append(key)
        }
        
        zxcvStackView.addArrangedSubview(rightPlaceholder)
        
        backspace = UIButton()
        backspace.tag = 3901
        backspace.translatesAutoresizingMaskIntoConstraints = false
        backspace.setImage(UIImage(named: "backspace", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal )
        backspace.imageEdgeInsets = imageEdgeInsets
        backspace.imageView!.contentMode = .ScaleAspectFit
        backspace.backgroundColor = kKeyBackgroundColor
        backspace.layer.cornerRadius = kKeyCornerRadius
        zxcvStackView.addArrangedSubview(backspace)
        backspace.addTarget(self, action: "backspaceKeyPressed", forControlEvents: .TouchUpInside)
        
        
        let placeholderWidth = leftPlaceholder.widthAnchor.constraintEqualToAnchor(rightPlaceholder.widthAnchor)  //local placeholders, any orientation
        placeholderWidth.priority = 999
        placeholderWidth.active = true
    }
    
    
    private func setupBottomRow(){
        bottomStackView = generateHorizontalStackView()
        
        swapKeysetButton = UIButton(type: .System)
        swapKeysetButton.tag = 4900
        swapKeysetButton.setTitle("12/*", forState: .Normal)
        swapKeysetButton.titleLabel!.adjustsFontSizeToFitWidth = true
        swapKeysetButton.translatesAutoresizingMaskIntoConstraints = false
        swapKeysetButton.backgroundColor = kKeyBackgroundColor
        swapKeysetButton.layer.cornerRadius = kKeyCornerRadius
        swapKeysetButton.addTarget(self, action: "swapKeyset", forControlEvents: .TouchUpInside)
        bottomStackView.addArrangedSubview(swapKeysetButton)
        
        //spacebar
        
        spacebar = PressureKey()
        spacebar.tag = 4901
        spacebar.backgroundColor = kKeyBackgroundColor
        spacebar.setCharKey(" ")
        spacebar.delegate = self
        spacebar.layer.cornerRadius = kKeyCornerRadius
        spacebar.clipsToBounds = true
        bottomStackView.addArrangedSubview(spacebar)
        
        //expanding punctuation key

        expandingPuncKey = ExpandingPressureKey(frame:CGRectZero)
        expandingPuncKey.tag = 4900
        expandingPuncKey.delegate = self
        expandingPuncKey.backgroundColor = kKeyBackgroundColor

        expandingPuncKey.addKey(withTextLabel: ".", actionName: ".")
        expandingPuncKey.addKey(withTextLabel: ",", actionName: ",")
        expandingPuncKey.addKey(withTextLabel: "?", actionName: "?")
        expandingPuncKey.addKey(withTextLabel: "!", actionName: "!")
        
        expandingPuncKey.cornerRadius = kKeyCornerRadius
        bottomStackView.addArrangedSubview(expandingPuncKey)
        
        returnKey = PressureView()
        returnKey.tag = 4002
        returnKey.delegate = self
        let returnKeyView = UILabel()
        returnKeyView.text = "Return"
        returnKeyView.textAlignment = .Center
        returnKey.setAsSpecialKey(returnKeyView, actionName: "\n")
        returnKey.backgroundColor = kKeyBackgroundColor
        returnKey.layer.cornerRadius = kKeyCornerRadius
        bottomStackView.addArrangedSubview(returnKey)

    }
    
    
    
    private func setupVerticalStackView(){
        
        verticalStackView = UIStackView(arrangedSubviews: [suggestionsBar, qwertyStackView,asdfStackView,zxcvStackView,bottomStackView])
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .Vertical
        verticalStackView.distribution = .FillEqually
        verticalStackView.spacing = 5.0
        verticalStackView.alignment = .Fill
        verticalStackView.layoutMarginsRelativeArrangement = true
        
        verticalStackView.layoutMargins = UIEdgeInsets(top: kStackInset, left: kStackInset, bottom: kStackInset, right: kStackInset)
        
        view.addSubview(verticalStackView)
        verticalStackView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        verticalStackView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        verticalStackView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        verticalStackView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        
        view.backgroundColor = backgroundColor
        
    }
    

    
    private func setupKeyConstraints(){
        for key in standardPressureKeys[1..<standardPressureKeys.count]{
            let widthConstraint = key.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor)
            widthConstraint.priority = 999
            widthConstraint.active = true
        }
        
        backspace.widthAnchor.constraintEqualToAnchor(shiftKey.widthAnchor).active = true   //any orientation
        swapKeysetButton.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor).active = true //any orientation
        
        bottomStackView.heightAnchor.constraintEqualToAnchor(qwertyStackView.heightAnchor).active = true
        zxcvStackView.heightAnchor.constraintEqualToAnchor(qwertyStackView.heightAnchor).active = true
        asdfStackView.heightAnchor.constraintEqualToAnchor(qwertyStackView.heightAnchor).active = true

        
        ///setup portrait constraints
        portraitOnlyConstraints.append( expandingPuncKey.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor, multiplier: 1.5) )
        portraitOnlyConstraints.append( shiftKey.widthAnchor.constraintGreaterThanOrEqualToAnchor(standardPressureKeys[0].widthAnchor, multiplier: 1.3) )
        portraitOnlyConstraints.append( shiftKey.widthAnchor.constraintLessThanOrEqualToAnchor(standardPressureKeys[0].widthAnchor, multiplier: 1.5) )
        portraitOnlyConstraints.append( returnKey.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor, multiplier: 2.0) )
        
        ///setup landscape constraints
        landscapeOnlyConstraints.append( expandingPuncKey.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor, multiplier: 1.0) )
        landscapeOnlyConstraints.append( shiftKey.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor) )
        landscapeOnlyConstraints.append( returnKey.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor, multiplier: 1.0) )

    }
    
    //MARK:- Changing constraints for layout change
    
    private func prepareForLandscape(){
        NSLayoutConstraint.deactivateConstraints(portraitOnlyConstraints)
        NSLayoutConstraint.activateConstraints(landscapeOnlyConstraints)
        //perform any key hides/unhides in stackviews here
        
    }
    
    private func prepareForPortrait(){
        NSLayoutConstraint.deactivateConstraints(landscapeOnlyConstraints)
        NSLayoutConstraint.activateConstraints(portraitOnlyConstraints)
        //perform any key hides/unhides in stackviews here
        
    }

    //MARK:- Setting/Changing key mappings
    func setQRowWithMapping(mapping:[IAKeyType]){
        for i in 0..<10 {
            if let singleKey = mapping[i] as? IASingleCharKey {
                let keyText = shiftKeyIsSelected ? singleKey.value.uppercaseString : singleKey.value
                (qwertyStackView.arrangedSubviews[i] as! PressureKey).setCharKey(keyText)
            }
        }
    }
    
    func setARowWithMapping(mapping:[IAKeyType]){
        let pressureKeys = asdfStackView.arrangedSubviews.filter({($0 is PressureKey)}) as! [PressureKey]
        if mapping.count == 9 {
            _ = asdfStackView.arrangedSubviews.filter({!($0 is PressureControl)}).map({$0.hidden = false}) //placeholders unhidden
            pressureKeys.last!.hidden = true //lastKey hidden
        } else {
            pressureKeys.last!.hidden = false //lastKey unhidden
            _ = asdfStackView.arrangedSubviews.filter({!($0 is PressureControl)}).map({$0.hidden = true}) //placeholders hidden
        }
        for i in 0..<min(mapping.count,pressureKeys.count){
            if let singleKey = mapping[i] as? IASingleCharKey {
                let keyText = shiftKeyIsSelected ? singleKey.value.uppercaseString : singleKey.value
                pressureKeys[i].setCharKey(keyText)
            }
        }
    }
    
    //start assuming 7 only
    func setZRowWithMapping(mapping:[IAKeyType]){
        let pressureKeys = zxcvStackView.arrangedSubviews.filter({($0 is PressureKey)}) as! [PressureKey]
        if mapping.count <= 7 {
            pressureKeys.last!.hidden = true //lastKey hidden
            _ = zxcvStackView.arrangedSubviews.filter({!($0 is PressureControl)}).map({$0.hidden = false}) //placeholders unhidden
        } else {
            pressureKeys.last!.hidden = false //lastKey unhidden
            _ = asdfStackView.arrangedSubviews.filter({!($0 is PressureControl)}).map({$0.hidden = true}) //placeholders hidden
        }
        for i in 0..<min(mapping.count,pressureKeys.count){
            if let singleKey = mapping[i] as? IASingleCharKey {
                let keyText = shiftKeyIsSelected ? singleKey.value.uppercaseString : singleKey.value
                pressureKeys[i].setCharKey(keyText)
            }
        }
        
    }
    
    func updateKeyMapping(){
        let currentPage = currentKeyset.keyPages[currentKeyPageNumber]
        self.setQRowWithMapping(currentPage.qRow)
        self.setARowWithMapping(currentPage.aRow)
        self.setZRowWithMapping(currentPage.zRow)
   
    }
    //MARK:- Setup helpers
    
    func generateHorizontalStackView()->UIStackView{
        let stackview = UIStackView()
        stackview.axis = UILayoutConstraintAxis.Horizontal
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.layoutMarginsRelativeArrangement = true
        stackview.alignment = .Fill
        stackview.distribution = .Fill
        stackview.spacing = kStandardKeySpacing
        return stackview
    }
    
    func setupPressureKey(tag:Int)->PressureKey{
        let nextKey = PressureKey()
        nextKey.tag = tag
        nextKey.delegate = self
        nextKey.backgroundColor = kKeyBackgroundColor
        nextKey.layer.cornerRadius = kKeyCornerRadius
        nextKey.clipsToBounds = true
        return nextKey
    }

    
    //MARK:- Key actions
    
    func backspaceKeyPressed(){
        textDocumentProxy.deleteBackward()
        //self.delegate?.iaKeyboardDeleteBackwards?(self)
    }
    ///cycles the pages of the current keyset
    func swapKeyset(){
        currentKeyPageNumber++
        updateKeyMapping()
    }
    
    ///All control elements adopting the KeyControl protocol deliver their user interaction events through this function
    func pressureKeyPressed(sender: PressureControl, actionName: String, intensity: Int) {
        //self.intensity = intensity
        preventRasterizationForDuration(5.0)
        UIDevice.currentDevice().playInputClick()
        var insertionText:String!
        if shiftKey.selected {
            shiftKey.deselect(overrideSelectedLock: false)
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
        updateSuggestionBar()
        autoCapsIfNeeded()
    }
    
    
    func prepareKeyboardForAppearance(){
        self.shiftKey.deselect(overrideSelectedLock: true)
        softSpace = false
        updateKeyMapping()
        autoCapsIfNeeded()
    }
    
    
    func autoCapsIfNeeded(){
        guard let editor = delegate as? IACompositeTextEditor where editor.selectedRange != nil else {return}
        guard editor.hasText() && editor.selectedRange!.startIndex > 0 else {
            self.shiftKey.selected = true; updateKeyMapping();return
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
            self.shiftKey.selected = true
            updateKeyMapping()
        } else {
            self.shiftKey.deselect(overrideSelectedLock: false)
            updateKeyMapping()
            return
        }
        
        
        
//        guard textDocumentProxy.hasText() else {self.shiftKey.selected = true; updateKeyMapping();return}
//        guard let text = textDocumentProxy.documentContextBeforeInput else {return}
//        guard NSCharacterSet.whitespaceAndNewlineCharacterSet().characterIsMember(text.utf16.last!) else {return}
//        for rChar in text.utf16.reverse() {
//            if NSCharacterSet.whitespaceAndNewlineCharacterSet().characterIsMember(rChar) {
//                continue
//            } else if puncCharset.characterIsMember(rChar) {
//                self.shiftKey.selected = true
//                updateKeyMapping()
//                return
//            } else {
//                return
//            }
//        }
    }
    
    func updateSuggestionBar(){
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
    
    
    func shiftKeyPressed(){
        updateKeyMapping()
    }
    
    func suggestionSelected(suggestionBar: SuggestionBarView!, suggestionString: String, intensity: Int) {
        softSpace = delegate?.iaKeyboard(self, suggestionSelected: suggestionString, intensity: intensity) ?? false
    }
    
    var suggestionBarActive:Bool {
        get{return !suggestionsBar.hidden}
        set{suggestionsBar.hidden = !newValue}
    }
    
}

///Misc saved stuff
//    var stackWidth:CGFloat {return screenWidth - (2 * kStackInset)}
//    var topRowKeyWidth:CGFloat { return(stackWidth - 9 * kStandardKeySpacing) / 10.0}





