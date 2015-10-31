//
//  ExpandingPressureKey.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/31/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import UIKit


///Configurable dropdown-like button which provides force-touch data when available
class ExpandingPressureKey: UIView {
    
    
    
    
    //needs view for drawing expanded container (in order to bypass constraints). if none provided then either the immediate superview is used or the view itself resizes
    
    ///needs unique event state most likely but can use target action if so inclined
    //needs direction for expansion
    //needs array of items and what to display in each: display can be handled by it being any subclass of uiview: need means for applying action for each
    
    
    func addKey(keyView keyView:UIView, action: Selector){
        
    }
}
