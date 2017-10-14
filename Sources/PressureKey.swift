//
//  PressureKey.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/12/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

/**
The PressureKey passes its touch data to the RawIntensity constellation of classes/structs in order to provide touch intensity data during/on completion of touch events. 
*/
class PressureKey:UILabel, PressureControl {
    
    lazy var rawIntensity:RawIntensity = RawIntensity()
    
    
    weak var delegate:PressureKeyActionDelegate?
    
    var actionName:String!
    
    ///Color for background of selected cell if 3dTouch (and so our dynamic selection background color) are not available.
    var selectionColor = UIColor.darkGray
    fileprivate var _baseBackgroundColor:UIColor? = UIColor.lightGray
    
    override var backgroundColor:UIColor? {
        set {_baseBackgroundColor = newValue; super.backgroundColor = newValue}//setBackgroundColorForIntensity()}
        get {return _baseBackgroundColor}
    }
    
    fileprivate func setBackgroundColorForIntensity(_ precomputedValue:Int? = nil){
        guard !IAKitPreferences.deviceResourcesLimited else {return}
        if self._baseBackgroundColor == nil {self._baseBackgroundColor = UIColor.clear}
        //guard forceTouchAvailable else {contentView?.backgroundColor = selectionColor; return}
        let intensity = precomputedValue ?? (rawIntensity.currentIntensity ?? 0)
        guard intensity > 0 else {super.backgroundColor = _baseBackgroundColor; return}
        var white:CGFloat = -1.0
        var alpha:CGFloat = 1.0
        self._baseBackgroundColor!.getWhite(&white, alpha: &alpha)
        let newAlpha:CGFloat = min(alpha * CGFloat(1 + intensity), 1.0)
        let newWhite:CGFloat = white * CGFloat(100 - intensity) / 100
        super.backgroundColor = UIColor(white: newWhite, alpha: newAlpha)
    }
    ///When the touch ends this sets the background color to normal
    fileprivate func resetBackground(){
        super.backgroundColor = self._baseBackgroundColor
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupKey()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupKey()
    }
    
    
    func setupKey() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isMultipleTouchEnabled = false
        self.textAlignment = .center
        self.isUserInteractionEnabled = true
    }
    
    ///Sets up the key with the same actionName as text in the key
    func setCharKey(_ charToInsert:String, font:UIFont = UIFont.systemFont(ofSize: 20)){
        //guard charToInsert.utf16.count > 0 else {fatalError("can't use setCharKey with empty text")}
        setKey(charToInsert, actionName: charToInsert)
    }
    
    func setKey(_ text:String, actionName:String){
        self.text = text
        self.actionName = actionName
    }
    
    func setKey(attributedString attString:NSAttributedString, actionName:String){
        self.attributedText = attString
        self.actionName = actionName
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //there should be one and only one touch in the touches set in touchesBegan since we have multitouch disabled
        if let touch = touches.first {
            //rawIntensity = RawIntensity(withValue: touch.force,maximumPossibleForce: touch.maximumPossibleForce)
            rawIntensity.updateIntensity(withTouch: touch)
            setBackgroundColorForIntensity()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let touch = touches.first {
            if point(inside: touch.location(in: self), with: event){
                rawIntensity.updateIntensity(withTouch: touch)
                setBackgroundColorForIntensity()
            } else {
                rawIntensity.cancelInteraction()
                resetBackground()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let lastVal = rawIntensity.endInteraction(withTouch: touches.first)
        if let touch = touches.first {
            if point(inside: touch.location(in: self), with: event){
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
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.resetBackground()
        rawIntensity.cancelInteraction()
    }

    
}
