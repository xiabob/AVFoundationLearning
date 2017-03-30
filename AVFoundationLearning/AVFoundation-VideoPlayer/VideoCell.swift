//
//  VideoCell.swift
//  AVFoundationLearning
//
//  Created by xiabob on 17/3/28.
//  Copyright © 2017年 xiabob. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

fileprivate var generators: [AVURLAsset: AVAssetImageGenerator] = [:]

class VideoCell: UITableViewCell {
    
    //MARK: - Var
    
    fileprivate lazy var thumbnailView: UIView = {
        let view = UIView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.contentsScale = UIScreen.main.scale
        view.backgroundColor = UIColor.gray
        return view
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.black
        return label
    }()
    
    fileprivate lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.gray
        return label
    }()
    
    fileprivate lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        return view
    }()
    
    fileprivate var asset: AVURLAsset!
    
    //MARK: - Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - config views
    
    fileprivate func configViews() {
        addSubview(thumbnailView)
        addSubview(titleLabel)
        addSubview(timeLabel)
        addSubview(bottomLine)
        
        setLayout()
    }
    
    fileprivate func setLayout() {
        thumbnailView.snp.makeConstraints { (make) in
            make.left.top.equalTo(8)
            make.bottom.equalTo(-8)
            make.width.equalTo(thumbnailView.snp.height)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(thumbnailView)
            make.left.equalTo(thumbnailView.snp.right).offset(8)
            make.right.lessThanOrEqualTo(self).offset(-8)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(self)
            make.height.equalTo(0.5)
            make.left.equalTo(self).offset(8)
        }
    }
    
    //MARK: - refresh action
    
    func refreshViews(with asset: AVURLAsset) {
        self.asset = asset
        
        titleLabel.text = asset.url.lastPathComponent
        loadThumbnail()
        loadVideoDuration()
    }
    
    fileprivate func loadThumbnail() {
        var generator = generators[asset]
        if generator == nil {
            //异步的方式获取缩略图
            generator = AVAssetImageGenerator(asset: asset)
        }
        
        generator?.generateCGImagesAsynchronously(forTimes: [kCMTimeZero as NSValue]) { (requestedTime, image, acturalTime, result, error) in
            DispatchQueue.main.async {
                //获取缩略图成功
                if result == .succeeded {
                    self.thumbnailView.layer.contents = image
                } else {
                    self.thumbnailView.layer.contents = nil
                }
            }
        }
        generators[asset] = generator
    }
    
    fileprivate func loadVideoDuration() {
        let keys = ["duration"]
        if asset.statusOfValue(forKey: keys[0], error: nil) == .loaded {
            timeLabel.text = convertCMTime(time: asset.duration)
        } else {
            asset.loadValuesAsynchronously(forKeys: keys, completionHandler: { 
                let status = self.asset.statusOfValue(forKey: keys[0], error: nil)
                if status == .loaded {
                    DispatchQueue.main.async {
                        self.timeLabel.text = self.convertCMTime(time: self.asset.duration)
                    }
                }
            })
        }
    }
    
    fileprivate func convertCMTime(time: CMTime) -> String {
        let duration = Int(CMTimeGetSeconds(time))
        let hours = duration / 3600
        let mins = (duration - hours*3600) / 60
        let seconds = duration - hours*3600 - mins*60
        return "\(hours)小时\(mins)分\(seconds)秒"
    }

    //MARK: - super method
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            backgroundColor = UIColor.white
            UIView.animate(withDuration: 0.25, animations: { 
                self.backgroundColor = UIColor.gray
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.25, animations: {
                    self.backgroundColor = UIColor.white
                })
            })
        }
    }

}
