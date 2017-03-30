//
//  PlayerTopToolBar.swift
//  AVFoundationLearning
//
//  Created by xiabob on 17/3/29.
//  Copyright © 2017年 xiabob. All rights reserved.
//

import UIKit
import SnapKit

protocol PlayerTopToolBarDelegate {
    func topToolBar(_ toolBar: PlayerTopToolBar, didClickBackButton button: UIButton)
}

class PlayerTopToolBar: UIView {
    
    fileprivate lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("back", for: .normal)
        button.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.textAlignment = .center
        return label
    }()
    
    var delegate: PlayerTopToolBarDelegate?

    init(frame: CGRect, title: String?) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.8)
        titleLabel.text = title
        configViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func configViews() {
        addSubview(backButton)
        addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(8)
            make.bottom.equalTo(-12)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(backButton)
            make.centerX.equalTo(self).priority(.high)
            make.left.greaterThanOrEqualTo(backButton.snp.right).offset(8)
            make.right.lessThanOrEqualTo(self).offset(-8)
        }
    }
    
    @objc fileprivate func clickBackButton() {
        delegate?.topToolBar(self, didClickBackButton: backButton)
    }

}
