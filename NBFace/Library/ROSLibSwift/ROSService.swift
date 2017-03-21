//
//  ROSService.swift
//  NBFace
//
//  Created by David Glivar on 2/26/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation

open class ROSService: NSObject {
    
    open let op = "call_service"
    open let service: String
    open let type: String
    
    open var args: [String: AnyObject]?
    open var id = UUID().uuidString
    open var serviceCallback: ROSHandler?
    
    init(service: String, type: String, args: [String: AnyObject]?) {
        self.service = service
        self.type = type
        self.args = args
    }
    
    open func callService(_ callback: ROSHandler?) {
        var message: [String: AnyObject] = [
            "op": op as AnyObject,
            "service": service as AnyObject,
            "id": id as AnyObject
        ]
        if let args = args {
            message["args"] = args as AnyObject?
        }
        serviceCallback = callback
        let payload = ROS.objectToJSONString(message)
        ROS.sharedInstance.registerService(self)
        ROS.sharedInstance.send(payload)
    }
}
