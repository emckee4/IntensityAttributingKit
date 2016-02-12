//
//  ExpandingKeyControl.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/8/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


///Non pressure sensitive ExpandingKey which will trigger a given target/action pair on touchupinside. This object only supports a single target for touchUpInside in order to keep the interface simple.
@IBDesignable public class ExpandingKeyControl: ExpandingKeyBase {
    
    private(set) public weak var target:AnyObject?
    private(set) public var selector:String?
    
    public func setSelector(target:AnyObject,selector:String){
        guard target.respondsToSelector(Selector(selector)) else {fatalError("ExpandingKeyControl.setSelector given target that does not respond to the provided selector")}
        self.target = target
        self.selector = selector
    }
    
    public func removeSelector(){
        target = nil
        selector = nil
    }
    
    override func handleKeySelection(selectedKey:EPKey){
        if target != nil && selector != nil {
            target?.performSelector(Selector(self.selector!), withObject: selectedKey.actionName)
        }
    }
}
