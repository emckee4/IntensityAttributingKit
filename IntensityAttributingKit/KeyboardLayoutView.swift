//
//  KeyboardLayoutView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 5/17/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit
/**
KeyboardLayoutView handles the layout and display of the IAKeyboard subviews, while providing a delegate that packages all of the delegates of its subviews for convenience in setup. KeyboardLayoutView and IAKeyboardVC aren't very well separated but neither have been designed with the intent of being used independently of one another.
 
 */
class KeyboardLayoutView:UIInputView, PressureKeyActionDelegate, SuggestionBarDelegate{

    //MARK:- UI visual constants
    
    private let keyBackgroundColor = IAKitPreferences.visualPreferences.kbButtonColor
    private let keyTintColor = IAKitPreferences.visualPreferences.kbButtonTintColor
    private let kKeyHeight:CGFloat = 40.0
    private let kStandardKeySpacing:CGFloat = 4.0
    private let kStackInset:CGFloat = 2.0
    private let kKeyCornerRadius:CGFloat = 4.0
    private let suggestionBarScaleFactor:CGFloat = IAKitPreferences.visualPreferences.kbSuggestionBarScaleFactor//0.75
    
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
    var shiftKey:LockingKey!
    private var backspace:UIButton!
    private var swapKeysetButton:UIButton!
    private var returnKey:PressureView!
    private var spacebar:PressureKey!
    private var expandingPuncKey:ExpandingPressureKey!
    
    var suggestionsBar:SuggestionBarView!
    
    weak var delegate:KeyboardViewDelegate?
    
