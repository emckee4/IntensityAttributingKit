//
//  IAKeyboardDelegateProtocol.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 4/8/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


protocol IAKeyboardDelegate:class {
    func iaKeyboard(iaKeyboard:IAKeyboard, insertTextAtCursor text:String, intensity:Int)
    func iaKeyboard(iaKeyboard:IAKeyboard, suggestionSelected text:String, intensity:Int)
    
}