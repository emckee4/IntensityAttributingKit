//
//  PressureKey.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/12/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


class PressureKey:UILabel, PressureControl {
    
    lazy var rawIntensity:RawIntensity = RawIntensity()
    
    
    weak var delegate:PressureKeyActionDelegate?
    
    var actionName:String!
    
    ///Color for background of selected cell if 3dTouch (and so our dynamic selection background color) are not available.
    var selectionColor = UIColor.darkGrayColor()
    private var _baseBackgroundColor:UIColor? = UIColor.lightGrayColor()
    
    override var backgroundColor:UIColor? {
        set {_baseBackgroundColor = newValue; super.backgroundColor = newValue}//setBackgroundColorForIntensity()}
        get {return _baseBackgroundColor}
    }
    
    private func setBackgroundColorForIntensity(precomputedValue:Int? = nil){
        guard !IAKitOptions.deviceResourcesLimited else {return}
        if self._baseBackgroundColor == nil {self._baseBackgroundColor = UIColor.clearColor()}
        //guard forceTouchAvailable else {contentView?.backgroundColor = selectionColor; return}
        let intensity = precomputedValue ?? (rawIntensity.currentIntensity ?? 0)
        guard intensity > 0 else {super.backgroundColor = _baseBackgroundColor; return}
        var white:CGFloat = -1.0
        var alpha:CGFloat = 1.0
        self._baseBackgroundColor!.getWhite(&white, alpha: &alpha)
        let newAlpha:CGFloat = max(alpha * CGFloat(1 + intensity), 1.0)
        let newWhite:CGFloat = white * CGFloat(1 - intensity)
        super.backgroundColor = UIColor(white: newWhite, alpha: newAlpha)
    }
    ///When the touch ends this sets the background color to normal
    private func resetBackground(){
        super.backgroundColor = self._baseBackgroundColor
    }
    
    init() {
        super.init(frame: CGRectZero)
        setupKey()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupKey()
    }
    
    
    func setupKey() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.multipleTouchEnabled = false
        self.textAlignment = .Center
        self.userInteractionEnabled = true
    }
    
    ///Sets up the key with the same actionName as text in the key
    func setCharKey(charToInsert:String, font:UIFont = UIFont.systemFontOfSize(20)){
        //guard charToInsert.utf16.count > 0 else {fatalError("can't use setCharKey with empty text")}
        setKey(charToInsert, actionName: charToInsert)
    }
    
    func setKey(text:String, actionName:String){
        self.text = text
        self.actionName = actionName
    }
    
    func setKey(attributedString attString:NSAttributedString, actionName:String){
        self.attributedText = attString
        self.actionName = actionName
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        //there should be one and only one touch in the touches set in touchesBegan since we have multitouch disabled
        if let touch = touches.first {
            //rawIntensity = RawIntensity(withValue: touch.force,maximumPossibleForce: touch.maximumPossibleForce)
            rawIntensity.updateIntensity(withTouch: touch)
            setBackgroundColorForIntensity()
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        if let touch = touches.first {
            if pointInside(touch.locationInView(self), withEvent: event){
                rawIntensity.updateIntensity(withTouch: touch)
                setBackgroundColorForIntensity()
            } else {
                rawIntensity.cancelInteraction()
                resetBackground()
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        let lastVal = rawIntensity.endInteraction(withTouch: touches.first)
        if let touch = touches.first {
            if pointInside(touch.locationInView(self), withEvent: event){
                if actionName != nil {
                    self.delegate?.pressureKeyPressed(self, actionName: self.actionName, intensity: lastVal)
                    if self.delegate == nil {
                        print("delegate not set for PressureView with action \(actionName)")
                    }
                }
            }
        }
        self.resetBackground()
        //rawIntensity.reset()
    }
    
//    override func touchesEstimatedPropertiesUpdated(touches: Set<NSObject>) {
//        super.touchesEstimatedPropertiesUpdated(touches)
//        
//    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        self.resetBackground()
        rawIntensity.cancelInteraction()
    }

    
}
