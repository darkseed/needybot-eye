//
//  NBIconButton.swift
//  NBFace
//
//  Created by David Glivar on 4/5/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation
import UIKit

class NBIconButton: UIControl, NBManager {
    
    fileprivate let ANIMATION_DURATION: TimeInterval = 0.15
    fileprivate let ANNOTATION_OFFSET: CGFloat = 25.0
    
    fileprivate var _scale: CGFloat = 1.0
    fileprivate var shadowOffset: CGFloat = 6.0
    
    let annotationLabel = UILabel()
    let backView = NBView()
    let borderWidth: CGFloat
    let container = NBView()
    let iconView = UIImageView()
    let shadowView = NBView()
    
    var handlers = [NBHandler]()
    var icon: UIImage!
    
    // MARK: - Computed properties
    
    var annotation: String? {
        get {
            return annotationLabel.text
        }
        set {
            annotationLabel.frame.size.width = NB.FRAME.width
            annotationLabel.text = newValue
            if newValue == nil || newValue == "" {
                annotationLabel.isHidden = true
            } else {
                annotationLabel.isHidden = false
                if let labelSize = annotationLabel.attributedText?.size() {
                    annotationLabel.frame.size.width = labelSize.width
                } else {
                    annotationLabel.frame.size.width = frame.size.width
                }
                annotationLabel.frame.centerInRectMut(frame, xOffset: 0, yOffset: radius + ANNOTATION_OFFSET)
            }
        }
    }
    
    fileprivate var _fontSize: CGFloat = 21.0
    var fontSize: CGFloat {
        get {
            return _fontSize
        }
        set {
            _fontSize = newValue
            annotationLabel.font = UIFont(name: NB.Font.MavenProBold.rawValue, size: _fontSize)
            if let labelSize = annotationLabel.attributedText?.size() {
                annotationLabel.frame.size = CGSize(width: labelSize.width, height: _fontSize + 5)
            } else {
                annotationLabel.frame.size = CGSize(width: frame.size.width, height: _fontSize + 5)
            }
            annotationLabel.frame.centerInRectMut(frame, xOffset: 0, yOffset: radius + ANNOTATION_OFFSET)
            setNeedsDisplay()
        }
    }
    
    var radius: CGFloat {
        return frame.size.width * scale * 0.5
    }
    
    var scale: CGFloat {
        get {
            return _scale
        }
        set {
            _scale = newValue
            transform = CGAffineTransform(scaleX: _scale, y: _scale)
        }
    }
    
    // MARK: - Initializers
    
    init?(withIconID _icon: String, borderWidth: CGFloat = 6, shadowOffset: CGFloat = 6) {
        self.borderWidth = borderWidth
        self.shadowOffset = shadowOffset
        super.init(frame: CGRect.zero)
        guard let image = UIImage(named: _icon) else {
            return nil
        }
        common(image)
    }
    
    init(withUIImage image: UIImage, borderWidth: CGFloat = 6) {
        self.borderWidth = borderWidth
        super.init(frame: CGRect.zero)
        common(image)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func common(_ image: UIImage) {
        frame.size = image.size
        container.frame = frame
        
        let cornerRadius: CGFloat = frame.size.width * 0.5
        
        icon = image
        iconView.contentMode = .scaleAspectFit
        iconView.image = icon
        iconView.frame.size = icon.size
        iconView.layer.cornerRadius = cornerRadius
        iconView.layer.masksToBounds = true
        
        backView.frame.size = frame.size
        backView.layer.cornerRadius = cornerRadius
        backView.backgroundColor = UIColor.white
        
        shadowView.frame.size = frame.size
        shadowView.frame.centerInRectMut(frame, xOffset: -shadowOffset, yOffset: shadowOffset)
        shadowView.layer.cornerRadius = cornerRadius
        shadowView.backgroundColor = NB.Colors.ButtonShadow
        
        annotationLabel.textColor = NB.Colors.OffWhite
        annotationLabel.textAlignment = .center
        annotationLabel.numberOfLines = 1
        fontSize = _fontSize
        
        container.isUserInteractionEnabled = false
        shadowView.isUserInteractionEnabled = false
        iconView.isUserInteractionEnabled = false
        backView.isUserInteractionEnabled = false
        annotationLabel.isUserInteractionEnabled = false
        
        container.addSubview(shadowView)
        container.addSubview(backView)
        container.addSubview(iconView)
        addSubview(container)
        addSubview(annotationLabel)
        
        addTarget(self, action: #selector(NBIconButton.handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(NBIconButton.handleTouchDragExit), for: .touchDragExit)
        addTarget(self, action: #selector(NBIconButton.handleTouchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(NBIconButton.handleTouchUpOutside), for: .touchUpOutside)
    }
    
    // MARK: - Public API
    
    func transitionToActive() {
        let borderWidth = self.borderWidth
        UIView.animate(
            withDuration: ANIMATION_DURATION,
            delay: 0,
            options: .allowUserInteraction,
            animations: { [weak self] in
                self?.container.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                self?.iconView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                self?.shadowView.transform = CGAffineTransform(translationX: borderWidth * 0.5, y: borderWidth * -0.5)
            }, completion: nil)
    }
    
    func transitionToDefault() {
        UIView.animate(
            withDuration: ANIMATION_DURATION,
            delay: 0,
            options: .allowUserInteraction,
            animations: { [weak self] in
                self?.container.transform = CGAffineTransform(scaleX: 1, y: 1)
                self?.iconView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self?.shadowView.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
    }
    
    // MARK: - UIControlEvent handlers
    
    func handleTouchDown() {
        transitionToActive()
    }
    
    func handleTouchDragExit() {
        transitionToDefault()
    }
    
    func handleTouchUpInside() {
        transitionToDefault()
        runStack()
    }
    
    func handleTouchUpOutside() {
        transitionToDefault()
    }
}
