//
//  NBIconLabel.swift
//  NBFace
//
//  Created by David Glivar on 5/27/16.
//  Copyright © 2016 Wieden+Kennedy. All rights reserved.
//

import Foundation
import UIKit

class NBIconLabel: NBView {
    
    var icon: UIImageView!
    var label = UILabel()
    
    convenience init(icon: String, text: String, xoffset: CGFloat = 0, yoffset: CGFloat = 0) {
        self.init(frame: CGRect(x: 0, y: 0, width: NB.FRAME.width, height: 50))
        guard let image = UIImage(named: icon) else {
            NB.log("unknown image id: \(icon)")
            return
        }
        
        self.icon = UIImageView(image: image)
        
        var trans = CGAffineTransform(scaleX: 0.5, y: 0.5)
        trans = trans.translatedBy(x: xoffset, y: yoffset)
        self.icon.transform = trans
        
        label.text = text
        label.font = UIFont(name: NB.Font.MavenProBold.rawValue, size: 21)
        label.numberOfLines = 1
        label.textColor = NB.Colors.OffWhite
        label.frame.size = CGSize(width: NB.FRAME.width, height: 50)
        label.frame.origin = CGPoint(x: 48, y: -3)
        
        addSubview(self.icon)
        addSubview(label)
        sizeToFit()
    }
}
