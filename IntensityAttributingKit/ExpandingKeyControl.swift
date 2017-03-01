//
//  ExpandingKeyControl.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/8/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


///Non pressure sensitive ExpandingKey which will trigger a given target/action pair on touchupinside. This object only supports a single target for touchUpInside in order to keep the interface simple.
@IBDesignable open class ExpandingKeyControl: ExpandingKeyBase {
    
    fileprivate(set) open weak var target:AnyObject?
    fileprivate(set) open var selector:String?
    
    open func setSelector(_ target:AnyObject,selector:String){
        guard target.responds(to: Selector(selector)) else {fatalError("ExpandingKeyControl.setSelector given target that does not respond to the provided selector")}
        self.target = target
        self.selector = selector
    }
    
    open func removeSelector(){
        target = nil
        selector = nil
    }
    
    override func handleKeySelection(_ selectedKey:EPKey, finalTouch:UITouch?){
        if target != nil && selector != nil {
            _ = target?.perform(Selector(self.selector!), with: selectedKey.actionName)
        }
    }
}
