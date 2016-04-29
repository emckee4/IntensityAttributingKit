//
//  IACaret.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/7/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//
/*
import UIKit


class IACaret:UIView{
    
    let blinkAnimation:CABasicAnimation = {
        let caretBlink = CABasicAnimation(keyPath: "opacity")
        caretBlink.fromValue = 1.0
        caretBlink.toValue = 0.4
        caretBlink.repeatCount = 99999
        caretBlink.duration = 0.75
        caretBlink.autoreverses = true
        //caretBlink.removedOnCompletion = false
        return caretBlink
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
        self.layer.addAnimation(blinkAnimation, forKey: "opacity")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
        self.layer.addAnimation(blinkAnimation, forKey: "opacity")
    }
    
    override var hidden: Bool {
        didSet {
            self.layer.addAnimation(blinkAnimation, forKey: "opacity")
        }
    }
    
    override func animationDidStart(anim: CAAnimation) {
        print("animationDidStart")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        print("animationDidStop")
    }
    
}

*/