    var edgeInsets:UIEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)
    var verticalSpacing:CGFloat = 4
    
    
    private lazy var bundle:NSBundle = { return NSBundle(forClass: self.dynamicType) }()
    
    
    
    override init(frame: CGRect, inputViewStyle: UIInputViewStyle) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        setupView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("coder not implemented on KEyboardLayoutView")
    }
    
    func setupView(){
        
        suggestionsBar = SuggestionBarView(frame: CGRectZero)
        suggestionsBar.backgroundColor = IAKitPreferences.visualPreferences.kbSuggestionsBackgroundColor
        suggestionsBar.textColor = IAKitPreferences.visualPreferences.kbSuggestionsTextColor
        suggestionsBar.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(suggestionsBar)
        suggestionsBar.delegate = self
        setupQwertyRow()
        setupAsdfRow()
        setupZxcvRow()
        setupBottomRow()
        setupKeyConstraints()
        
    }
    
    
    ///MARK:- Keyboard initial layout functions
    private func setupQwertyRow(){
        qwertyStackView = generateHorizontalStackView()
        for i in 0..<10 {
            let key = setupPressureKey(i + 1000)
            qwertyStackView.addArrangedSubview(key)
            standardPressureKeys.append(key)
        }
        self.addSubview(qwertyStackView)
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
        self.addSubview(asdfStackView)
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
        shiftKey.backgroundColor = keyBackgroundColor
        shiftKey.setImage(UIImage(named: "caps2", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Selected)
        shiftKey.addTarget(self, action: #selector(KeyboardLayoutView.shiftKeyPressed(_:)), forControlEvents: .TouchUpInside)
        shiftKey.tintColor = keyTintColor
        
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
        backspace.setImage(UIImage(named: "backspace", inBundle: bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal )
        backspace.imageEdgeInsets = imageEdgeInsets
        backspace.imageView!.contentMode = .ScaleAspectFit
        backspace.backgroundColor = keyBackgroundColor
        backspace.layer.cornerRadius = kKeyCornerRadius
        zxcvStackView.addArrangedSubview(backspace)
        backspace.addTarget(self, action: #selector(KeyboardLayoutView.backspaceKeyPressed), forControlEvents: .TouchUpInside)
        backspace.tintColor = keyTintColor
        
        let placeholderWidth = leftPlaceholder.widthAnchor.constraintEqualToAnchor(rightPlaceholder.widthAnchor)  //local placeholders, any orientation
        placeholderWidth.priority = 999
        placeholderWidth.active = true
        self.addSubview(zxcvStackView)
    }
    
    
    private func setupBottomRow(){
        bottomStackView = generateHorizontalStackView()
        
        swapKeysetButton = UIButton(type: .System)
        swapKeysetButton.tag = 4900
        swapKeysetButton.setTitle("12/*", forState: .Normal)
        swapKeysetButton.titleLabel!.adjustsFontSizeToFitWidth = true
        swapKeysetButton.translatesAutoresizingMaskIntoConstraints = false
        swapKeysetButton.tintColor = keyTintColor
        swapKeysetButton.backgroundColor = keyBackgroundColor
        swapKeysetButton.layer.cornerRadius = kKeyCornerRadius
        swapKeysetButton.addTarget(self, action: #selector(KeyboardLayoutView.swapKeysetPageButtonPressed), forControlEvents: .TouchUpInside)
        bottomStackView.addArrangedSubview(swapKeysetButton)
        
        //spacebar
        
        spacebar = PressureKey()
        spacebar.tag = 4901
        spacebar.backgroundColor = keyBackgroundColor
        spacebar.setCharKey(" ")
        spacebar.delegate = self
        spacebar.layer.cornerRadius = kKeyCornerRadius
        spacebar.clipsToBounds = true
        bottomStackView.addArrangedSubview(spacebar)
        
        //expanding punctuation key
        
        expandingPuncKey = ExpandingPressureKey(frame:CGRectZero)
        expandingPuncKey.tag = 4900
        expandingPuncKey.delegate = self
        expandingPuncKey.backgroundColor = keyBackgroundColor
        expandingPuncKey.tintColor = keyTintColor
        expandingPuncKey.textColor = keyTintColor
        
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
        returnKeyView.textColor = keyTintColor
        returnKeyView.textAlignment = .Center
        returnKey.setAsSpecialKey(returnKeyView, actionName: "\n")
        returnKey.backgroundColor = keyBackgroundColor
        returnKey.layer.cornerRadius = kKeyCornerRadius
        bottomStackView.addArrangedSubview(returnKey)
        self.addSubview(bottomStackView)
    }

    
    private func setupKeyConstraints(){
        for key in standardPressureKeys[1..<standardPressureKeys.count]{
            let widthConstraint = key.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor)
            widthConstraint.priority = 999
            widthConstraint.active = true
        }
        
        backspace.widthAnchor.constraintEqualToAnchor(shiftKey.widthAnchor).active = true   //any orientation
        swapKeysetButton.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor).active = true //any orientation
        
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
    
    
    //MARK:- Setting/Changing key mappings
    private func setQRowWithMapping(mapping:[IAKeyType],shift:Bool){
        for i in 0..<10 {
            if let singleKey = mapping[i] as? IASingleCharKey {
                let keyText = shift ? singleKey.value.uppercaseString : singleKey.value
                (qwertyStackView.arrangedSubviews[i] as! PressureKey).setCharKey(keyText)
            }
        }
    }
    
    private func setARowWithMapping(mapping:[IAKeyType],shift:Bool){
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
                let keyText = shift ? singleKey.value.uppercaseString : singleKey.value
                pressureKeys[i].setCharKey(keyText)
            }
        }
    }
    
    //start assuming 7 only
    private func setZRowWithMapping(mapping:[IAKeyType],shift:Bool){
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
                let keyText = shift ? singleKey.value.uppercaseString : singleKey.value
                pressureKeys[i].setCharKey(keyText)
            }
        }
        
    }

    func setKeyset(keyset:IAKeyset, pageNumber:Int, shiftSelected:Bool){
        guard keyset.totalKeyPages > pageNumber else {print("KeyboardLayoutView: setKeyset received invalid page number for keyset"); return}
        self.setQRowWithMapping(keyset.keyPages[pageNumber].qRow,shift:shiftSelected)
        self.setARowWithMapping(keyset.keyPages[pageNumber].aRow,shift:shiftSelected)
        self.setZRowWithMapping(keyset.keyPages[pageNumber].zRow,shift:shiftSelected)
    }
    
    //MARK:- Setup helpers
    
    private func generateHorizontalStackView()->UIStackView{
        let stackview = UIStackView()
        stackview.axis = UILayoutConstraintAxis.Horizontal
        stackview.translatesAutoresizingMaskIntoConstraints = true
        stackview.layoutMarginsRelativeArrangement = true
        stackview.alignment = .Fill
        stackview.distribution = .Fill
        stackview.spacing = kStandardKeySpacing
        return stackview
    }
    
    private func setupPressureKey(tag:Int)->PressureKey{
        let nextKey = PressureKey()
        nextKey.tag = tag
        nextKey.delegate = self
        nextKey.backgroundColor = keyBackgroundColor
        nextKey.layer.cornerRadius = kKeyCornerRadius
        nextKey.textColor = keyTintColor
        nextKey.clipsToBounds = true
        return nextKey
    }


    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if suggestionsBar.hidden == false {
            let heightMinusInsetsAndSpacing = self.bounds.height - edgeInsets.top - edgeInsets.bottom - (4 * verticalSpacing)
            //(height - insets - 4*spacing) / 4.75
            let svHeight = floor(heightMinusInsetsAndSpacing / (4.0 + suggestionBarScaleFactor))
            let suggBarHeight = floor(heightMinusInsetsAndSpacing - (4.0 * svHeight))
            let commonWidth = bounds.width - edgeInsets.left - edgeInsets.right
            
            suggestionsBar.frame = CGRectMake(edgeInsets.left, edgeInsets.top, commonWidth, suggBarHeight)
            
            
            qwertyStackView.frame = CGRectMake(edgeInsets.left, (edgeInsets.top + suggBarHeight + verticalSpacing),commonWidth, svHeight)
            asdfStackView.frame = CGRectMake(edgeInsets.left, (edgeInsets.top + suggBarHeight + 2 * verticalSpacing + svHeight), commonWidth, svHeight)
            zxcvStackView.frame = CGRectMake(edgeInsets.left, (edgeInsets.top + suggBarHeight + 3 * verticalSpacing + 2 * svHeight), commonWidth, svHeight)
            bottomStackView.frame = CGRectMake(edgeInsets.left, (edgeInsets.top + suggBarHeight + 4 * verticalSpacing + 3 * svHeight), commonWidth, svHeight)
        } else {
            let heightMinusInsetsAndSpacing = self.bounds.height - edgeInsets.top - edgeInsets.bottom - (3 * verticalSpacing)
            //(height - insets - 4*spacing) / 4.75
            let svHeight = floor(heightMinusInsetsAndSpacing / 4.0 )
            let commonWidth = bounds.width - edgeInsets.left - edgeInsets.right
            
            qwertyStackView.frame = CGRectMake(edgeInsets.left, (edgeInsets.top),commonWidth, svHeight)
            asdfStackView.frame = CGRectMake(edgeInsets.left, (edgeInsets.top  + 1 * verticalSpacing + svHeight), commonWidth, svHeight)
            zxcvStackView.frame = CGRectMake(edgeInsets.left, (edgeInsets.top + 2 * verticalSpacing + 2 * svHeight), commonWidth, svHeight)
            bottomStackView.frame = CGRectMake(edgeInsets.left, (edgeInsets.top + 3 * verticalSpacing + 3 * svHeight), commonWidth, svHeight)
            
        }
    }
    
    func setConstraintsForOrientation(orientation:UIInterfaceOrientation){
        if orientation == .LandscapeLeft || orientation == .LandscapeRight {
            NSLayoutConstraint.deactivateConstraints(portraitOnlyConstraints)
            NSLayoutConstraint.activateConstraints(landscapeOnlyConstraints)
        } else {
            NSLayoutConstraint.deactivateConstraints(landscapeOnlyConstraints)
            NSLayoutConstraint.activateConstraints(portraitOnlyConstraints)
        }
    }
    
    
    //MARK:-Delegate message forwarding
    
    ///Forwards all presses to the keyDelegate. This lets us set up all the numerous key delegates before we set the view's pk delegate.
    func pressureKeyPressed(sender: PressureControl, actionName: String, intensity: Int) {
        delegate?.pressureKeyPressed(sender, actionName: actionName, intensity: intensity)
    }
    
    func backspaceKeyPressed(){
        delegate?.backspaceKeyPressed()
    }
    
    func shiftKeyPressed(sender:LockingKey){
        delegate?.shiftKeyPressed(sender)
    }
    
    func swapKeysetPageButtonPressed(){
        delegate?.swapKeysetPageButtonPressed()
    }
    
    func suggestionSelected(suggestionBar: SuggestionBarView!, suggestionString: String, intensity: Int) {
        delegate?.suggestionSelected(suggestionBar, suggestionString: suggestionString, intensity: intensity)
    }
 
    
}

///Packages all of the delegates along with action targets used in the KeyboardLayoutView to the IAKeyboard
protocol KeyboardViewDelegate:PressureKeyActionDelegate, SuggestionBarDelegate{
    func shiftKeyPressed(shiftKey:LockingKey!)
    func backspaceKeyPressed()
    func swapKeysetPageButtonPressed()
    
}


