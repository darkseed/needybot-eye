//
//  IrisOverlayPath.swift
//  NBEyeAnimation
//
//  Created by Nate Horstmann on 7/11/16.
//  Copyright © 2016 Nate Horstmann. All rights reserved.
//

import Foundation
import UIKit

class IrisOverlayPath: UIBezierPath {
    override init() {
        super.init()
        
        move(to: CGPoint(x: 539.15, y: 538.43))
        addCurve(to: CGPoint(x: 539.19, y: 538.4), controlPoint1: CGPoint(x: 539.18, y: 538.41), controlPoint2: CGPoint(x: 539.19, y: 538.4))
        addLine(to: CGPoint(x: 180, y: 941.93))
        addCurve(to: CGPoint(x: 87.14, y: 833.73), controlPoint1: CGPoint(x: 144.5, y: 910.17), controlPoint2: CGPoint(x: 113.23, y: 873.79))
        addCurve(to: CGPoint(x: 539.15, y: 538.43), controlPoint1: CGPoint(x: 163.18, y: 786.62), controlPoint2: CGPoint(x: 534.57, y: 541.45))
        addLine(to: CGPoint(x: 827.57, y: 83.06))
        addCurve(to: CGPoint(x: 1079.55, y: 539.66), controlPoint1: CGPoint(x: 978.97, y: 178.65), controlPoint2: CGPoint(x: 1079.55, y: 347.4))
        addCurve(to: CGPoint(x: 1063.13, y: 672.18), controlPoint1: CGPoint(x: 1079.55, y: 585.39), controlPoint2: CGPoint(x: 1073.84, y: 629.78))
        addLine(to: CGPoint(x: 539.19, y: 538.4))
        close()
        move(to: CGPoint(x: 378.4, y: 24.54))
        addLine(to: CGPoint(x: 539.19, y: 538.4))
        addLine(to: CGPoint(x: 489.7, y: 2.33))
        addCurve(to: CGPoint(x: 378.4, y: 24.54), controlPoint1: CGPoint(x: 451.3, y: 5.86), controlPoint2: CGPoint(x: 414.05, y: 13.39))
        close()
        move(to: CGPoint(x: 277.3, y: 68.03))
        addCurve(to: CGPoint(x: 59.64, y: 292.86), controlPoint1: CGPoint(x: 184.43, y: 119.81), controlPoint2: CGPoint(x: 108.43, y: 198.17))
        addLine(to: CGPoint(x: 539.19, y: 538.4))
        addLine(to: CGPoint(x: 277.3, y: 68.03))
        close()
        move(to: CGPoint(x: 100.4, y: 451.12))
        addLine(to: CGPoint(x: 9.83, y: 436.82))
        addCurve(to: CGPoint(x: 0, y: 539.66), controlPoint1: CGPoint(x: 3.41, y: 470.11), controlPoint2: CGPoint(x: 0, y: 504.49))
        addCurve(to: CGPoint(x: 46.12, y: 758.19), controlPoint1: CGPoint(x: 0, y: 617.45), controlPoint2: CGPoint(x: 16.49, y: 691.38))
        addLine(to: CGPoint(x: 539.19, y: 538.4))
        addLine(to: CGPoint(x: 100.4, y: 451.12))
        close()
        move(to: CGPoint(x: 240.32, y: 988.7))
        addCurve(to: CGPoint(x: 303.43, y: 1024.95), controlPoint1: CGPoint(x: 260.44, y: 1002.14), controlPoint2: CGPoint(x: 281.52, y: 1014.26))
        addLine(to: CGPoint(x: 539.19, y: 538.4))
        addLine(to: CGPoint(x: 240.32, y: 988.7))
        close()
        move(to: CGPoint(x: 408.04, y: 1063.1))
        addCurve(to: CGPoint(x: 539.78, y: 1079.32), controlPoint1: CGPoint(x: 450.21, y: 1073.68), controlPoint2: CGPoint(x: 494.33, y: 1079.32))
        addCurve(to: CGPoint(x: 649.56, y: 1068.14), controlPoint1: CGPoint(x: 577.4, y: 1079.32), controlPoint2: CGPoint(x: 614.11, y: 1075.46))
        addCurve(to: CGPoint(x: 539.19, y: 538.4), controlPoint1: CGPoint(x: 621.64, y: 946.54), controlPoint2: CGPoint(x: 539.19, y: 538.4))
        addLine(to: CGPoint(x: 408.04, y: 1063.1))
        close()
        move(to: CGPoint(x: 739.27, y: 1041.25))
        addLine(to: CGPoint(x: 539.19, y: 538.4))
        addLine(to: CGPoint(x: 705.69, y: 1053.3))
        addCurve(to: CGPoint(x: 739.27, y: 1041.25), controlPoint1: CGPoint(x: 717.05, y: 1049.64), controlPoint2: CGPoint(x: 728.26, y: 1045.63))
        close()
        move(to: CGPoint(x: 881.89, y: 957.08))
        addCurve(to: CGPoint(x: 1043.9, y: 732.85), controlPoint1: CGPoint(x: 953.72, y: 898.17), controlPoint2: CGPoint(x: 1010.05, y: 821.08))
        addLine(to: CGPoint(x: 539.19, y: 538.4))
        addLine(to: CGPoint(x: 881.89, y: 957.08))
        close()
        move(to: CGPoint(x: 539.78, y: 0))
        addCurve(to: CGPoint(x: 538.58, y: 0.02), controlPoint1: CGPoint(x: 539.38, y: 0), controlPoint2: CGPoint(x: 538.98, y: 0.01))
        addLine(to: CGPoint(x: 539.19, y: 538.4))
        addLine(to: CGPoint(x: 690.34, y: 21.3))
        addCurve(to: CGPoint(x: 539.78, y: 0), controlPoint1: CGPoint(x: 642.55, y: 7.45), controlPoint2: CGPoint(x: 592.04, y: 0))
        close()
        move(to: CGPoint(x: 539.78, y: 0))
        usesEvenOddFillRule = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

