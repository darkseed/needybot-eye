//
//  ROS.swift
//  ROSLibSwift
//
//  Created by David Glivar on 2/15/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation
import SocketRocket

open class ROS: NSObject, SRWebSocketDelegate {
    
    open static let sharedInstance = ROS()
    
    fileprivate var connectCallback: ROSHandler?
    fileprivate var connectTimer: Timer?
    fileprivate var isConnected = false
    fileprivate var queue = [NSString]()
    fileprivate var services = [ROSService]()
    fileprivate var socket: SRWebSocket?
    fileprivate var subscribers = [ROSTopic]()
    fileprivate var url: String?
    fileprivate var nsurl: URL?
    
    open static func fromJSON(_ jsonString: String) -> [String: AnyObject]? {
        guard let data = jsonString.data(using: String.Encoding.utf8) else {
            return nil
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            return nil
        }
        return json as? [String: AnyObject]
    }
    
    open static func template(_ key: String, _ value: String, _ isRaw: Bool = false) -> String {
        if isRaw {
            return "\"\(key)\": \(value)"
        }
        return "\"\(key)\": \"\(value)\""
    }
    
    open static func objectToJSONString(_ object: [String: AnyObject]) -> String {
        var arr: [String] = []
        
        for (k, v) in object {
            // handle nested objects
            if let val = v as? [String: AnyObject] {
                let s = template(k, objectToJSONString(val), true)
                arr.append(s)
                continue
            }
            
            if let val = v as? [[String: AnyObject]] {
                var a = [String]()
                for n in val {
                    a.append(objectToJSONString(n))
                }
                arr.append("\"\(k)\": [\(a.joined(separator: ","))]")
                continue
            }
            
            // handle array types
            if let val = v as? [AnyObject] {
                var s: String = ""
                if let val = val as? [String] {
                    var a = [String]()
                    for n in val {
                        a.append("\"\(n)\"")
                    }
                    s = "\"\(k)\": [\(a.joined(separator: ","))]"
                } else {
                    s = template(k, "\(val)", true)
                }
                arr.append(s)
                continue
            }
            
            // handle strings
            if let val = v as? String {
                arr.append(template(k, val))
                continue
            }
            
            // handle floats and ints
            if let val = v as? Float64 {
                let isInt = String(describing: v) != String(val)
                if isInt {
                    arr.append(template(k, "\(Int(val))", true))
                    continue
                }
                arr.append(template(k, "\(val)", true))
                continue
            }
            
            // handle booleans
            if let val = v as? Bool {
                arr.append(template(k, "\(val)", true))
                continue
            }
        }
        
        let joined = arr.joined(separator: ", ")
        return "{ \(joined) }"
    }
    
    open func connect(_ url: String, _ callback: ROSHandler? = nil) /*throws*/ {
        guard let nsurl = URL(string: url) else {
            NSLog("Invalid connection url")
            return
        }
        if let cb = callback {
            connectCallback = cb
        }
        NB.log("Preparing to connect to ROS on url \(url) ...")
        self.nsurl = nsurl
        self.url = url
        connectTimer = Timer.schedule(repeatInterval: 5.0) { timer in
            if !self.isConnected {
                NSLog("ROS is not connected, retrying in 5 seconds...")
                self.socket = SRWebSocket(url: nsurl)
                self.socket?.delegate = self
                self.socket?.open()
            } else {
                timer?.invalidate()
            }
        }
    }
    
    open func close() {
        socket?.close()
    }
    
    open func registerService(_ service: ROSService) -> Bool {
        guard let _ = services.index(of: service) else {
            services.append(service)
            return true
        }
        return false
    }
    
    open func registerSubscriber(_ topic: ROSTopic) -> Bool {
        guard let _ = subscribers.index(of: topic) else {
            subscribers.append(topic)
            return true
        }
        return false
    }
    
    open func send(_ message: String) {
        let message = NSString(string: message)
        if !isConnected {
            queue.append(message)
            return
        }
        socket?.send(message)
    }
    
    open func sendNSString(_ message: NSString) {
        if !isConnected {
            queue.append(message)
            return
        }
        socket?.send(message)
    }
    
    open func unregisterService(_ service: ROSService) -> Bool {
        guard let idx = services.index(of: service) else {
            return false
        }
        services.remove(at: idx)
        return true
    }
    
    open func unregisterSubscriber(_ topic: ROSTopic) -> Bool {
        guard let idx = subscribers.index(of: topic) else {
            return false
        }
        subscribers.remove(at: idx)
        return true
    }
    
    open func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        guard let message = message as? String,
            let msg = ROS.fromJSON(message) else {
                return
        }
        if let topicName = msg["topic"] as? String {
            for subscriber in subscribers {
                if subscriber.topic != topicName {
                    continue
                }
                subscriber.subscribeHandler?.handle(msg)
            }
        } else if let serviceName = msg["service"] as? String {
            guard let id = msg["id"] as? String else {
                NSLog("No id in service response")
                return
            }
            for service in services {
                if service.service != serviceName || service.id != id {
                    continue
                }
                service.serviceCallback?.handle(msg)
                unregisterService(service)
            }
        }
    }
    
    open func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        NSLog("ROSLibSwift connected to \(url!)")
        connectTimer?.invalidate()
        isConnected = true
        connectCallback?.handle([:])
        for message in queue {
            sendNSString(message)
        }
    }
    
    open func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        NSLog("ROS disconnected with code: \(code), reason: \(reason)")
        guard let url = url else { return }
        NSLog("Attempting to reconnect...")
        connectTimer?.invalidate()
        isConnected = false
        connect(url)
    }
}
