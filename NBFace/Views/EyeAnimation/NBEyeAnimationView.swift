//
//  NBEyeAnimationView.swift
//  NBFace
//
//  Created by Nate Horstmann on 7/15/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation
import UIKit

class NBEyeAnimationView: UIView {
    
    fileprivate var displayLink: CADisplayLink!
    
    var container: CALayer!
    var eyeLayer: CALayer!
    var eyeMaskLayer: CAShapeLayer!
    var scleraDiffuseLayer: CAShapeLayer!
    var corneaLayer: CALayer!
    var corneaMaskLayer: CAShapeLayer!
    var irisDiffuseLayer: CAShapeLayer!
    var irisOverlayLayer: CAShapeLayer!
    var pupilLayer: CAShapeLayer!
    var eyelidUpperLayer: CAShapeLayer!
    var eyelidLowerLayer: CAShapeLayer!
    
    var corneaScale: CGFloat = 1.0
    var pupilScale: CGFloat = 1.0

    var lookAtPoint = CGPoint(x: 0.0, y: 0.0)
    var irisSpinAngle: CGFloat = 0.0;
    var irisSpinSpeed: CGFloat = 0.005
    
    var animationsDict = [String: NBEyeAnimation]()
    
    struct EyeColors {
        static let Sclera = UIColor(hue: 0.167, saturation: 0.027, brightness: 1, alpha: 1)
        static let Pupil = UIColor(hue: 0.5, saturation: 0.004, brightness: 0.201, alpha: 1)
        static let IrisIdle = UIColor(red: 0.4, green: 0.816, blue: 0.855, alpha: 1)
        static let IrisHappy = UIColor(red: 0.157, green: 0.933, blue: 0.725, alpha: 1)
        static let IrisSad = UIColor(red: 0.431, green: 0.584, blue: 0.906, alpha: 1)
        static let IrisOverlay = UIColor(white: 0, alpha: 0.08)
        static let Eyelid = UIColor(white: 0.478, alpha: 1)
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        
        backgroundColor = UIColor.clear
        // backgroundColor = UIColor(red: 0.0, green: 0.25, blue: 0.0, alpha: 1.0)
        
        corneaScale = NBAnimation.EyeValues.ScaleCorneaIdle
        pupilScale = NBAnimation.EyeValues.ScalePupilIdle
        
        initLayers()
        
        // Scale container so that eye fits within target bounds.
        // Scaling the container rather than the eye layer leaves
        // eye at it's normalized scale for doing animation.
        let resizedEyeFrame = NB.ResizingBehavior.aspectFit.apply(
            rect: CGRect(x: 0, y: 0, width: eyeLayer.bounds.width, height: eyeLayer.bounds.height),
            target: CGRect(x: 0, y: 0, width: frame.width * 0.5, height: frame.height)
        )
        let resizedEyeScale = CGSize(
            width: resizedEyeFrame.width / eyeLayer.bounds.width,
            height: resizedEyeFrame.height / eyeLayer.bounds.height
        )
        container.transform = CATransform3DScale(container.transform, resizedEyeScale.width, resizedEyeScale.height, 1.0)
        
        initAnimations()
        
        // init display link
        displayLink = CADisplayLink(target: self, selector: #selector(self.update))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        displayLink.isPaused = true
        
        update()
//        animate01()
    }
    
