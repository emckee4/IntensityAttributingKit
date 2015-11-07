//
//  IAKeyboard.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/25/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//
import UIKit

@IBDesignable
class IAKeyboard: UIInputViewController, PressureKeyAction {
    
    
    
    
    
    /// 4 rows without autocorrect, 5 with.
    // qwertyuiop  10
    // asdfghjkl    9
    // ^zxcvbnm<    9 (1 square, 7 chars, 1 square)
    // 1KDSR        5 (2 squares, 1 char, 4char bar, doubleSquare)
    //above as numericKB, changeKB, dictation, space, return
    //
    //need array of pressure buttons
    //need nextKeyboard button
    var intensity:Float!
    
    
    
    //    var screenWidth:CGFloat {return UIScreen.mainScreen().bounds.width}
    //    var stackWidth:CGFloat {return screenWidth - (2 * kStackInset)}
    //
    //    var topRowKeyWidth:CGFloat { return(stackWidth - 9 * kStandardKeySpacing) / 10.0}
    //
    private let kKeyBackgroundColor = UIColor.lightGrayColor()
    private let kKeyHeight:CGFloat = 40.0
    private let kStandardKeySpacing:CGFloat = 4.0
    private let kStackInset:CGFloat = 2.0
    private let kKeyCornerRadius:CGFloat = 4.0
    
    private let primaryMapping:[[Int:String]] = [
        [0:"q",1:"w",2:"e",3:"r",4:"t",5:"y",6:"u",7:"i",8:"o",9:"p"],
        [0:"a",1:"s",2:"d",3:"f",4:"g",5:"h",6:"j",7:"k",8:"l"],
        [0:"z",1:"x",2:"c",3:"v",4:"b",5:"n",6:"m"]
    ]
    private let basicEnglishMapping:[[String]] = [
        ["q","w","e","r","t","y","u","i","o","p"],
        ["a","s","d","f","g","h","j","k","l"],
        ["z","x","c","v","b","n","m"]
    ]
    private let numpad:[[String]] = [
        ["1","2","3","4","5","6","7","8","9","0"],
        ["-","/",":",";","(",")","$","&","@","\""],
        [".","+","=","*","*","\\","'"]
    ]
    
    private let baseFont = UIFont.systemFontOfSize(20.0)
    
    private var verticalStackView:UIStackView!
    private var qwertyStackView:UIStackView!
    private var asdfStackView:UIStackView!
    private var zxcvStackView:UIStackView!
    private var bottomStackView:UIStackView!
    
    private var portraitOnlyConstraints:[NSLayoutConstraint] = []
    private var landscapeOnlyConstraints:[NSLayoutConstraint] = []
    
