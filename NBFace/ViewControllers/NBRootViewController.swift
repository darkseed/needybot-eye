//
//  NBNewRootViewController.swift
//  NBFace
//
//  Created by Nate Horstmann on 7/14/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import Async


class NBRootViewController: UIViewController, UIGestureRecognizerDelegate {
    
    fileprivate let eyeController = NBEyeViewController()
    fileprivate let inputController = NBInputViewController()
    fileprivate let blinkView = NBBlinkView()
    
    fileprivate var currentInputType: NB.InputType?
    fileprivate var currentEmotion: NB.EyeEmotion?
    
    fileprivate var debug = true
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NBViewMachine.sharedInstance.root = self
        
        // start out playing idle animation
        setEyeEmotion(.Idle)
        
        // ------------------------------------------------
        // TODO: remove - testing only
        // ------------------------------------------------
        if debug {
            let debugView = NBDebugView()
            view.addSubview(debugView)
            
            setInputType(.Confirm, withData: [
                "title": "Confirmation Screen Title Here" as AnyObject,
                "subtitle": "Subtitle Here" as AnyObject
            ])
            
            tapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(NBRootViewController.handleTapGesture)
            )
            tapGestureRecognizer.delegate = self
            tapGestureRecognizer.delaysTouchesBegan = false
            tapGestureRecognizer.delaysTouchesEnded = false
            tapGestureRecognizer.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    override func loadView() {
        view = UIView()
        view.addSubview(eyeController.view)
        view.addSubview(inputController.view)
        view.addSubview(blinkView)
    }
    
    func setInputType(_ inputType: NB.InputType, withData data: [String: AnyObject]? = nil) {
        // NB.log("setInput inputType: " + inputType.rawValue)
        
        // make sure type is different
        guard inputType != currentInputType else {
            return
        }

        currentInputType = inputType
        
        blinkView.blink(
            onClosed: { [weak self] in
                self?.eyeController.deactivate()
                
                self?.inputController.setInputType((self?.currentInputType)!, withData: data)
                self?.inputController.show()
            }
        )
    }
    
    func setEyeEmotion(_ eyeEmotion: NB.EyeEmotion = .Idle) {
        // NB.log("setEyeEmotion eyeEmotion: " + eyeEmotion.rawValue)
        currentEmotion = eyeEmotion
        
        if (inputController.isShowing) {
            // if input showing blink to transition to eye
            blinkView.blink(
                onClosed: { [weak self] in
                    self?.inputController.hide()
                },
                onOpen: { [weak self] in
                    self?.eyeController.playEmotion(eyeEmotion)
                }
            )
        } else {
            // play emotion
            eyeController.playEmotion(eyeEmotion)
        }
    }
    
    func handleTapGesture() {
        // switch emotions

        switch currentEmotion! {
            case .Happy:
                setEyeEmotion(.Sad)
            case .Sad:
                setEyeEmotion(.Idle)
            case .Idle:
                setEyeEmotion(.Happy)
            default:
                setEyeEmotion(.Idle)
        }
    }
    
}
