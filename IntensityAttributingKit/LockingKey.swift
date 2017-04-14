//
//  LockingKey.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/31/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit


///Sticky state toggling button which supports a locking selected state on double tap. This is used as the shift key.
class LockingKey:UIButton {
    
//    let kSelectedLockedOnFlag:UInt = 1 << 16
//    let kSelectedLockedOnState:UIControlState = UIControlState(rawValue: (1 << 16))
    fileprivate let cgClear = UIColor.clear.cgColor
    fileprivate let cgBlack = UIColor.black.cgColor
    
    var selectedLockedOn = false {
        didSet{
            if selectedLockedOn != oldValue {
                isSelected = selectedLockedOn
                layer.borderColor = selectedLockedOn ? cgBlack : cgClear
            }
        }
    }
    ///Because a TouchUpInside inevitably follows any TouchDowns we need to ignore the next TouchUpInside after a TouchDownRepeat
    fileprivate var ignoreNextTouchupInside = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(LockingKey.changeSelected), for: .touchDown)
        self.addTarget(self, action: #selector(LockingKey.setSelectedLockedOn), for: .touchDownRepeat)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = cgClear
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeSelected(){
        //guard !ignoreNextTouchupInside else {ignoreNextTouchupInside = false; return}
        if self.isSelected {
            deselect(overrideSelectedLock: true)
        } else {
            self.isSelected = true
        }
    }
    
    func setSelectedLockedOn(){
        self.selectedLockedOn = true
        isSelected = true
        //ignoreNextTouchupInside = true
    }
    
    func deselect(overrideSelectedLock overriding:Bool){
        if overriding {
            self.selectedLockedOn = false
            self.isSelected = false
        } else if !self.selectedLockedOn {
            self.isSelected = false
        }
    }

    
}