    private var standardPressureKeys:[PressureView] = []
    private var shiftKey:LockingKey!
    private var backspace:UIButton!
    private var swapKeysetButton:UIButton!
    private var returnKey:PressureView!
    private var spacebar:PressureView!
    private var expandingPuncKey:ExpandingPressureKey!
    
    
    private lazy var bundle:NSBundle = { return NSBundle(forClass: self.dynamicType) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        setupQwertyRow()
        setupAsdfRow()
        setupZxcvRow()
        setupBottomRow()
        setupVerticalStackView()
        setupKeyConstraints()
       
        setKeyMapping(basicEnglishMapping)
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
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if size.width > size.height {
            prepareForLandscape()
        } else {
            prepareForPortrait()
        }
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
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
        let rightPlaceholder = UIView()//generatePlaceholder(width: (kStandardKeyWidth / 2.0) - kStandardKeySpacing, height: 20.0)
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
        //shiftKey.setTitle("SH", forState: .Selected)
        
        zxcvStackView.addArrangedSubview(shiftKey)
        
        let leftPlaceholder = UIView()
        leftPlaceholder.tag = 3100
        let rightPlaceholder = UIView()
        rightPlaceholder.tag = 3101
        zxcvStackView.addArrangedSubview( leftPlaceholder)//generatePlaceholder(width: (kStandardKeyWidth / 2.0) - kStandardKeySpacing * 6,height: 10.0) )
        
        for i in 0..<8 {
            let key = setupPressureKey(i + 3001)
            zxcvStackView.addArrangedSubview(key)
            standardPressureKeys.append(key)
        }
        
        zxcvStackView.addArrangedSubview(rightPlaceholder)//generatePlaceholder(width: (kStandardKeyWidth / 2.0) - kStandardKeySpacing * 6,height: 10.0))
        
        
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
        swapKeysetButton.translatesAutoresizingMaskIntoConstraints = false
        swapKeysetButton.backgroundColor = kKeyBackgroundColor
        swapKeysetButton.layer.cornerRadius = kKeyCornerRadius
        swapKeysetButton.addTarget(self, action: "swapKeyset", forControlEvents: .TouchUpInside)
        bottomStackView.addArrangedSubview(swapKeysetButton)
        
        //spacebar
        
        spacebar = PressureView()
        spacebar.tag = 4901
        spacebar.backgroundColor = kKeyBackgroundColor
        spacebar.setAsCharKey(" ")
        spacebar.delegate = self
        spacebar.layer.cornerRadius = kKeyCornerRadius
        bottomStackView.addArrangedSubview(spacebar)
        
        //expanding punctuation key

        expandingPuncKey = ExpandingPressureKey(frame:CGRectZero)
        expandingPuncKey.tag = 4900
        expandingPuncKey.delegate = self
        expandingPuncKey.backgroundColor = kKeyBackgroundColor

        expandingPuncKey.addCharKey(charToInsert: ".")
        expandingPuncKey.addCharKey(charToInsert: ",")
        expandingPuncKey.addCharKey(charToInsert: "?")
        expandingPuncKey.addCharKey(charToInsert: "!")
        
        expandingPuncKey.cornerRadius = kKeyCornerRadius
        bottomStackView.addArrangedSubview(expandingPuncKey)
        
        
        
        
        returnKey = PressureView()
        returnKey.tag = 4002
        returnKey.delegate = self
        let returnKeyView = UILabel()
        returnKeyView.text = "Return"
        returnKeyView.textAlignment = .Center
        returnKey.setAsSpecialKey(returnKeyView, actionName: "\n", actionType: .CharInsert)
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
        
        view.backgroundColor = UIColor.redColor()
        
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
    //always 10, simple case
    func setQRowWithMapping(mapping:[String]){
        for (i,keyName) in mapping.enumerate() {
            (qwertyStackView.arrangedSubviews[i] as! PressureView).setAsCharKey(keyName)
        }
    }
    
    func setARowWithMapping(mapping:[String]){
        let pressureKeys = asdfStackView.arrangedSubviews.filter({($0 is PressureView)}) as! [PressureView]
        if mapping.count == 9 {
            _ = asdfStackView.arrangedSubviews.filter({!($0 is PressureControl)}).map({$0.hidden = false}) //placeholders unhidden
            //aRowPlaceholderConstraint.active = true
            
            pressureKeys.last!.hidden = true //lastKey hidden

        } else {
            pressureKeys.last!.hidden = false //lastKey unhidden
            //aRowPlaceholderConstraint.active = false
            _ = asdfStackView.arrangedSubviews.filter({!($0 is PressureControl)}).map({$0.hidden = true}) //placeholders hidden
        }
        for i in 0..<min(mapping.count,pressureKeys.count){
            pressureKeys[i].setAsCharKey(mapping[i])
        }
    }
    
    //start assuming 7 only
    func setZRowWithMapping(mapping:[String]){
        let pressureKeys = zxcvStackView.arrangedSubviews.filter({($0 is PressureView)}) as! [PressureView]
        if mapping.count == 7 {
            pressureKeys.last!.hidden = true //lastKey hidden
            _ = zxcvStackView.arrangedSubviews.filter({!($0 is PressureControl)}).map({$0.hidden = false}) //placeholders unhidden
            //zRowPlaceholderConstraint.active = true
        }
//        } else {
//            pressureKeys.last!.hidden = false //lastKey unhidden
//            _ = asdfStackView.arrangedSubviews.filter({!($0 is PressureControl)}).map({$0.hidden = true}) //placeholders hidden
//        }
        for i in 0..<min(mapping.count,pressureKeys.count){
            pressureKeys[i].setAsCharKey(mapping[i])
        }
        
    }
    
    func setKeyMapping(mapping:[[String]]){
        //UIView.animateWithDuration(0.3) { () -> Void in
            self.setQRowWithMapping(mapping[0])
            self.setARowWithMapping(mapping[1])
            self.setZRowWithMapping(mapping[2])
        //}
        
        
    }
    
    
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
    
//    func setupPressureKey(tag:Int, title:String)->PressureButton{
//        let nextKey = PressureButton(type: UIButtonType.System)
//        nextKey.tag = tag
//        //nextKey.setTitle("\(title)", forState: .Normal)
//        nextKey.setAttributedTitle(NSAttributedString(string: title,attributes: [NSFontAttributeName:baseFont]), forState: .Normal)
//        nextKey.backgroundColor = UIColor.lightGrayColor()
//        
//        nextKey.setContentHuggingPriority(100, forAxis: .Horizontal)
//        nextKey.translatesAutoresizingMaskIntoConstraints = false
//        nextKey.addTarget(self, action: "charKeyPressed:", forControlEvents: .TouchUpInside)
//        nextKey.layer.cornerRadius = kKeyCornerRadius
//        return nextKey
//    }
    
    
    func setupPressureKey(tag:Int)->PressureView{
        let nextKey = PressureView()
        nextKey.tag = tag
        nextKey.delegate = self
        nextKey.backgroundColor = kKeyBackgroundColor
        nextKey.layer.cornerRadius = kKeyCornerRadius
        return nextKey
    }

    
    
    func expandingCharKeyPressed(text:String,intensity:RawIntensity){
        self.intensity = intensity.intensity
        if shiftKey.selected {
            shiftKey.deselect(overrideSelectedLock: false)
            self.textDocumentProxy.insertText(text.uppercaseString)
        } else {
            self.textDocumentProxy.insertText(text)
        }
        
    }
    
    
    
    func charKeyPressed(sender:PressureButton!){
        if let text = sender.titleLabel?.text {
            self.intensity = sender.lastIntensity
            if shiftKey.selected {
                shiftKey.deselect(overrideSelectedLock: false)
                self.textDocumentProxy.insertText(text.uppercaseString)
            } else {
                self.textDocumentProxy.insertText(text)
            }
        }
    }
//    func returnKeyPressed(sender:PressureButton!){
//        self.intensity = sender.lastIntensity
//        self.textDocumentProxy.insertText("\n")
//        shiftKey.deselect(overrideSelectedLock: false)
//    }
    
    func backspaceKeyPressed(){
        textDocumentProxy.deleteBackward()
    }
    
    var current = 0
    
    func swapKeyset(){
        if current == 0 {
            current++
            setKeyMapping(numpad)
        } else {
            current = 0
            setKeyMapping(basicEnglishMapping)
        }
    }
    
    func pressureKeyPressed(sender: PressureControl, actionName: String, actionType: PressureKeyActionType, intensity: Float) {
        if actionType == .CharInsert {
            self.intensity = intensity
            if shiftKey.selected {
                shiftKey.deselect(overrideSelectedLock: false)
                self.textDocumentProxy.insertText(actionName.uppercaseString)
            } else {
                self.textDocumentProxy.insertText(actionName)
            }
        } else if actionType == .TriggerFunction {
            //handle function calling...
        }
    }

    
}







