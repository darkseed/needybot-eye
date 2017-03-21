//
//  ROSTopic.swift
//  ROSLibSwift
//
//  Created by David Glivar on 2/16/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation

open class ROSTopic: NSObject {
    
    fileprivate var isAdvertised = false
    
    open var queueLength: Int
    open var subscribeHandler: ROSHandler?
    open var throttleRate: Int
    open var topic: String
    open var type: String
    
    public init(topic: String, type: String, queueLength: Int = 10, throttleRate: Int = 0) {
        self.queueLength = queueLength
        self.throttleRate = throttleRate
        self.topic = topic
        self.type = type
        super.init()
    }
    
    open func subscribe(_ handler: ROSHandler) {
        subscribeHandler = handler
        let message: [String: AnyObject] = [
            "op": "subscribe" as AnyObject,
            "topic": topic as AnyObject,
            "type": type as AnyObject,
            "throttle_rate": throttleRate as AnyObject,
            "queue_length": queueLength as AnyObject,
        ]
        ROS.sharedInstance.registerSubscriber(self)
        ROS.sharedInstance.send(ROS.objectToJSONString(message))
    }
    
    open func unsubscribe() {
        subscribeHandler = nil
        let message: [String: AnyObject] = [
            "op": "unsubscribe" as AnyObject,
            "topic": topic as AnyObject
        ]
        ROS.sharedInstance.unregisterSubscriber(self)
        ROS.sharedInstance.send(ROS.objectToJSONString(message))
    }
    
    open func advertise() {
        if isAdvertised {
            return
        }
        let message: [String: AnyObject] = [
            "op": "advertise" as AnyObject,
            "topic": topic as AnyObject,
            "type": type as AnyObject,
        ]
        ROS.sharedInstance.send(ROS.objectToJSONString(message))
        isAdvertised = true
    }
    
    open func unadvertise() {
        if !isAdvertised {
            return
        }
        let message: [String: AnyObject] = [
            "op": "unadvertise" as AnyObject,
            "topic": topic as AnyObject
        ]
        ROS.sharedInstance.send(ROS.objectToJSONString(message))
        isAdvertised = false
    }
    
    open func publish(_ msg: [String: AnyObject]) {
        if !isAdvertised {
            advertise()
        }
        let message: [String: AnyObject] = [
            "op": "publish" as AnyObject,
            "topic": topic as AnyObject,
            "msg": msg as AnyObject
        ]
        if topic == "/needybot/msg/response" {
            NB.log("publishing: \(message.description)")
        }
        ROS.sharedInstance.send(ROS.objectToJSONString(message))
    }
}
