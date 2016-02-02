//
//  TVInputTest.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/30/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

public class TVInputTest: UITextView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
//    var typingAttributes {
//        didSet{
//        
//        }
//    }
    
    override public func insertText(text: String) {
        super.insertText(text)
    }
    
    override public func deleteBackward() {
        super.deleteBackward()
    }
    
    override public func hasText() -> Bool {
        return super.hasText()
    }
    
    
    
    override public func shouldChangeTextInRange(range: UITextRange, replacementText text: String) -> Bool {
        return super.shouldChangeTextInRange(range, replacementText: text)
    }
    
    override public func textInRange(range: UITextRange) -> String? {
        return super.textInRange(range)
    }
    
    override public func replaceRange(range: UITextRange, withText text: String) {
        return super.replaceRange(range, withText: text)
    }
    
    
    
    
    

}
