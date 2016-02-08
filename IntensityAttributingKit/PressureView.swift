//
//  PressureView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/6/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit

///Delegate based equivilent of PressureButton.
class PressureView:UIView, PressureControl {
    
    
    lazy var forceTouchAvailable:Bool = {
        return self.traitCollection.forceTouchCapability == UIForceTouchCapability.Available
    }()
    
    lazy var rawIntensity:RawIntensity = RawIntensity()
    
//    ///this value is made available for the receiving class after it receives the action message from a touch
//    var lastIntensity:Float {
//        return rawIntensity.intensity
//    }
    weak var delegate:PressureKeyActionDelegate?
    
    private var contentView:UIView!
    var actionName:String!

    
    
//    private var baseBackgroundColor:UIColor? {
//        didSet {contentView?.backgroundColor = baseBackgroundColor}
//    }
//    override var backgroundColor:UIColor? {
//        get{return baseBackgroundColor }
//        set{baseBackgroundColor = newValue}
//    }
    override var backgroundColor:UIColor? {
        didSet{contentView?.backgroundColor = self.backgroundColor}
    }
    
    ///Color for background of selected cell if 3dTouch (and so our dynamic selection background color) are not available
    var nonTouchSelectionBGColor = UIColor.darkGrayColor()
    
    private func setBackgroundColorForIntensity(){
        guard self.backgroundColor != nil else {return}
        guard forceTouchAvailable else {contentView?.backgroundColor = nonTouchSelectionBGColor; return}
        let intensity = rawIntensity.intensity
        guard intensity > 0 else {contentView.backgroundColor = self.backgroundColor; return}
        var white:CGFloat = -1.0
        var alpha:CGFloat = 1.0
        self.backgroundColor!.getWhite(&white, alpha: &alpha)
        let newAlpha:CGFloat = max(alpha * CGFloat(1 + intensity), 1.0)
        let newWhite:CGFloat = white * CGFloat(1 - intensity)
        contentView?.backgroundColor = UIColor(white: newWhite, alpha: newAlpha)
    }
    ///When the touch ends this sets the background color to normal
    private func resetBackground(){
        contentView.backgroundColor = self.backgroundColor
    }
    
    init() {
        super.init(frame: CGRectZero)
        setupKey()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupKey()
    }
    
    func setupKey(){
        self.translatesAutoresizingMaskIntoConstraints = false
        //set default background
        self.backgroundColor = UIColor.lightGrayColor()
        self.multipleTouchEnabled = false
        self.clipsToBounds = true
    }
    
    
    func setAsCharKey(charToInsert:String){
        if (contentView as? UILabel) == nil {
            contentView = UILabel()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(contentView)
            contentView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
            contentView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
            contentView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
            contentView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
            contentView.setContentHuggingPriority(100, forAxis: .Horizontal)
            contentView.setContentHuggingPriority(100, forAxis: .Vertical)
        }

        (contentView as! UILabel).font = UIFont.systemFontOfSize(20.0)
        (contentView as! UILabel).textAlignment = .Center
        (contentView as! UILabel).text = charToInsert
        
        contentView.backgroundColor = self.backgroundColor
        self.actionName = charToInsert
    }
    
    func setAsSpecialKey(contentView:UIView, actionName:String){
        self.contentView = contentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        contentView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        contentView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        contentView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        contentView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        
        contentView.backgroundColor = self.backgroundColor
        
        self.actionName = actionName
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        guard contentView != nil else {return}
        //there should be one and only one touch in the touches set in touchesBegan since we have multitouch disabled
        if let touch = touches.first {
            rawIntensity = RawIntensity(withValue: touch.force,maximumPossibleForce: touch.maximumPossibleForce)
            setBackgroundColorForIntensity()
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        guard contentView != nil  else {return}
        if let touch = touches.first {
            if pointInside(touch.locationInView(self), withEvent: event){
                rawIntensity.append(touch.force)
                setBackgroundColorForIntensity()
            } else {
                rawIntensity.reset()
                resetBackground()
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        guard contentView != nil else {return}
        if let touch = touches.first {
            if pointInside(touch.locationInView(self), withEvent: event){
                rawIntensity.append(touch.force)
                if actionName != nil {
                    self.delegate?.pressureKeyPressed(self, actionName: self.actionName, intensity: rawIntensity.intensity)
                    if self.delegate == nil {
                        print("delegate not set for PressureView with action \(actionName)")
                    }
                }
            }
        }
        self.resetBackground()
        rawIntensity.reset()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        self.resetBackground()
        rawIntensity.reset()
    }

}
