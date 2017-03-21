//
//  NBDebugView.swift
//  NBFace
//
//  Created by David Glivar on 3/17/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation
import UIKit

class NBDebugView: NBView {
    
    let outline = CAShapeLayer()
    let crosshair = CAShapeLayer()
    
    convenience init() {
        self.init(frame: NB.FRAME)
        
        isUserInteractionEnabled = false
        
        let crosshairPath = UIBezierPath()
        crosshairPath.move(to: CGPoint(x: NB.FRAME.width * 0.5, y: 0))
        crosshairPath.addLine(to: CGPoint(x: NB.FRAME.width * 0.5, y: NB.FRAME.height))
        crosshairPath.move(to: CGPoint(x: 0, y: NB.FRAME.height * 0.5))
        crosshairPath.addLine(to: CGPoint(x: NB.FRAME.width, y: NB.FRAME.height * 0.5))
        
        crosshair.path = crosshairPath.cgPath
        crosshair.strokeColor = UIColor.red.cgColor
        
        outline.path = NBShape.createPath(NBShape.Debug.Outline).cgPath
        outline.backgroundColor = UIColor(0, 0, 0, 0.2).cgColor
        outline.strokeColor = UIColor.white.cgColor
        outline.fillColor = UIColor.clear.cgColor
        
        outline.transform = CATransform3DScale(outline.transform, 0.5, 0.5, 0)
        
        outline.frame.origin.y = NB.FRAME.height * 0.5 - NBShape.sizeOfShape(NBShape.Debug.Outline).height * 0.25
        
        layer.addSublayer(outline)
        layer.addSublayer(crosshair)
    }
}
