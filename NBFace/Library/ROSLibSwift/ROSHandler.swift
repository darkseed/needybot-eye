//
//  ROSHandler.swift
//  ROSLibSwift
//
//  Created by David Glivar on 2/16/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation

open class ROSHandler: NSObject {
    
    public typealias Handle = ([String: AnyObject]) -> ()
    
    open var handle: Handle
    
    public init(handle: @escaping ROSHandler.Handle) {
        self.handle = handle
    }
}
