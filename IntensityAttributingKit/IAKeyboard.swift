//
//  IAKeyboard.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/25/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//
import UIKit

class IAKeyboard: UIInputViewController, PressureKeyActionDelegate {
    
    
    ///Intensity of last keypress. IATextView will retrieve this value and set it to nil after the textDocumentProxy informs it of text insertion by the keyboard
    //var intensity:Float!
    
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
        setupQwertyRow()
        setupAsdfRow()
        setupZxcvRow()
        setupBottomRow()
        setupVerticalStackView()
        setupKeyConstraints()
       
        updateKeyMapping()
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
        
        
        verticalStackView = UIStackView(arrangedSubviews: [ qwertyStackView,asdfStackView,zxcvStackView,bottomStackView])
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
        if shiftKey.selected {
            shiftKey.deselect(overrideSelectedLock: false)
            updateKeyMapping()
            //self.textDocumentProxy.insertText(actionName.uppercaseString)
            self.delegate?.iaKeyboard?(self, insertTextAtCursor: actionName.uppercaseString, intensity: intensity)
        } else {
            //self.textDocumentProxy.insertText(actionName)
            self.delegate?.iaKeyboard?(self, insertTextAtCursor: actionName, intensity: intensity)
        }
    }

    
    override func selectionDidChange(textInput: UITextInput?) {
        //print("selectionDidChange: \(textInput): context: <\(textDocumentProxy.documentContextBeforeInput)><\(textDocumentProxy.documentContextAfterInput)>")
        super.selectionDidChange(textInput)
        self.autoCapsIfNeeded()
    }
    
    func prepareKeyboardForAppearance(){
        self.shiftKey.deselect(overrideSelectedLock: true)
        updateKeyMapping()
        autoCapsIfNeeded()
    }
    
    
    func autoCapsIfNeeded(){
        guard textDocumentProxy.hasText() else {self.shiftKey.selected = true; updateKeyMapping();return}
        guard let text = textDocumentProxy.documentContextBeforeInput else {return}
        let puncCharset = NSCharacterSet(charactersInString: ".?!")
        guard NSCharacterSet.whitespaceAndNewlineCharacterSet().characterIsMember(text.utf16.last!) else {return}
        for rChar in text.utf16.reverse() {
            if NSCharacterSet.whitespaceAndNewlineCharacterSet().characterIsMember(rChar) {
                continue
            } else if puncCharset.characterIsMember(rChar) {
                self.shiftKey.selected = true
                updateKeyMapping()
                return
            } else {
                return
            }
        }
    }
    
    func shiftKeyPressed(){
        updateKeyMapping()
    }
    
//    private func shouldCaps(text:String)->Bool{
//        let puncCharset = NSCharacterSet(charactersInString: ".?!")
//        guard !text.isEmpty else {return true}
//        guard NSCharacterSet.whitespaceAndNewlineCharacterSet().characterIsMember(text.utf16.last!) else {return false}
//        for rChar in text.utf16.reverse() {
//            if NSCharacterSet.whitespaceAndNewlineCharacterSet().characterIsMember(rChar) {
//                continue
//            } else if puncCharset.characterIsMember(rChar) {
//                return true
//            } else {
//                return false
//            }
//        }
//        return true
//    }
    
}

///Misc saved stuff
//    var stackWidth:CGFloat {return screenWidth - (2 * kStackInset)}
//    var topRowKeyWidth:CGFloat { return(stackWidth - 9 * kStandardKeySpacing) / 10.0}



@objc protocol IAKeyboardDelegate {
    optional func iaKeyboard(iaKeyboard:IAKeyboard, insertTextAtCursor text:String, intensity:Int)
    //optional func iaKeyboardDeleteBackwards(iaKeyboard:IAKeyboard)
    
    ///This should be further implemented to allow autocapitalization, periods, etc
    //optional func iaKeyboardContextAroundCursor()
    
}


