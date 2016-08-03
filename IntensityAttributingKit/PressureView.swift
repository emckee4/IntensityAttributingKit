//
//  PressureView.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 11/6/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit


///The PressureView is basically the same as PressureKey except that its base class is UIView instead of UILabel.
class PressureView:UIView, PressureControl {
    
    lazy var rawIntensity:RawIntensity = RawIntensity()
    
    weak var delegate:PressureKeyActionDelegate?
    
    var contentView:UIView!
    var actionName:String!
    
    
    override var backgroundColor:UIColor? {
        didSet{contentView?.backgroundColor = self.backgroundColor}
    }
    
    private var contentConstraints:[NSLayoutConstraint] = []
    
    
    ///Color for background of selected cell if 3dTouch (and so our dynamic selection background color) are not available.
    var selectionColor = UIColor.darkGrayColor()
    
    private func setBackgroundColorForIntensity(){
        guard !IAKitPreferences.deviceResourcesLimited else {return}
        guard self.backgroundColor != nil else {return}
        //guard forceTouchAvailable else {contentView?.backgroundColor = selectionColor; return}
        let intensity = rawIntensity.currentIntensity
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
    
    func setAsSpecialKey(contentView:UIView, actionName:String){
        _ = contentConstraints.map({$0.active = false})
        contentConstraints = []
        self.contentView = contentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        
        contentConstraints.append(contentView.topAnchor.constraintEqualToAnchor(self.topAnchor))
        contentConstraints.append(contentView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor))
        contentConstraints.append(contentView.leftAnchor.constraintEqualToAnchor(self.leftAnchor))
        contentConstraints.append(contentView.rightAnchor.constraintEqualToAnchor(self.rightAnchor))
        _ = contentConstraints.map({$0.active = true})
        contentView.backgroundColor = self.backgroundColor
        
        self.actionName = actionName
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        guard contentView != nil else {return}
        //there should be one and only one touch in the touches set in touchesBegan since we have multitouch disabled
        if let touch = touches.first {
            //rawIntensity = RawIntensity(withValue: touch.force,maximumPossibleForce: touch.maximumPossibleForce)
            rawIntensity.updateIntensity(withTouch: touch)
            setBackgroundColorForIntensity()
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        guard contentView != nil  else {return}
        if let touch = touches.first {
            if pointInside(touch.locationInView(self), withEvent: event){
                //rawIntensity.append(touch.force)
                rawIntensity.updateIntensity(withTouch: touch)
                setBackgroundColorForIntensity()
            } else {
                //rawIntensity.reset()
                rawIntensity.cancelInteraction()
                resetBackground()
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        guard contentView != nil else {return}
        let lastVal = rawIntensity.endInteraction(withTouch: touches.first)
        if let touch = touches.first {
            if pointInside(touch.locationInView(self), withEvent: event){
                //rawIntensity.append(touch.force)
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
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        self.resetBackground()
        //rawIntensity.reset()
        rawIntensity.cancelInteraction()
    }
}


    
    
    

    
    





