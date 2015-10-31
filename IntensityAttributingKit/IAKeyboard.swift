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
    
    
    //    var screenWidth:CGFloat {return UIScreen.mainScreen().bounds.width}
    //    var stackWidth:CGFloat {return screenWidth - (2 * kStackInset)}
    //
    //    var topRowKeyWidth:CGFloat { return(stackWidth - 9 * kStandardKeySpacing) / 10.0}
    //
    var shiftKey:LockingKey!
    
    let kKeyHeight:CGFloat = 40.0
    let kStandardKeySpacing:CGFloat = 4.0
    let kStackInset:CGFloat = 2.0
    
    let primaryMapping:[[Int:String]] = [
        [0:"q",1:"w",2:"e",3:"r",4:"t",5:"y",6:"u",7:"i",8:"o",9:"p"],
        [0:"a",1:"s",2:"d",3:"f",4:"g",5:"h",6:"j",7:"k",8:"l"],
        [0:"z",1:"x",2:"c",3:"v",4:"b",5:"n",6:"m"]
    ]
    
    let baseFont = UIFont.systemFontOfSize(20.0)
    
    var verticalStackView:UIStackView!
    var qwertyStackView:UIStackView!
    var asdfStackView:UIStackView!
    var zxcvStackView:UIStackView!
    var bottomStackView:UIStackView!
    
    
    var standardPressureKeys:[PressureButton] = []
    
    
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
    
    
    
    
    func setupQwertyRow(){
        qwertyStackView = generateHorizontalStackView()
        
        for i in 0..<10 {
            let title = primaryMapping[0][i]!
            let key = setupPressureKey(i, title: title)
            qwertyStackView.addArrangedSubview(key)
            standardPressureKeys.append(key)
        }
        
        
    }
    
    func setupAsdfRow(){
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
        leftPlaceholder.widthAnchor.constraintEqualToAnchor(rightPlaceholder.widthAnchor).active = true
    }
    
    
    func setupZxcvRow(){
        zxcvStackView = generateHorizontalStackView()
        
        shiftKey = LockingKey()
        // shiftButton.widthAnchor.constraintEqualToConstant(kKeyHeight).active = true
        // shiftButton.heightAnchor.constraintEqualToConstant(kKeyHeight).active = true
        shiftKey.widthAnchor.constraintGreaterThanOrEqualToAnchor(shiftKey.heightAnchor).active = true
        shiftKey.translatesAutoresizingMaskIntoConstraints = false
        shiftKey.setTitle("sh", forState: .Normal)
        shiftKey.setTitle("SH", forState: .Selected)
        shiftKey.setTitleColor(UIColor.yellowColor(), forState: UIControlState.Highlighted.union(.Selected))
        
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
        
        
        let backspace = UIButton()
        //backspace.widthAnchor.constraintEqualToConstant(kKeyHeight).active = true
        //backspace.heightAnchor.constraintEqualToConstant(kKeyHeight).active = true
        //backspace.heightAnchor.constraintEqualToAnchor(backspace.widthAnchor).active = true
        backspace.translatesAutoresizingMaskIntoConstraints = false
        backspace.backgroundColor = UIColor.purpleColor()
        zxcvStackView.addArrangedSubview(backspace)
        backspace.addTarget(self, action: "backspaceKeyPressed", forControlEvents: .TouchUpInside)
        shiftKey.widthAnchor.constraintEqualToAnchor(backspace.widthAnchor).active = true
        
        leftPlaceholder.widthAnchor.constraintEqualToAnchor(rightPlaceholder.widthAnchor).active = true
        
    }
    
    
    func setupBottomRow(){
        bottomStackView = generateHorizontalStackView()
        
        let space = PressureButton()
        //space.widthAnchor.constraintEqualToConstant(kKeyHeight).active = true
        //space.heightAnchor.constraintEqualToConstant(kKeyHeight).active = true
        space.translatesAutoresizingMaskIntoConstraints = false
        space.backgroundColor = UIColor.purpleColor()
        space.setTitle(" ", forState: .Normal)
        space.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        bottomStackView.addArrangedSubview(space)
        
    }
    
    
    
    func setupVerticalStackView(){
        
        
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
    
    func setupKeyConstraints(){
        for key in standardPressureKeys[1..<standardPressureKeys.count]{
            key.widthAnchor.constraintEqualToAnchor(standardPressureKeys[0].widthAnchor).active = true
        }
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
        let nextKey = PressureButton(type: UIButtonType.RoundedRect)
        nextKey.tag = tag
        //nextKey.setTitle("\(title)", forState: .Normal)
        nextKey.setAttributedTitle(NSAttributedString(string: title,attributes: [NSFontAttributeName:baseFont]), forState: .Normal)
        nextKey.backgroundColor = UIColor.lightGrayColor()
        
        nextKey.setContentHuggingPriority(100, forAxis: .Horizontal)
        nextKey.translatesAutoresizingMaskIntoConstraints = false
        nextKey.addTarget(self, action: "charKeyPressed:", forControlEvents: .TouchUpInside)
        nextKey.layer.cornerRadius = 4.0
        return nextKey
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
    
    func backspaceKeyPressed(){
        textDocumentProxy.deleteBackward()
    }
    
    
    
    
}







