//
//  Message.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 8/10/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation
import IntensityAttributingKit

struct Message {
    let messageID:String
    let iaStringArchive:IAStringArchive
    let createdAt:Date
    let isSender:Bool
    
    var iaString:IAString {
        return iaStringArchive.iaString
    }
    
    init(iaString:IAString, isSender:Bool){
        self.iaStringArchive = IAStringArchive(iaString: iaString)
        self.isSender = isSender
        self.createdAt = NSDate() as Date
        self.messageID = String.randomAlphaString(8)
    }
}

