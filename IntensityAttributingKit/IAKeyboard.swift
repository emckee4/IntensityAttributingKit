//
//  IAKeyboard.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/25/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//
import UIKit

@IBDesignable
class IAKeyboard: UIInputViewController {
    
    
    
    
    
    /// 4 rows without autocorrect, 5 with.
    // qwertyuiop  10
    // asdfghjkl    9
    // ^zxcvbnm<    9 (1 square, 7 chars, 1 square)
    // 1KDSR        5 (2 squares, 1 char, 4char bar, doubleSquare)
    //above as numericKB, changeKB, dictation, space, return
    //
    //need array of pressure buttons
    //need nextKeyboard button
    var lastKeyAvgIntensity:Float?
    var lastKeyPeakIntensity:Float?
    
    private let kKeyBackgroundColor = UIColor.lightGrayColor()
    
    //    var screenWidth:CGFloat {return UIScreen.mainScreen().bounds.width}
    //    var stackWidth:CGFloat {return screenWidth - (2 * kStackInset)}
    //
    //    var topRowKeyWidth:CGFloat { return(stackWidth - 9 * kStandardKeySpacing) / 10.0}
    //
    
    private let kKeyHeight:CGFloat = 40.0
    private let kStandardKeySpacing:CGFloat = 4.0
    private let kStackInset:CGFloat = 2.0
    private let kKeyCornerRadius:CGFloat = 4.0
    
    private let primaryMapping:[[Int:String]] = [
        [0:"q",1:"w",2:"e",3:"r",4:"t",5:"y",6:"u",7:"i",8:"o",9:"p"],
        [0:"a",1:"s",2:"d",3:"f",4:"g",5:"h",6:"j",7:"k",8:"l"],
        [0:"z",1:"x",2:"c",3:"v",4:"b",5:"n",6:"m"]
    ]
    
    private let baseFont = UIFont.systemFontOfSize(20.0)
    
    private var verticalStackView:UIStackView!
    private var qwertyStackView:UIStackView!
    private var asdfStackView:UIStackView!
    private var zxcvStackView:UIStackView!
    private var bottomStackView:UIStackView!
    
    private var portraitOnlyConstraints:[NSLayoutConstraint] = []
    private var landscapeOnlyConstraints:[NSLayoutConstraint] = []
    
