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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
        
        // Do any additional setup after loading the view.
    }
    
    
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
    
    //let kStandardKeyWidth:CGFloat = 30.0
    lazy var kStandardKeyWidth:CGFloat = {
        let width = UIScreen.mainScreen().bounds.width / 12.0
        print(width)
        return width
    }()
    
    let kKeyHeight:CGFloat = 40.0
    let kStandardKeySpacing:CGFloat = 2.0
    let kStackInset:CGFloat = 2.0
    
    let primaryMapping:[[Int:String]] = [
        [0:"q",1:"w",2:"e",3:"r",4:"t",5:"y",6:"u",7:"i",8:"o",9:"p"],
        [0:"a",1:"s",2:"d",3:"f",4:"g",5:"h",6:"j",7:"k",8:"l"],
        [0:"z",1:"x",2:"c",3:"v",4:"b",5:"n",6:"m"]
    ]
    
    let baseFont = UIFont.systemFontOfSize(20.0)
    
    var containerView:UIView!
    
    var verticalStackView:UIStackView!
    
    //var qwertyButtons:[PressureButton] = []
    var qwertyStackView:UIStackView!
    
    //var asdfButtons:[PressureButton] = []
    var asdfStackView:UIStackView!
    
    var zxcvStackView:UIStackView!
    
    var bottomStackView:UIStackView!
    
    
    var topBarMinimized = false
    
    var portraitConstraints:[NSLayoutConstraint] = []
    
    
    
    func setupQwertyRow(){
        qwertyStackView = UIStackView()
        qwertyStackView.axis = UILayoutConstraintAxis.Horizontal
        qwertyStackView.distribution = .EqualSpacing
        qwertyStackView.translatesAutoresizingMaskIntoConstraints = false
        qwertyStackView.layoutMarginsRelativeArrangement = true
        qwertyStackView.alignment = .Center
        qwertyStackView.spacing = 2.0
        for i in 0..<10 {
            let title = primaryMapping[0][i]!
            qwertyStackView.addArrangedSubview(setupPressureKey(i, title: title))
        }
        
        
    }
    
    func setupAsdfRow(){
        asdfStackView = UIStackView()
        asdfStackView.axis = UILayoutConstraintAxis.Horizontal
        //asdfStackView.distribution = .EqualSpacing
        asdfStackView.translatesAutoresizingMaskIntoConstraints = false
        asdfStackView.layoutMarginsRelativeArrangement = true
        asdfStackView.alignment = .Center
        asdfStackView.distribution = .EqualSpacing
        
        asdfStackView.addArrangedSubview(generatePlaceholder(width: (kStandardKeyWidth / 2.0) - kStandardKeySpacing) )
        for i in 0..<9 {
            let title = primaryMapping[1][i]!
            asdfStackView.addArrangedSubview(setupPressureKey(i, title: title))
        }
        asdfStackView.addArrangedSubview(generatePlaceholder(width: (kStandardKeyWidth / 2.0) - kStandardKeySpacing))
    }
    
    
    func setupZxcvRow(){
        zxcvStackView = UIStackView()
        zxcvStackView.axis = UILayoutConstraintAxis.Horizontal
        //asdfStackView.distribution = .EqualSpacing
        zxcvStackView.translatesAutoresizingMaskIntoConstraints = false
        zxcvStackView.layoutMarginsRelativeArrangement = true
        zxcvStackView.alignment = .Center
        zxcvStackView.distribution = .EqualSpacing
        
        let shiftButton = UIButton()
        shiftButton.widthAnchor.constraintEqualToConstant(kKeyHeight).active = true
        shiftButton.heightAnchor.constraintEqualToConstant(kKeyHeight).active = true
        shiftButton.translatesAutoresizingMaskIntoConstraints = false
        shiftButton.backgroundColor = UIColor.purpleColor()
        zxcvStackView.addArrangedSubview(shiftButton)
        
        
        zxcvStackView.addArrangedSubview(generatePlaceholder(width: (kStandardKeyWidth / 2.0) - kStandardKeySpacing * 6) )
        
        for i in 0..<7 {
            //            let nextKey = PressureButton(type: UIButtonType.RoundedRect)
            //            nextKey.tag = i
            //            nextKey.setTitle("\(i)", forState: .Normal)
            //            nextKey.backgroundColor = UIColor.lightGrayColor()
            //            nextKey.heightAnchor.constraintEqualToConstant(kKeyHeight).active = true
            //            nextKey.widthAnchor.constraintEqualToConstant(kStandardKeyWidth).active = true
            //            nextKey.translatesAutoresizingMaskIntoConstraints = false
            //            zxcvStackView.addArrangedSubview(nextKey)
            let title = primaryMapping[2][i]!
            zxcvStackView.addArrangedSubview(setupPressureKey(i, title: title))
        }
        
        zxcvStackView.addArrangedSubview(generatePlaceholder(width: (kStandardKeyWidth / 2.0) - kStandardKeySpacing * 6))
        
        
        let backspace = UIButton()
        backspace.widthAnchor.constraintEqualToConstant(kKeyHeight).active = true
        backspace.heightAnchor.constraintEqualToConstant(kKeyHeight).active = true
        backspace.translatesAutoresizingMaskIntoConstraints = false
        backspace.backgroundColor = UIColor.purpleColor()
        zxcvStackView.addArrangedSubview(backspace)
    }
    
    
    func setupBottomRow(){
        bottomStackView = UIStackView()
        bottomStackView.axis = UILayoutConstraintAxis.Horizontal
        //asdfStackView.distribution = .EqualSpacing
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.layoutMarginsRelativeArrangement = true
        bottomStackView.alignment = .Center
        bottomStackView.distribution = .EqualSpacing
        //
        let shiftButton = UIButton()
        shiftButton.widthAnchor.constraintEqualToConstant(kKeyHeight).active = true
        shiftButton.heightAnchor.constraintEqualToConstant(kKeyHeight).active = true
        shiftButton.translatesAutoresizingMaskIntoConstraints = false
        shiftButton.backgroundColor = UIColor.purpleColor()
        bottomStackView.addArrangedSubview(shiftButton)
        //
        //
        //        zxcvStackView.addArrangedSubview(generatePlaceholder(width: (kStandardKeyWidth / 2.0) - kStandardKeySpacing * 2) )
        //
        //        for i in 0..<7 {
        //            let nextKey = PressureButton(type: UIButtonType.RoundedRect)
        //            nextKey.tag = i
        //            nextKey.setTitle("\(i)", forState: .Normal)
        //            nextKey.backgroundColor = UIColor.lightGrayColor()
        //            nextKey.heightAnchor.constraintEqualToConstant(kKeyHeight).active = true
        //            nextKey.widthAnchor.constraintEqualToConstant(kStandardKeyWidth).active = true
        //            nextKey.translatesAutoresizingMaskIntoConstraints = false
        //            zxcvStackView.addArrangedSubview(nextKey)
        //        }
        //
        //        zxcvStackView.addArrangedSubview(generatePlaceholder(width: (kStandardKeyWidth / 2.0) - kStandardKeySpacing * 2))
        //
        //
        //        let backspace = UIButton()
        //        backspace.widthAnchor.constraintEqualToConstant(kKeyHeight).active = true
        //        backspace.heightAnchor.constraintEqualToConstant(kKeyHeight).active = true
        //        backspace.translatesAutoresizingMaskIntoConstraints = false
        //        backspace.backgroundColor = UIColor.purpleColor()
        //        zxcvStackView.addArrangedSubview(backspace)
    }
    
    var topStackView:UIStackView!
    
    func setupTopRow(){
        topStackView = UIStackView()
        topStackView.axis = UILayoutConstraintAxis.Horizontal
        //asdfStackView.distribution = .EqualSpacing
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.layoutMarginsRelativeArrangement = true
        topStackView.alignment = .Center
        topStackView.distribution = .EqualSpacing
        //
        let shiftButton = UIButton()
        shiftButton.widthAnchor.constraintEqualToConstant(kKeyHeight - 2.0).active = true
        shiftButton.heightAnchor.constraintEqualToConstant(kKeyHeight - 8.0).active = true
        shiftButton.translatesAutoresizingMaskIntoConstraints = false
        shiftButton.backgroundColor = UIColor.purpleColor()
        shiftButton.addTarget(self, action: "topButtonPressed:", forControlEvents: .TouchUpInside)
        topStackView.addArrangedSubview(shiftButton)
    }
    var trButton:UIButton!
    
    func setupTopRowRevealButton(){
        trButton = UIButton()
        trButton.backgroundColor = UIColor.greenColor()
        trButton.translatesAutoresizingMaskIntoConstraints = false
        trButton.widthAnchor.constraintEqualToConstant(UIScreen.mainScreen().bounds.width).active = true
        trButton.heightAnchor.constraintEqualToConstant(6.0).active = true
        trButton.layer.cornerRadius = 2.0
        trButton.hidden = true
        trButton.addTarget(self, action: "topButtonPressed:", forControlEvents: .TouchUpInside)
    }
    
    
    func setupKeyboard(){
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        setupTopRow()
        setupQwertyRow()
        setupAsdfRow()
        setupZxcvRow()
        setupBottomRow()
        setupTopRowRevealButton()
        
        //verticalStackView = UIStackView(arrangedSubviews: [qwertyStackView])
        verticalStackView = UIStackView(arrangedSubviews: [topStackView,trButton, qwertyStackView,asdfStackView,zxcvStackView,bottomStackView])
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .Vertical
        verticalStackView.distribution = .EqualSpacing
        verticalStackView.spacing = 4.0
        
        //        //self.addSubview(verticalStackView)
        //
        //
        //
        //        //let edgeInset:CGFloat = 4.0
        //        verticalStackView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor, constant: kStackInset).active = true
        //        verticalStackView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor, constant: -kStackInset).active = true
        //        verticalStackView.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: kStackInset).active = true
        //        //verticalStackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -kStackInset).active = true
        //        self.backgroundColor = UIColor.redColor()
        
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(containerView)
        //let edgeInset:CGFloat = 4.0
        containerView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: kStackInset).active = true
        containerView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -kStackInset).active = true
        containerView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: kStackInset).active = true
        containerView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -kStackInset).active = true
        containerView.addSubview(verticalStackView)
        
        
        verticalStackView.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor).active = true
        verticalStackView.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor).active = true
        verticalStackView.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        verticalStackView.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor).active = true
        
        view.backgroundColor = UIColor.redColor()
        
        
    }
    
    func generatePlaceholder(width width:CGFloat, height:CGFloat = 0.0)->UIView{
        let placeholder = UIView()
        placeholder.widthAnchor.constraintEqualToConstant(width).active = true
        if height != 0.0 {
            placeholder.heightAnchor.constraintEqualToConstant(height).active = true
        }
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        return placeholder
    }
    
    
    func setupPressureKey(tag:Int, title:String)->PressureButton{
        let nextKey = PressureButton(type: UIButtonType.RoundedRect)
        nextKey.tag = tag
        //nextKey.setTitle("\(title)", forState: .Normal)
        nextKey.setAttributedTitle(NSAttributedString(string: title,attributes: [NSFontAttributeName:baseFont]), forState: .Normal)
        nextKey.backgroundColor = UIColor.lightGrayColor()
        
        let heightConstraint = nextKey.heightAnchor.constraintGreaterThanOrEqualToConstant(kKeyHeight)
        heightConstraint.active = true
        portraitConstraints.append(heightConstraint)
        let widthConstraint = nextKey.widthAnchor.constraintEqualToConstant(kStandardKeyWidth)
        widthConstraint.active = true
        portraitConstraints.append(widthConstraint)
        nextKey.translatesAutoresizingMaskIntoConstraints = false
        nextKey.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        nextKey.layer.cornerRadius = 4.0
        return nextKey
    }
    
    
    
    
    
    func buttonPressed(sender:PressureButton!){
        
        
        if let text = sender.titleLabel?.text {
            self.lastKeyAvgIntensity = Float(sender.avgPressure)
            self.lastKeyPeakIntensity = Float(sender.peakPressure)
            self.textDocumentProxy.insertText(text)
        }
        
    }
    
    
    func topButtonPressed(sender:UIButton!){
        UIView.animateWithDuration(0.5) { () -> Void in
            if self.topBarMinimized {
                self.topStackView.hidden = false
                self.trButton.hidden = true
                NSLayoutConstraint.activateConstraints(self.portraitConstraints)
            } else {
                self.topStackView.hidden = true
                self.trButton.hidden = false
                NSLayoutConstraint.deactivateConstraints(self.portraitConstraints)
            }
        }
        topBarMinimized = !topBarMinimized
    }
    
    
    
    
    
}



