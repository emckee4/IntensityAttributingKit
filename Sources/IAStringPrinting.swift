//
//  IAStringPrinting.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/2/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit


extension IAString:CustomStringConvertible, CustomDebugStringConvertible {
    
    
    public var description:String {
        return "IAString: \"" + self.text + "\""
    }
    
    public var debugDescription:String {
        return self.description + "\nIntensities: \(self.intensities)\nBaseAtts:\(self.baseAttributes)\nLinks:\(self.links)\nAttachments:\(self.attachments)\nisValid?: \(self.validate())"
    }
    
    ///Performs basic validation of IAString, returning true if passing checks
    public func validate()->Bool{
        guard self.length == self.text.utf16.count else {print("invalid IAString: self.length != self.text.utf16.count"); return false}
        guard self.length == baseAttributes.count else {print("invalid IAString: self.length != baseAttributes.count"); return false}
        guard self.length == self.intensities.count else {print("invalid IAString: self.length != self.intensities.count"); return false}
        guard self.attachments.count == 0 || self.length > (self.attachments.lastLoc ?? 0) else {print("invalid IAString: self.length < (self.attachments.lastLoc) "); return false}
        guard self.length >= (self.links.last?.endIndex ?? 0) else {print("invalid IAString: self.length < (self.links.last?.endIndex"); return false}
        guard baseAttributes.validate() else {print("invalid IAString: baseAttributes.validate() failed "); return false}
        
        return true
    }
    
}