    private var standardPressureKeys:[PressureButton] = []
    private var shiftKey:LockingKey!
    private var backspace:UIButton!
    private var swapKeysetButton:UIButton!
    private var returnKey:PressureButton!
    private var spacebar:PressureButton!
    private var expandingKey:ExpandingPressureKey!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        setupQwertyRow()
        setupAsdfRow()
        setupZxcvRow()
        setupBottomRow()
        setupVerticalStackView()
        setupKeyConstraints()
       
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
            let title = primaryMapping[0][i]!
            let key = setupPressureKey(i, title: title)
            qwertyStackView.addArrangedSubview(key)
            standardPressureKeys.append(key)
        }
        
        
    }
    
    private func setupAsdfRow(){
        asdfStackView = generateHorizontalStackView()
        
        let leftPlaceholder = UIView()//generatePlaceholder(width: (kStandardKeyWidth / 2.0) - kStandardKeySpacing,height: 20.0)
        let rightPlaceholder = UIView()//generatePlaceholder(width: (kStandardKeyWidth / 2.0) - kStandardKeySpacing, height: 20.0)
        
        asdfStackView.addArrangedSubview(leftPlaceholder)
        for i in 0..<9 {
            let title = primaryMapping[1][i]!
            let key = setupPressureKey(i, title: title)
            asdfStackView.addArrangedSubview(key)
            standardPressureKeys.append(key)
        }
        asdfStackView.addArrangedSubview(rightPlaceholder)
        leftPlaceholder.widthAnchor.constraintEqualToAnchor(rightPlaceholder.widthAnchor).active = true  //local placeholders, any orientation
    }
    
    
    private func setupZxcvRow(){
        zxcvStackView = generateHorizontalStackView()
        
        shiftKey = LockingKey()

        
        shiftKey.translatesAutoresizingMaskIntoConstraints = false
        shiftKey.setTitle("sh", forState: .Normal)
        shiftKey.layer.cornerRadius = kKeyCornerRadius
        shiftKey.backgroundColor = kKeyBackgroundColor
        shiftKey.setTitle("SH", forState: .Selected)
        
        zxcvStackView.addArrangedSubview(shiftKey)
        
        let leftPlaceholder = UIView()
        let rightPlaceholder = UIView()
        zxcvStackView.addArrangedSubview( leftPlaceholder)//generatePlaceholder(width: (kStandardKeyWidth / 2.0) - kStandardKeySpacing * 6,height: 10.0) )
        
        for i in 0..<7 {
            let title = primaryMapping[2][i]!
            let key = setupPressureKey(i, title: title)
            zxcvStackView.addArrangedSubview(key)
            standardPressureKeys.append(key)
        }
        
        zxcvStackView.addArrangedSubview(rightPlaceholder)//generatePlaceholder(width: (kStandardKeyWidth / 2.0) - kStandardKeySpacing * 6,height: 10.0))
        
        
        backspace = UIButton()
        backspace.translatesAutoresizingMaskIntoConstraints = false
        backspace.backgroundColor = kKeyBackgroundColor
        backspace.layer.cornerRadius = kKeyCornerRadius
        zxcvStackView.addArrangedSubview(backspace)
        backspace.addTarget(self, action: "backspaceKeyPressed", forControlEvents: .TouchUpInside)
        
        
        leftPlaceholder.widthAnchor.constraintEqualToAnchor(rightPlaceholder.widthAnchor).active = true  //local placeholders, any orientation
        
    }
    
    
    private func setupBottomRow(){
        bottomStackView = generateHorizontalStackView()
        
        swapKeysetButton = UIButton(type: .System)
        swapKeysetButton.setTitle("12/*", forState: .Normal)
        swapKeysetButton.translatesAutoresizingMaskIntoConstraints = false
        swapKeysetButton.backgroundColor = kKeyBackgroundColor
        swapKeysetButton.layer.cornerRadius = kKeyCornerRadius
        swapKeysetButton.addTarget(self, action: "swapKeyset", forControlEvents: .TouchUpInside)
        bottomStackView.addArrangedSubview(swapKeysetButton)
        
        //spacebar
        
        spacebar = PressureButton()
        spacebar.translatesAutoresizingMaskIntoConstraints = false
        spacebar.backgroundColor = kKeyBackgroundColor
        spacebar.setTitle(" ", forState: .Normal)
        spacebar.addTarget(self, action: "charKeyPressed:", forControlEvents: .TouchUpInside)
        spacebar.layer.cornerRadius = kKeyCornerRadius
        bottomStackView.addArrangedSubview(spacebar)
        
        //expanding punctuation key
        
        expandingKey = ExpandingPressureKey(frame:CGRectZero)
        expandingKey.backgroundColor = kKeyBackgroundColor
        
        expandingKey.addKey(withTextLabel: ".") { (intensity) -> Void in
            self.expandingCharKeyPressed(".", intensity: intensity)
        }
        expandingKey.addKey(withTextLabel: ",") { (intensity) -> Void in
            self.expandingCharKeyPressed(",", intensity: intensity)
        }
        expandingKey.addKey(withTextLabel: "?") { (intensity) -> Void in
            self.expandingCharKeyPressed("?", intensity: intensity)
        }
        expandingKey.addKey(withTextLabel: "!") { (intensity) -> Void in
            self.expandingCharKeyPressed("!", intensity: intensity)
        }
        expandingKey.cornerRadius = kKeyCornerRadius
        bottomStackView.addArrangedSubview(expandingKey)
        
        
        
        
        returnKey = PressureButton()
        returnKey.setTitle("Return", forState: .Normal)
        returnKey.addTarget(self, action: "returnKeyPressed:", forControlEvents: .TouchUpInside)
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
            key.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor).active = true
        }
        
        backspace.widthAnchor.constraintEqualToAnchor(shiftKey.widthAnchor).active = true   //any orientation
        swapKeysetButton.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor).active = true //any orientation
        
        bottomStackView.heightAnchor.constraintEqualToAnchor(qwertyStackView.heightAnchor).active = true
        zxcvStackView.heightAnchor.constraintEqualToAnchor(qwertyStackView.heightAnchor).active = true
        asdfStackView.heightAnchor.constraintEqualToAnchor(qwertyStackView.heightAnchor).active = true

        
        ///setup portrait constraints
        portraitOnlyConstraints.append( expandingKey.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor, multiplier: 1.5) )
        portraitOnlyConstraints.append( shiftKey.widthAnchor.constraintGreaterThanOrEqualToAnchor(standardPressureKeys[0].widthAnchor, multiplier: 1.3) )
        portraitOnlyConstraints.append( shiftKey.widthAnchor.constraintLessThanOrEqualToAnchor(standardPressureKeys[0].widthAnchor, multiplier: 1.5) )
        portraitOnlyConstraints.append( returnKey.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor, multiplier: 2.0) )
        
        ///setup landscape constraints
        landscapeOnlyConstraints.append( expandingKey.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor, multiplier: 1.0) )
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
    
    func setupPressureKey(tag:Int, title:String)->PressureButton{
        let nextKey = PressureButton(type: UIButtonType.System)
        nextKey.tag = tag
        //nextKey.setTitle("\(title)", forState: .Normal)
        nextKey.setAttributedTitle(NSAttributedString(string: title,attributes: [NSFontAttributeName:baseFont]), forState: .Normal)
        nextKey.backgroundColor = UIColor.lightGrayColor()
        
        nextKey.setContentHuggingPriority(100, forAxis: .Horizontal)
        nextKey.translatesAutoresizingMaskIntoConstraints = false
        nextKey.addTarget(self, action: "charKeyPressed:", forControlEvents: .TouchUpInside)
        nextKey.layer.cornerRadius = kKeyCornerRadius
        return nextKey
    }
    
    
    func expandingCharKeyPressed(text:String,intensity:RawIntensity){
        self.lastKeyAvgIntensity = Float(intensity.avgPressure)
        self.lastKeyPeakIntensity = Float(intensity.peakPressure)
        if shiftKey.selected {
            shiftKey.deselect(overrideSelectedLock: false)
            self.textDocumentProxy.insertText(text.uppercaseString)
        } else {
            self.textDocumentProxy.insertText(text)
        }
        
    }
    
    
    
    func charKeyPressed(sender:PressureButton!){
        if let text = sender.titleLabel?.text {
            self.lastKeyAvgIntensity = Float(sender.avgPressure)
            self.lastKeyPeakIntensity = Float(sender.peakPressure)
            if shiftKey.selected {
                shiftKey.deselect(overrideSelectedLock: false)
                self.textDocumentProxy.insertText(text.uppercaseString)
            } else {
                self.textDocumentProxy.insertText(text)
            }
        }
    }
    func returnKeyPressed(sender:PressureButton!){
        self.lastKeyAvgIntensity = Float(sender.avgPressure)
        self.lastKeyPeakIntensity = Float(sender.peakPressure)
        self.textDocumentProxy.insertText("\n")
        shiftKey.deselect(overrideSelectedLock: false)
    }
    
    func backspaceKeyPressed(){
        textDocumentProxy.deleteBackward()
    }
    
    func swapKeyset(){
        print("swap keyset")
    }
    
 
    
    
    
    
}







