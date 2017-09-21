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
    
    fileprivate let keyBackgroundColor = IAKitPreferences.visualPreferences.kbButtonColor
    fileprivate let keyTintColor = IAKitPreferences.visualPreferences.kbButtonTintColor
    fileprivate let kKeyHeight:CGFloat = 40.0
    fileprivate let kStandardKeySpacing:CGFloat = 4.0
    fileprivate let kStackInset:CGFloat = 2.0
    fileprivate let kKeyCornerRadius:CGFloat = 4.0
    fileprivate let suggestionBarScaleFactor:CGFloat = IAKitPreferences.visualPreferences.kbSuggestionBarScaleFactor//0.75
    
    fileprivate var verticalStackView:UIStackView!
    fileprivate var qwertyStackView:EmbeddableStackView!
    fileprivate var asdfStackView:EmbeddableStackView!
    fileprivate var zxcvStackView:EmbeddableStackView!
    fileprivate var bottomStackView:EmbeddableStackView!
    
    //MARK:- Retained Constraints
    fileprivate var portraitOnlyConstraints:[NSLayoutConstraint] = []
    fileprivate var landscapeOnlyConstraints:[NSLayoutConstraint] = []
    
    //MARK:- Controls
    fileprivate var standardPressureKeys:[PressureKey] = []
    var shiftKey:LockingKey!
    fileprivate var backspace:UIButton!
    fileprivate var swapKeysetButton:UIButton!
    fileprivate var returnKey:PressureView!
    fileprivate var spacebar:PressureKey!
    fileprivate var expandingPuncKey:ExpandingPressureKey!
    
    var suggestionsBar:SuggestionBarView!
    
    weak var delegate:KeyboardViewDelegate?
    
    var edgeInsets:UIEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)
    var verticalSpacing:CGFloat = 4
    
    
    fileprivate lazy var bundle:Bundle = { return Bundle(for: type(of: self)) }()
    
    
    
    override init(frame: CGRect, inputViewStyle: UIInputViewStyle) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        setupView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("coder not implemented on KEyboardLayoutView")
    }
    
    func setupView(){
        
        suggestionsBar = SuggestionBarView(frame: CGRect.zero)
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
    fileprivate func setupQwertyRow(){
        qwertyStackView = generateHorizontalStackView()
        for i in 0..<10 {
            let key = setupPressureKey(i + 1000)
            qwertyStackView.addArrangedSubview(key)
            standardPressureKeys.append(key)
        }
        self.addSubview(qwertyStackView)
    }
    
    fileprivate func setupAsdfRow(){
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
        let placeholderWidth = leftPlaceholder.widthAnchor.constraint(equalTo: rightPlaceholder.widthAnchor) //local placeholders, any orientation
        placeholderWidth.priority = 999
        placeholderWidth.isActive = true
        self.addSubview(asdfStackView)
    }
    
    
    fileprivate func setupZxcvRow(){
        zxcvStackView = generateHorizontalStackView()
        
        shiftKey = LockingKey()
        shiftKey.tag = 3900
        
        let imageEdgeInsets = UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0)
        shiftKey.translatesAutoresizingMaskIntoConstraints = false
        shiftKey.setImage(UIImage(named: "caps1", in: bundle, compatibleWith: nil), for: UIControlState() )
        shiftKey.imageEdgeInsets = imageEdgeInsets
        shiftKey.imageView!.contentMode = .scaleAspectFit
        shiftKey.layer.cornerRadius = kKeyCornerRadius
        shiftKey.backgroundColor = keyBackgroundColor
        shiftKey.setImage(UIImage(named: "caps2", in: bundle, compatibleWith: nil), for: .selected)
        shiftKey.addTarget(self, action: #selector(KeyboardLayoutView.shiftKeyPressed(_:)), for: .touchUpInside)
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
        backspace.setImage(UIImage(named: "backspace", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: UIControlState() )
        backspace.imageEdgeInsets = imageEdgeInsets
        backspace.imageView!.contentMode = .scaleAspectFit
        backspace.backgroundColor = keyBackgroundColor
        backspace.layer.cornerRadius = kKeyCornerRadius
        zxcvStackView.addArrangedSubview(backspace)
        backspace.addTarget(self, action: #selector(KeyboardLayoutView.backspaceKeyPressed), for: .touchUpInside)
        backspace.tintColor = keyTintColor
        
        let placeholderWidth = leftPlaceholder.widthAnchor.constraint(equalTo: rightPlaceholder.widthAnchor)  //local placeholders, any orientation
        placeholderWidth.priority = 999
        placeholderWidth.isActive = true
        self.addSubview(zxcvStackView)
    }
    
    
    fileprivate func setupBottomRow(){
        bottomStackView = generateHorizontalStackView()
        
        swapKeysetButton = UIButton(type: .system)
        swapKeysetButton.tag = 4900
        swapKeysetButton.setTitle("12/*", for: UIControlState())
        swapKeysetButton.titleLabel!.adjustsFontSizeToFitWidth = true
        swapKeysetButton.translatesAutoresizingMaskIntoConstraints = false
        swapKeysetButton.tintColor = keyTintColor
        swapKeysetButton.backgroundColor = keyBackgroundColor
        swapKeysetButton.layer.cornerRadius = kKeyCornerRadius
        swapKeysetButton.addTarget(self, action: #selector(KeyboardLayoutView.swapKeysetPageButtonPressed), for: .touchUpInside)
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
        
        expandingPuncKey = ExpandingPressureKey(frame:CGRect.zero)
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
        returnKeyView.textAlignment = .center
        returnKey.setAsSpecialKey(returnKeyView, actionName: "\n")
        returnKey.backgroundColor = keyBackgroundColor
        returnKey.layer.cornerRadius = kKeyCornerRadius
        bottomStackView.addArrangedSubview(returnKey)
        self.addSubview(bottomStackView)
    }

    
    fileprivate func setupKeyConstraints(){
        for key in standardPressureKeys[1..<standardPressureKeys.count]{
            let widthConstraint = key.widthAnchor.constraint(equalTo: standardPressureKeys[0].widthAnchor)
            widthConstraint.priority = 999
            widthConstraint.isActive = true
        }
        
        backspace.widthAnchor.constraint(equalTo: shiftKey.widthAnchor).isActive = true   //any orientation
        swapKeysetButton.widthAnchor.constraint(equalTo: standardPressureKeys[0].widthAnchor).isActive = true //any orientation
        
        ///setup portrait constraints
        portraitOnlyConstraints.append( expandingPuncKey.widthAnchor.constraint(equalTo: standardPressureKeys[0].widthAnchor, multiplier: 1.5) )
        portraitOnlyConstraints.append( shiftKey.widthAnchor.constraint(greaterThanOrEqualTo: standardPressureKeys[0].widthAnchor, multiplier: 1.3) )
        portraitOnlyConstraints.append( shiftKey.widthAnchor.constraint(lessThanOrEqualTo: standardPressureKeys[0].widthAnchor, multiplier: 1.5) )
        portraitOnlyConstraints.append( returnKey.widthAnchor.constraint(equalTo: standardPressureKeys[0].widthAnchor, multiplier: 2.0) )
        
        ///setup landscape constraints
        landscapeOnlyConstraints.append( expandingPuncKey.widthAnchor.constraint(equalTo: standardPressureKeys[0].widthAnchor, multiplier: 1.0) )
        landscapeOnlyConstraints.append( shiftKey.widthAnchor.constraint(equalTo: standardPressureKeys[0].widthAnchor) )
        landscapeOnlyConstraints.append( returnKey.widthAnchor.constraint(equalTo: standardPressureKeys[0].widthAnchor, multiplier: 1.0) )
        
    }
    
    
    //MARK:- Setting/Changing key mappings
    fileprivate func setQRowWithMapping(_ mapping:[IAKeyType],shift:Bool){
        for i in 0..<10 {
            if let singleKey = mapping[i] as? IASingleCharKey {
                let keyText = shift ? singleKey.value.uppercased() : singleKey.value
                (qwertyStackView.arrangedSubviews[i] as! PressureKey).setCharKey(keyText)
            }
        }
    }
    
    fileprivate func setARowWithMapping(_ mapping:[IAKeyType],shift:Bool){
        let pressureKeys = asdfStackView.arrangedSubviews.filter({($0 is PressureKey)}) as! [PressureKey]
        if mapping.count == 9 {
            _ = asdfStackView.arrangedSubviews.filter({!($0 is PressureControl)}).map({$0.isHidden = false}) //placeholders unhidden
            pressureKeys.last!.isHidden = true //lastKey hidden
        } else {
            pressureKeys.last!.isHidden = false //lastKey unhidden
            _ = asdfStackView.arrangedSubviews.filter({!($0 is PressureControl)}).map({$0.isHidden = true}) //placeholders hidden
        }
        for i in 0..<min(mapping.count,pressureKeys.count){
            if let singleKey = mapping[i] as? IASingleCharKey {
                let keyText = shift ? singleKey.value.uppercased() : singleKey.value
                pressureKeys[i].setCharKey(keyText)
            }
        }
    }
    
    //start assuming 7 only
    fileprivate func setZRowWithMapping(_ mapping:[IAKeyType],shift:Bool){
        let pressureKeys = zxcvStackView.arrangedSubviews.filter({($0 is PressureKey)}) as! [PressureKey]
        if mapping.count <= 7 {
            pressureKeys.last!.isHidden = true //lastKey hidden
            _ = zxcvStackView.arrangedSubviews.filter({!($0 is PressureControl)}).map({$0.isHidden = false}) //placeholders unhidden
        } else {
            pressureKeys.last!.isHidden = false //lastKey unhidden
            _ = asdfStackView.arrangedSubviews.filter({!($0 is PressureControl)}).map({$0.isHidden = true}) //placeholders hidden
        }
        for i in 0..<min(mapping.count,pressureKeys.count){
            if let singleKey = mapping[i] as? IASingleCharKey {
                let keyText = shift ? singleKey.value.uppercased() : singleKey.value
                pressureKeys[i].setCharKey(keyText)
            }
        }
        
    }

    func setKeyset(_ keyset:IAKeyset, pageNumber:Int, shiftSelected:Bool){
        guard keyset.totalKeyPages > pageNumber else {print("KeyboardLayoutView: setKeyset received invalid page number for keyset"); return}
        self.setQRowWithMapping(keyset.keyPages[pageNumber].qRow,shift:shiftSelected)
        self.setARowWithMapping(keyset.keyPages[pageNumber].aRow,shift:shiftSelected)
        self.setZRowWithMapping(keyset.keyPages[pageNumber].zRow,shift:shiftSelected)
    }
    
    //MARK:- Setup helpers
    
    fileprivate func generateHorizontalStackView()->EmbeddableStackView{
        let stackview = EmbeddableStackView()
        stackview.axis = UILayoutConstraintAxis.horizontal
        stackview.translatesAutoresizingMaskIntoConstraints = true
        stackview.isLayoutMarginsRelativeArrangement = true
        stackview.alignment = .fill
        stackview.distribution = .fill
        stackview.spacing = kStandardKeySpacing
        return stackview
    }
    
    fileprivate func setupPressureKey(_ tag:Int)->PressureKey{
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
        if suggestionsBar.isHidden == false {
            let heightMinusInsetsAndSpacing = self.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom - (4 * verticalSpacing)
            //(height - insets - 4*spacing) / 4.75
            let svHeight = floor(heightMinusInsetsAndSpacing / (4.0 + suggestionBarScaleFactor))
            let suggBarHeight = floor(heightMinusInsetsAndSpacing - (4.0 * svHeight))
            let commonWidth = bounds.width - safeAreaInsets.left - safeAreaInsets.right
            
            suggestionsBar.frame = CGRect(x: safeAreaInsets.left, y: safeAreaInsets.top, width: commonWidth, height: suggBarHeight)
            
            
            qwertyStackView.frame = CGRect(x: safeAreaInsets.left, y: (safeAreaInsets.top + suggBarHeight + verticalSpacing),width: commonWidth, height: svHeight)
            asdfStackView.frame = CGRect(x: safeAreaInsets.left, y: (safeAreaInsets.top + suggBarHeight + 2 * verticalSpacing + svHeight), width: commonWidth, height: svHeight)
            zxcvStackView.frame = CGRect(x: safeAreaInsets.left, y: (safeAreaInsets.top + suggBarHeight + 3 * verticalSpacing + 2 * svHeight), width: commonWidth, height: svHeight)
            bottomStackView.frame = CGRect(x: safeAreaInsets.left, y: (safeAreaInsets.top + suggBarHeight + 4 * verticalSpacing + 3 * svHeight), width: commonWidth, height: svHeight)
        } else {
            let heightMinusInsetsAndSpacing = self.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom - (3 * verticalSpacing)
            //(height - insets - 4*spacing) / 4.75
            let svHeight = floor(heightMinusInsetsAndSpacing / 4.0 )
            let commonWidth = bounds.width - safeAreaInsets.left - safeAreaInsets.right
            
            qwertyStackView.frame = CGRect(x: safeAreaInsets.left, y: (safeAreaInsets.top),width: commonWidth, height: svHeight)
            asdfStackView.frame = CGRect(x: safeAreaInsets.left, y: (safeAreaInsets.top  + 1 * verticalSpacing + svHeight), width: commonWidth, height: svHeight)
            zxcvStackView.frame = CGRect(x: safeAreaInsets.left, y: (safeAreaInsets.top + 2 * verticalSpacing + 2 * svHeight), width: commonWidth, height: svHeight)
            bottomStackView.frame = CGRect(x: safeAreaInsets.left, y: (safeAreaInsets.top + 3 * verticalSpacing + 3 * svHeight), width: commonWidth, height: svHeight)
            
        }
    }
    
    func setConstraintsForOrientation(_ orientation:UIInterfaceOrientation){
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            NSLayoutConstraint.deactivate(portraitOnlyConstraints)
            NSLayoutConstraint.activate(landscapeOnlyConstraints)
        } else {
            NSLayoutConstraint.deactivate(landscapeOnlyConstraints)
            NSLayoutConstraint.activate(portraitOnlyConstraints)
        }
    }
    
    
    //MARK:-Delegate message forwarding
    
    ///Forwards all presses to the keyDelegate. This lets us set up all the numerous key delegates before we set the view's pk delegate.
    func pressureKeyPressed(_ sender: PressureControl, actionName: String, intensity: Int) {
        delegate?.pressureKeyPressed(sender, actionName: actionName, intensity: intensity)
    }
    
    func backspaceKeyPressed(){
        delegate?.backspaceKeyPressed()
    }
    
    func shiftKeyPressed(_ sender:LockingKey){
        delegate?.shiftKeyPressed(sender)
    }
    
    func swapKeysetPageButtonPressed(){
        delegate?.swapKeysetPageButtonPressed()
    }
    
    func suggestionSelected(_ suggestionBar: SuggestionBarView!, suggestionString: String, intensity: Int) {
        delegate?.suggestionSelected(suggestionBar, suggestionString: suggestionString, intensity: intensity)
    }
 
    
}

///Packages all of the delegates along with action targets used in the KeyboardLayoutView to the IAKeyboard
protocol KeyboardViewDelegate:PressureKeyActionDelegate, SuggestionBarDelegate{
    func shiftKeyPressed(_ shiftKey:LockingKey!)
    func backspaceKeyPressed()
    func swapKeysetPageButtonPressed()
    
}


