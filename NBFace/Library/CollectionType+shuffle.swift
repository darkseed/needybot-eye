//
//  CollectionType+shuffle.swift
//  NBFace
//
//  Created by David Glivar on 2/8/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation

extension Collection {
    
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}
