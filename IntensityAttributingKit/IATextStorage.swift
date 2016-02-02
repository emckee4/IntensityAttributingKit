//
//  IATextStorage.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/31/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


class IATextStorage: NSTextStorage {
    
    
    /*
    need to override:
    
    var string
    func
    - (NSString *)string;
    
    - (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range;
    
    And subclasses must override two NSMutableAttributedString primitives:
    
    - (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str;
    
    - (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range;
    
*/
    
    override var string:String {
        return super.string
    }
    
    override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [String : AnyObject] {
        return super.attributesAtIndex(location, effectiveRange: range)
    }
    
    override func replaceCharactersInRange(range: NSRange, withAttributedString attrString: NSAttributedString) {
        super.replaceCharactersInRange(range, withAttributedString: attrString)
    }
    
    override func setAttributes(attrs: [String : AnyObject]?, range: NSRange) {
        super.setAttributes(attrs, range: range)
    }
}





