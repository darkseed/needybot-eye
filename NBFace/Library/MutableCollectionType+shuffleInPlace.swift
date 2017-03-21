//
//  MutableCollectionType+shuffleInPlace.swift
//  NBFace
//
//  Created by David Glivar on 2/8/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation

extension MutableCollection where Index == Int {
    
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            if i != j {
                swap(&self[i], &self[j])
            }
        }
    }
}
