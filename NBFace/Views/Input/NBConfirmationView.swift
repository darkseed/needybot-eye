//
//  NBConfirmationView.swift
//  NBFace
//
//  Created by Nate Horstmann on 7/15/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation

class NBConfirmationView: NBInputView, NBInputViewConfigurable {
    
    fileprivate let textContainer = UIView()
    fileprivate let header = UILabel()
    fileprivate let subheader = UILabel()
    fileprivate let yesButton = NBIconButton(withIconID: "yes")!
    fileprivate let noButton = NBIconButton(withIconID: "no")!
    fileprivate let replayButton = NBIconButton(withIconID: "replay")!
    
    fileprivate let pad: CGFloat = 30
    fileprivate let textShowingButtonsY: CGFloat = 25
    fileprivate let lineHeight: CGFloat = 38
    
    fileprivate let responseTopic = ROSTopic(topic: "/needybot/msg/response", type: "needybot/FaceResponse")
    
    var headerText: String? {
        get {
            return header.text
        }
        set {
            header.text = newValue
        }
    }
    var subheaderText: String? {
        get {
            return subheader.text
        }
        set {
            subheader.text = newValue
        }
    }
    
    convenience init() {
        self.init(frame: NB.FRAME)
        
        textContainer.frame.centerInRectMut(NB.FRAME, xOffset: 0, yOffset: -200)
        
        applyTextStyles(header, 34)
        applyTextStyles(subheader, 18)
        subheader.frame.origin.y = lineHeight
        
        replayButton.frame.centerInRectMut(NB.FRAME, xOffset: 0, yOffset: replayButton.radius + 165)
        
        addSubview(textContainer)
        textContainer.addSubview(header)
        textContainer.addSubview(subheader)
        
        addSubview(yesButton)
        addSubview(noButton)
        addSubview(replayButton)
        
        addResponses()
        
        hide();
    }
    
    // MARK: - Private methods
    
    fileprivate func addResponses() {
        replayButton.addHandler(NBHandler() { _ in
            ROSTopic(topic: "/needybot/msg/replay", type: "std_msgs/Empty").publish([:])
        })
        
        yesButton.addHandler(NBHandler() { _ in
            self.handleResponse(true)
        })
        
        noButton.addHandler(NBHandler() { _ in
            self.handleResponse(false)
        })
    }
    
    func handleResponse(_ success: Bool) {
        // keep response from being sent more than once if multiple taps
        // are triggered
        guard isActive else {
            return
        }
        
        deactivate()
        let response = (success) ? NBFaceResponseMsg.Success() : NBFaceResponseMsg.Failure()
        responseTopic.publish(response.asMsg())
    }
    
    fileprivate func applyTextStyles(_ label: UILabel, _ fontsize: CGFloat) {
        label.textColor = NB.Colors.OffWhite
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = UIFont(name: NB.Font.MavenProBold.rawValue, size: fontsize)
        label.frame =  CGRect(
            x: -frame.width * 0.5,
            y: 0,
            width: frame.width,
            height: lineHeight
        )
    }
    
    // MARK: - Public API
    
    /**
     Implements NBInputViewConfigurable protocol
    */
    func show(withData data: [String: AnyObject]?) {
        if let data = data {
            // NB.log("NBConfirmation view show withData: ")
            // NB.log(data.description)

            if let title = data["title"] as? String {
                header.text = title
                showText()
            }
            
            if let subtitle = data["subtitle"] as? String {
                subheader.text = subtitle
            }
        }
        
        super.show()        
    }
    
    override func hide() {
        super.hide()
        hideText()
    }
    
    func hideText() {
        header.isHidden = true
        subheader.isHidden = true
        header.text = ""
        subheader.text = ""
        
        // return yes/no buttons to center
        let radius = yesButton.radius
        yesButton.frame.centerInRectMut(NB.FRAME, xOffset: -(radius + pad), yOffset: 0)
        noButton.frame.centerInRectMut(NB.FRAME, xOffset: radius + pad, yOffset: 0)
    }
    
    func showText() {
        header.isHidden = false
        subheader.isHidden = false
        
        // shift yes/no buttons down to accommodate text
        let radius = yesButton.radius
        yesButton.frame.centerInRectMut(NB.FRAME, xOffset: -(radius + pad), yOffset: 25)
        noButton.frame.centerInRectMut(NB.FRAME, xOffset: radius + pad, yOffset: 25)
    }
}
