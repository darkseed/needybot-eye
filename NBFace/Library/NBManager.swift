//
//  NBManager.swift
//  NBFace
//
//  Created by David Glivar on 2/8/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation

protocol NBManager: class {
    var handlers: [NBHandler] { get set }
    func addHandler(_ handler: NBHandler) -> Bool
    func removeHandler(_ handler: NBHandler) -> Bool
    func runStack(_ args: Any?...)
}

extension NBManager {
    
    func addHandler(_ handler: NBHandler) -> Bool {
        guard let _ = handlers.index(of: handler) else {
            handlers.append(handler)
            return true
        }
        return false
    }
    
    func removeHandler(_ handler: NBHandler) -> Bool {
        guard let idx = handlers.index(of: handler) else {
            return false
        }
        handlers.remove(at: idx)
        return true
    }
    
    func removeAllHandlers() {
        handlers = []
    }
    
    func runStack(_ args: Any?...) {
        var toremove = [NBHandler]()
        for handler in handlers {
            handler.handle(args)
            if handler.oneshot {
                toremove.append(handler)
            }
        }
        for handler in toremove {
            removeHandler(handler)
        }
    }
}
