//
//  NBEyeViewController.swift
//  NBFace
//
//  Created by Nate Horstmann on 7/15/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation
import UIKit

class NBEyeViewController: UIViewController {
    
    fileprivate var eyeView: NBEyeAnimationView!
    
    fileprivate var isActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func loadView() {
        view = UIView()
        view.frame = UIScreen.main.bounds
        eyeView = NBEyeAnimationView()
        
        view.addSubview(eyeView)
    }
    
    func activate() {
        guard !isActive else {
            return
        }
        
        isActive = true
        
        // start eye animation updates
        eyeView.start()
    }
    
    func deactivate() {
        guard isActive else {
            return
        }

        isActive = false
        
        // stop eye animation updates
        eyeView.stop()
    }

    func playEmotion(_ eyeEmotion: NB.EyeEmotion) {
        activate()
        
        eyeView.playEmotion(eyeEmotion)
    }
}
