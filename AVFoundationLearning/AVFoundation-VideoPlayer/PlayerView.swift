//
//  PlayerView.swift
//  AVFoundationLearning
//
//  Created by xiabob on 17/3/29.
//  Copyright © 2017年 xiabob. All rights reserved.
//

import UIKit
import AVFoundation

//layer不支持自动布局，这里用view包装一下
class PlayerView: UIView {
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override open class var layerClass: Swift.AnyClass  {
        return AVPlayerLayer.self
    }
    
    init(player: AVPlayer?) {
        super.init(frame: CGRect.zero)
        self.player = player
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
