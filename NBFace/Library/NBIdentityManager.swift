//
//  NBIdentifier.swift
//  NBFace
//
//  Created by David Glivar on 8/13/15.
//  Copyright (c) 2015 Wieden+Kennedy. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class NBIdentityManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    static var _defaultManager: NBIdentityManager?
    static func defaultManager() -> NBIdentityManager {
        if let manager = _defaultManager {
            return manager
        }
        _defaultManager = NBIdentityManager()
        return _defaultManager!
    }
    
    fileprivate enum Stack {
        case detection, preview
    }
    
    fileprivate let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue", attributes: [])
    
    fileprivate var detector: CIDetector?
    fileprivate var detectionHandlers = [NBHandler]()
    fileprivate var device: AVCaptureDevice?
    fileprivate var deviceInput: AVCaptureDeviceInput?
    fileprivate var previewHandlers = [NBHandler]()
    fileprivate var session: AVCaptureSession?
    fileprivate var videoDataOutput: AVCaptureVideoDataOutput?
    
    override init() {
        super.init()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            setupAVCapture()
            detector = CIDetector(
                ofType: CIDetectorTypeFace,
                context: CIContext(options: [kCIContextUseSoftwareRenderer: true]),
                options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            )
        }
    }
    
    // MARK: Private methods
    
    fileprivate func processFeatures(_ features: [CIFeature], image: CGImage, videoRect: CGRect) {
        let angle = CGFloat(-0.5 * M_PI)
        let uiimage = UIImage(cgImage: image)
        UIGraphicsBeginImageContext(CGSize(width: uiimage.size.height, height: uiimage.size.width))
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.scaleBy(x: -1, y: 1)
        ctx?.translateBy(x: -uiimage.size.height, y: uiimage.size.width)
        ctx?.rotate(by: angle)
        uiimage.draw(at: CGPoint(x: 0, y: 0))
        let out = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        runStack(Stack.preview, payload: [
            "image": out
        ])
        
        let outRect = CGRect(x: 0, y: 0, width: (out?.size.width)!, height: (out?.size.height)!)
        
        if features.count > 0 {
            
            // Filter features to find the one with the largest size
            var focusedFeature: CIFeature?
            for feature in features {
                if focusedFeature == nil {
                    focusedFeature = feature
                    continue
                }
                if feature.bounds.size.width > focusedFeature?.bounds.size.width {
                    focusedFeature = feature
                }
            }
            
            // Apply normalization tranformation
            if let rect = focusedFeature?.bounds {
                var transform = CGAffineTransform(translationX: 0, y: videoRect.width)
                transform = transform.scaledBy(x: -1, y: -1)
                transform = transform.rotated(by: -angle)
                let newRect = rect.applying(transform)
                
                // Crop image
                let clone = out?.cgImage?.copy()
                let croppedImage = clone?.cropping(to: newRect)
                
                if croppedImage != nil {
                    let img = UIImage(cgImage: croppedImage!)
                    // Run detection stack
                    let payload: [String: Any] = [
                        "feature": newRect,
                        "videoRect": outRect,
                        "croppedImage": img,
                        "image": out,
                    ]
                    runStack(Stack.detection, payload: payload)
                }
            }
        }
    }
    
    fileprivate func runStack(_ stack: Stack, payload: [String: Any]) {
        var handlers: [NBHandler]
        switch stack {
        case .detection:
            handlers = detectionHandlers
            
        case .preview:
            handlers = previewHandlers
        }
        
        for handler in handlers {
            handler.handle(payload)
        }
    }
    
    fileprivate func setupAVCapture() {
        var err: NSError? = nil
        
        session = AVCaptureSession()
        guard let session = session else {
            return
        }
        
        session.sessionPreset = AVCaptureSessionPresetMedium
        
        let devices = AVCaptureDevice.devices()
        for d in devices! {
            guard let d = d as? AVCaptureDevice else {
                continue
            }
            if d.hasMediaType(AVMediaTypeVideo) && d.position == .front {
                device = d
            }
        }
        
        guard let device = device else {
            return
        }
        
        if device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = CGPoint(
                x: UIScreen.main.bounds.size.width * 0.5,
                y: UIScreen.main.bounds.size.height * 0.5
            )
            device.focusMode = AVCaptureFocusMode.continuousAutoFocus
        }
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            err = error
            deviceInput = nil
        }
        if err != nil {
            NB.log("Error: \(err?.userInfo)")
            return
        }
        
        guard let deviceInput = deviceInput else {
            return
        }
        
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }
        
        videoDataOutput = AVCaptureVideoDataOutput()
        guard let videoDataOutput = videoDataOutput else {
            return
        }
        
        guard let rgbOutputSettings = NSDictionary(
                object: NSNumber(value: kCMPixelFormat_32BGRA as UInt32),
                forKey: kCVPixelBufferPixelFormatTypeKey as String as String as NSCopying
            ) as? [AnyHashable: Any] else {
                return
        }
        videoDataOutput.videoSettings = rgbOutputSettings
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        
        videoDataOutput.connection(withMediaType: AVMediaTypeVideo).isEnabled = true
        
        start()
    }
    
    // MARK: Public API
    
    func addDetectionHandler(_ handler: NBHandler) {
        detectionHandlers.append(handler)
    }
    
    func addPreviewHandler(_ handler: NBHandler) {
        previewHandlers.append(handler)
    }
    
    func removeDetectionHandler(_ handler: NBHandler) -> Bool {
        if let index = detectionHandlers.index(of: handler) {
            detectionHandlers.remove(at: index)
            return true
        }
        return false
    }
    
    func removePreviewHandler(_ handler: NBHandler) -> Bool {
        if let index = previewHandlers.index(of: handler) {
            previewHandlers.remove(at: index)
            return true
        }
        return false
    }
    
    func start() {
        guard let session = session else {
            return
        }
        session.startRunning()
    }
    
    func stop() {
        guard let session = session else {
            return
        }
        session.stopRunning()
    }
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate implementation
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let detector = detector,
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let pixelBuffer = imageBuffer as CVPixelBuffer
        let image = CIImage(cvPixelBuffer: pixelBuffer)
        let ctx = CIContext(options: nil)
        let ctxRect = CGRect(
            x: 0, y: 0,
            width: CGFloat(CVPixelBufferGetWidth(pixelBuffer)),
            height: CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        )
        let ctxImage = ctx.createCGImage(image, from: ctxRect)
        let imageOptions = [
            CIDetectorImageOrientation: NSNumber(value: 8 as Int) // upside-down constant
        ]
        let features = detector.features(in: image, options: imageOptions)
        guard let desc = CMSampleBufferGetFormatDescription(sampleBuffer) else {
            return
        }
        
        let cleanAperture: CGRect = CMVideoFormatDescriptionGetCleanAperture(desc, false)
        
        DispatchQueue.main.async { [weak self] in
            self?.processFeatures(features , image: ctxImage!, videoRect: cleanAperture)
        }
    }
}