    fileprivate func initLayers() {
        container = CALayer()
        container.bounds = bounds
        container.position = CGPoint(x: frame.width/2, y: frame.height/2)
        layer.addSublayer(container)
        
        let eyePath = EyePath()
        eyeLayer = CALayer()
        eyeMaskLayer = CAShapeLayer()
        eyeMaskLayer.fillColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor
        eyeMaskLayer.path = eyePath.cgPath
        eyeLayer.bounds = eyePath.bounds
        eyeLayer.position = CGPoint(x: container.bounds.width/2, y: container.bounds.height/2)
        eyeLayer.mask = eyeMaskLayer
        container.addSublayer(eyeLayer)

        scleraDiffuseLayer = CAShapeLayer()
        scleraDiffuseLayer.fillColor = EyeColors.Sclera.cgColor
        scleraDiffuseLayer.path = eyePath.cgPath
        eyeLayer.addSublayer(scleraDiffuseLayer)
        
        let corneaPath = CorneaPath()
        corneaLayer = CALayer()
        corneaLayer.bounds = corneaPath.bounds
        corneaLayer.position = CGPoint(x: 500, y: 500)
        corneaMaskLayer = CAShapeLayer()
        corneaMaskLayer.fillColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor
        corneaMaskLayer.path = corneaPath.cgPath
        corneaLayer.mask = corneaMaskLayer
        corneaLayer.transform = CATransform3DScale(corneaLayer.transform, corneaScale, corneaScale, 1.0)
        eyeLayer.addSublayer(corneaLayer)
        
        irisDiffuseLayer = CAShapeLayer()
        irisDiffuseLayer.fillColor = EyeColors.IrisIdle.cgColor
        irisDiffuseLayer.path = corneaPath.cgPath
        corneaLayer.addSublayer(irisDiffuseLayer)
        
        let irisOverlayPath = IrisOverlayPath()
        irisOverlayLayer = CAShapeLayer()
        irisOverlayLayer.fillColor = EyeColors.IrisOverlay.cgColor
        irisOverlayLayer.path = irisOverlayPath.cgPath
        irisOverlayLayer.bounds = irisOverlayPath.bounds
        irisOverlayLayer.position = CGPoint(x: 500, y: 500)
        corneaLayer.addSublayer(irisOverlayLayer)
        
        let pupilPath = PupilPath()
        pupilLayer = CAShapeLayer()
        pupilLayer.fillColor = EyeColors.Pupil.cgColor
        pupilLayer.path = pupilPath.cgPath
        pupilLayer.bounds = pupilPath.bounds
        pupilLayer.position = CGPoint(x: 500, y: 500)
        pupilLayer.transform = CATransform3DScale(pupilLayer.transform, pupilScale, pupilScale, 1.0)
        corneaLayer.addSublayer(pupilLayer)
        
        let highlightLayer = CAShapeLayer()
        let highlightOuterPath = UIBezierPath(ovalIn: CGRect(x: -292, y: -303, width: 584, height: 606))
        let highlightInnerPath = UIBezierPath(ovalIn: CGRect(x: -73, y: -73, width: 146, height: 146))
        let highlightOuterLayer = CAShapeLayer()
        let highlightInnerLayer = CAShapeLayer()
        highlightOuterLayer.fillColor = UIColor(white: 1.0, alpha: 0.15).cgColor
        highlightInnerLayer.fillColor = UIColor.white.cgColor
        highlightOuterLayer.path = highlightOuterPath.cgPath
        highlightInnerLayer.path = highlightInnerPath.cgPath
        highlightOuterLayer.bounds = highlightOuterPath.bounds
        highlightInnerLayer.bounds = highlightInnerPath.bounds
        highlightLayer.position = CGPoint(x: 844, y: 112);
        highlightLayer.addSublayer(highlightOuterLayer)
        highlightLayer.addSublayer(highlightInnerLayer)
        pupilLayer.addSublayer(highlightLayer)
        
        // eyelids
        let eyelidLayer = CALayer()
        eyelidUpperLayer = CAShapeLayer()
        eyelidLowerLayer = CAShapeLayer()
        eyelidUpperLayer.fillColor = EyeColors.Eyelid.cgColor
        eyelidLowerLayer.fillColor = EyeColors.Eyelid.cgColor
        eyelidUpperLayer.path = EyelidPaths.UpperIdleOpen.cgPath
        eyelidLowerLayer.path = EyelidPaths.LowerIdleOpen.cgPath
        eyelidUpperLayer.bounds = CGRect(x: 0, y: 0, width: 1000, height: 1000)
        eyelidLowerLayer.bounds = CGRect(x: 0, y: 0, width: 1000, height: 1000)
        eyelidLayer.addSublayer(eyelidUpperLayer)
        eyelidLayer.addSublayer(eyelidLowerLayer)
        eyelidLayer.position = CGPoint(x: 500, y: 500);
        eyeLayer.addSublayer(eyelidLayer)
    }
    
    func initAnimations() {
        animationsDict[NB.EyeEmotion.Idle.rawValue] = NBEyeIdle(animationView: self)
        animationsDict[NB.EyeEmotion.Happy.rawValue] = NBEyeHappy(animationView: self)
        animationsDict[NB.EyeEmotion.Sad.rawValue] = NBEyeSad(animationView: self)
    }
    
    func update() {
        irisSpinAngle += 0.005
        irisOverlayLayer.transform = CATransform3DRotate(irisOverlayLayer.transform, irisSpinSpeed , 0.0, 0.0, 1.0)  // 3D rotation around z-axis
    }
    
    func start() {
        displayLink.isPaused = false
    }
    
    func stop() {
        displayLink.isPaused = true
    }
    
    func idle() {
        // go into looping idle mode
    }
    
    func playEmotion(_ eyeEmotion: NB.EyeEmotion) {
        // pick animation based on emotion
        if let animation = animationsDict[eyeEmotion.rawValue] {
            // TODO: handle stopping and transitioning out existing animation
            animation.animate()
        } else {
            NB.log("No animation exists for key: " + eyeEmotion.rawValue)
            idle()
        }
    }
    
    static func getCorneaLookPosition(_ angle: CGFloat, withScale scale: CGFloat) -> CGPoint {
        let corneaHalfWidth = scale * 500
        var centerOffsetPos = CGPoint(x: 490 - corneaHalfWidth, y: 0)
        centerOffsetPos = centerOffsetPos.applying(CGAffineTransform(rotationAngle: angle))
        return CGPoint(x: 500 + centerOffsetPos.x, y: 500 + centerOffsetPos.y)
    }
}