/*

@IBOutlet var nextKeyboardButton: UIButton!
@IBOutlet var lightButton: PressureButton!
var lastKeyAvgIntensity:Float?
var lastKeyPeakIntensity:Float?

override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
view.translatesAutoresizingMaskIntoConstraints = false
}

required init?(coder aDecoder: NSCoder) {
super.init(coder: aDecoder)
}

override func updateViewConstraints() {
super.updateViewConstraints()

// Add custom view sizing constraints here
}
override func viewDidAppear(animated: Bool) {
super.viewDidAppear(true)
lastKeyAvgIntensity = nil
lastKeyPeakIntensity = nil
}

override func viewDidLoad() {
super.viewDidLoad()

// Perform custom UI setup here
self.nextKeyboardButton = UIButton(type: .System)

self.nextKeyboardButton.setTitle(NSLocalizedString("Next keyboard", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
self.nextKeyboardButton.sizeToFit()
self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false

self.nextKeyboardButton.titleLabel!.font = UIFont(name: "Helvetica", size: 10)

self.nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)

self.view.addSubview(self.nextKeyboardButton)

var nextKeyboardButtonLeftSideConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
var nextKeyboardButtonBottomConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
self.view.addConstraints([nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint])

// lightButton button

self.lightButton = PressureButton(type:.System)

self.lightButton.setTitle(NSLocalizedString("light", comment: "lightButton button"), forState: .Normal)
self.lightButton.sizeToFit()
self.lightButton.translatesAutoresizingMaskIntoConstraints = false

self.lightButton.titleLabel!.font = UIFont(name: "Helvetica", size: 50)

self.lightButton.addTarget(self, action: "lightButtonPressed:", forControlEvents: .TouchUpInside)

self.view.addSubview(self.lightButton)

var lightButtonCenterXConstraint = NSLayoutConstraint(item: self.lightButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
var lightButtonCenterYConstraint = NSLayoutConstraint(item: self.lightButton, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
self.view.addConstraints([lightButtonCenterXConstraint, lightButtonCenterYConstraint])
}

func lightButtonPressed(sender:PressureButton!) {
if sender?.avgPressure > 0.0 && sender?.peakPressure > 0.0 {
self.lastKeyPeakIntensity = Float(sender.avgPressure)
self.lastKeyAvgIntensity = Float(sender.peakPressure)
} else {
self.lastKeyPeakIntensity = 0
self.lastKeyAvgIntensity = 0
}

let proxy = self.textDocumentProxy as UITextDocumentProxy
proxy.insertText("Light ")
}

override func didReceiveMemoryWarning() {
super.didReceiveMemoryWarning()
// Dispose of any resources that can be recreated
}

override func textWillChange(textInput: UITextInput?) {
// The app is about to change the document's contents. Perform any preparation here.
//print("text will change: \(textInput)")
}


override func textDidChange(textInput: UITextInput?) {
// The app has just changed the document's contents, the document context has been updated.

var textColor: UIColor
let proxy = self.textDocumentProxy as UITextDocumentProxy
if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
textColor = UIColor.whiteColor()
} else {
textColor = UIColor.blackColor()
}
self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
self.lightButton.setTitleColor(textColor, forState: .Normal)
//print("text did change: \(textInput)")
}

*/

