//
//  NSHashTable+Extension.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 3/10/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation


extension NSHashTable: SequenceType {
    public func generate() -> NSFastGenerator {
        return NSFastGenerator(self)
    }
}