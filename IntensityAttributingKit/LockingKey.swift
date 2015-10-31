//
//  LockingKey.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/31/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit


///Sticky state toggling button which supports a locking selected state on double tap
class LockingKey:UIButton {
    
    let kSelectedLockedOnState = 1 << 16
    
    var selectedLockedOn = false {
        didSet{
            if selectedLockedOn != oldValue {
                selected = selectedLockedOn
                self.highlighted = selectedLockedOn
                //self.setNeedsLayout()
            }
        }
    }
    ///Because a TouchUpInside inevitably follows any TouchDowns we need to ignore the next TouchUpInside after a TouchDownRepeat
    private var ignoreNextTouchupInside = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: "changeSelected", forControlEvents: .TouchUpInside)
        self.addTarget(self, action: "setSelectedLockedOn", forControlEvents: .TouchDownRepeat)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeSelected(){
        guard !ignoreNextTouchupInside else {ignoreNextTouchupInside = false; return}
        if self.selected {
            deselect(overrideSelectedLock: true)
        } else {
            self.selected = true
        }
    }
    
    func setSelectedLockedOn(){
        self.selectedLockedOn = true
        selected = true
        ignoreNextTouchupInside = true
    }
    
    func deselect(overrideSelectedLock overriding:Bool){
        if overriding {
            self.selectedLockedOn = false
            self.selected = false
        } else if !self.selectedLockedOn {
            self.selected = false
        }
    }
    
    /*
    setImageForSelectionLock
    
    setText/AttributedTextForSelectionLock
    
    setHighlighting, bgcolor, bgimage, etc for selectionLock
    
    */
    
}
