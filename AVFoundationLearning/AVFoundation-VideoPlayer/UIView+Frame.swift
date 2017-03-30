//
//  UIView+Frame.swift
//  AVFoundationLearning
//
//  Created by xiabob on 17/3/29.
//  Copyright © 2017年 xiabob. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var xb_height: CGFloat {
        get {
            return frame.height
        }
        
        set {
            let size = CGSize(width: frame.width, height: newValue)
            frame.size = size
        }
    }
}
