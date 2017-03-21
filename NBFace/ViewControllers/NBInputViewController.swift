//
//  NBInputViewController.swift
//  NBFace
//
//  Created by Nate Horstmann on 7/15/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation
import UIKit

class NBInputViewController: UIViewController {
    
    fileprivate var confirmationView: NBConfirmationView!
    // TODO: add other kinds of input views
    fileprivate var currentView: NBInputView?
    
    var isShowing = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func loadView() {
        view = UIView()
        view.frame = UIScreen.main.bounds
        view.backgroundColor = NB.Colors.UIBackground
        
        confirmationView = NBConfirmationView()
        
        view.addSubview(confirmationView)
        
        hide()
    }
    
    func setInputType(_ inputType: NB.InputType, withData data: [String: AnyObject]? = nil) {
        switch inputType {
            case .Confirm:
                currentView = confirmationView
                confirmationView.show(withData: data)
            // TODO: add other kinds of input views
            default:
                NB.log("Unable to find inputType" + inputType.rawValue)
        }
    }
    
    func show() {
        view.isHidden = false
        isShowing = true
    }
    
    func hide() {
        if let currentView = currentView {
            currentView.hide()
        }
        
        view.isHidden = true
        isShowing = false
    }    
}
