//
//  NBBlinkView.swift
//  NBFace
//
//  Created by David Glivar on 9/4/15.
//  Copyright (c) 2015 Wieden+Kennedy. All rights reserved.
//

import Async
import Foundation
import UIKit

class NBBlinkView: NBView {
    
    let color = NB.Colors.Background.cgColor
//    let color = UIColor(255, 0, 0, 0.15).CGColor
    let toplid = CAShapeLayer()
    let botlid = CAShapeLayer()
    let duration = 0.25
    
    let botPathStart: UIBezierPath = {
        let p = UIBezierPath()
        let c = NB.FRAME.getCenter()
        let yoff = c.x * 0.5
        let cp1 = CGPoint(x: NB.FRAME.width * 0.375, y: c.y + c.x + yoff)
        let cp2 = CGPoint(x: NB.FRAME.width * 0.625, y: c.y + c.x + yoff)
        
        p.move(to: CGPoint(x: 0, y: c.y + yoff))
        p.addLine(to: CGPoint(x: 10, y: c.y + yoff))
        p.addCurve(to: CGPoint(x: NB.FRAME.width - 10, y: c.y + yoff), controlPoint1: cp1, controlPoint2: cp2)
        p.addLine(to: CGPoint(x: NB.FRAME.width, y: c.y + yoff))
        p.addLine(to: CGPoint(x: NB.FRAME.width, y: c.y * 2))
        p.addLine(to: CGPoint(x: NB.FRAME.origin.x, y: c.y * 2))
        p.close()
        
        return p
    }()
    
    let botPathEnd: UIBezierPath = {
        let p = UIBezierPath()
        let c = NB.FRAME.getCenter()
        let cp1 = CGPoint(x: NB.FRAME.width * 0.375, y: c.y)
        let cp2 = CGPoint(x: NB.FRAME.width * 0.625, y: c.y)
        
        p.move(to: CGPoint(x: 0, y: c.y))
        p.addLine(to: CGPoint(x: 10, y: c.y))
        p.addCurve(to: CGPoint(x: NB.FRAME.width - 10, y: c.y), controlPoint1: cp1, controlPoint2: cp2)
        p.addLine(to: CGPoint(x: NB.FRAME.width, y: c.y))
        p.addLine(to: CGPoint(x: NB.FRAME.width, y: c.y * 2))
        p.addLine(to: CGPoint(x: NB.FRAME.origin.x, y: c.y * 2))
        p.close()
        
        return p
    }()
    
    let topPathStart: UIBezierPath = {
        let p = UIBezierPath()
        let c = NB.FRAME.getCenter()
        let yoff: CGFloat = c.x * 0.5
        let cp1 = CGPoint(x: NB.FRAME.width * 0.375, y: c.y - c.x - yoff)
        let cp2 = CGPoint(x: NB.FRAME.width * 0.625, y: c.y - c.x - yoff)
        
        p.move(to: CGPoint(x: 0, y: c.y - yoff))
        p.addLine(to: CGPoint(x: 10, y: c.y - yoff))
        p.addCurve(to: CGPoint(x: NB.FRAME.width - 10, y: c.y - yoff), controlPoint1: cp1, controlPoint2: cp2)
        p.addLine(to: CGPoint(x: NB.FRAME.width, y: c.y - yoff))
        p.addLine(to: CGPoint(x: NB.FRAME.width, y: NB.FRAME.origin.y))
        p.addLine(to: CGPoint(x: NB.FRAME.origin.x, y: NB.FRAME.origin.y))
        p.close()
        
        return p
    }()
    
    let topPathEnd: UIBezierPath = {
        let p = UIBezierPath()
        let c = NB.FRAME.getCenter()
        let cp1 = CGPoint(x: NB.FRAME.width * 0.375, y: c.y)
        let cp2 = CGPoint(x: NB.FRAME.width * 0.625, y: c.y)
        
        p.move(to: CGPoint(x: 0, y: c.y))
        p.addLine(to: CGPoint(x: 10, y: c.y))
        p.addCurve(to: CGPoint(x: NB.FRAME.width - 10, y: c.y), controlPoint1: cp1, controlPoint2: cp2)
        p.addLine(to: CGPoint(x: NB.FRAME.width, y: c.y))
        p.addLine(to: CGPoint(x: NB.FRAME.width, y: NB.FRAME.origin.y))
        p.addLine(to: CGPoint(x: NB.FRAME.origin.x, y: NB.FRAME.origin.y))
        p.close()
        
        return p
    }()
    
    convenience init() {
        self.init(frame: NB.FRAME)
        isUserInteractionEnabled = false
        frame.origin.y += abs(NB.FRAME.origin.y)
        backgroundColor = UIColor.clear
        
        toplid.fillColor = color
        toplid.strokeColor = color
        toplid.path = topPathStart.cgPath
        
        botlid.fillColor = color
        botlid.strokeColor = color
        botlid.path = botPathStart.cgPath
        
        layer.addSublayer(toplid)
        layer.addSublayer(botlid)
    }
    
    fileprivate func close() {
        let topCloseAnimation = CABasicAnimation(keyPath: "path")
        topCloseAnimation.timingFunction = UIView.function(withType: CustomTimingFunctionQuadIn)
        topCloseAnimation.duration = duration * 0.5
        topCloseAnimation.fromValue = topPathStart.cgPath
        topCloseAnimation.toValue = topPathEnd.cgPath
        toplid.add(topCloseAnimation, forKey: "topCloseAnimation")
        
        let botCloseAnimation = CABasicAnimation(keyPath: "path")
        botCloseAnimation.timingFunction = UIView.function(withType: CustomTimingFunctionQuadInOut)
        botCloseAnimation.duration = duration * 0.5
        botCloseAnimation.fromValue = botPathStart.cgPath
        botCloseAnimation.toValue = botPathEnd.cgPath
        botlid.add(botCloseAnimation, forKey: "botCloseAnimation")
        
        toplid.path = topPathEnd.cgPath
        botlid.path = botPathEnd.cgPath
    }
    
    fileprivate func open() {
        let topCloseAnimation = CABasicAnimation(keyPath: "path")
        topCloseAnimation.timingFunction = UIView.function(withType: CustomTimingFunctionQuadIn)
        topCloseAnimation.duration = duration
        topCloseAnimation.fromValue = topPathEnd.cgPath
        topCloseAnimation.toValue = topPathStart.cgPath
        toplid.add(topCloseAnimation, forKey: "topCloseAnimation")
        
        let botCloseAnimation = CABasicAnimation(keyPath: "path")
        botCloseAnimation.timingFunction = UIView.function(withType: CustomTimingFunctionQuadInOut)
        botCloseAnimation.duration = duration
        botCloseAnimation.fromValue = botPathEnd.cgPath
        botCloseAnimation.toValue = botPathStart.cgPath
        botlid.add(botCloseAnimation, forKey: "botCloseAnimation")
        
        toplid.path = topPathStart.cgPath
        botlid.path = botPathStart.cgPath
    }
    
    func blink(onClosed closedCallback: @escaping NB.Callback = {}, onOpen openCallback: @escaping NB.Callback = {}) {
        // cancel any ongoing blink
        
        close()
        Async.main(after: duration) {
            closedCallback()
        }.main {
            self.open()
        }.main(after: duration) {
            openCallback()
        }
    }
 }
