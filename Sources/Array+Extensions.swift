//
//  Array+Extensions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 10/18/17.
//  Copyright © 2017 McKeeMaKer. All rights reserved.
//

import Foundation

extension Array where Element:Hashable {
    func withoutDuplicates() -> [Element] {
        var seenElements:Set<Element> = []
        var results:[Element] = []
        for item in self {
            guard !seenElements.contains(item) else {continue}
            seenElements.insert(item)
            results.append(item)
        }
        return results
    }
}
