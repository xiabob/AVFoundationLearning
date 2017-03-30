//
//  ViewController.swift
//  AVFoundation-VideoPlayer
//
//  Created by xiabob on 17/3/28.
//  Copyright © 2017年 xiabob. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class ListController: UIViewController {
    
    fileprivate lazy var videoTableView: UITableView = {
        let tableView: UITableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.register(VideoCell.self, forCellReuseIdentifier: NSStringFromClass(VideoCell.self))
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    fileprivate var videos: [AVURLAsset] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
        configViews()
        loadVideos()
    }

    fileprivate func commonInit() {
        navigationItem.title = "本地视频"
        view.backgroundColor = UIColor.white
    }
    
    fileprivate func configViews() {
        view.addSubview(videoTableView)
    }
    
    fileprivate func loadVideos() {
        loadVideosFromPhotos()
    }

    fileprivate func loadVideosFromPhotos() {
        let library = ALAssetsLibrary()
        library.enumerateGroups(withTypes: ALAssetsGroupType(ALAssetsGroupSavedPhotos), using: { (group, stop) in
            // Within the group enumeration block, filter to enumerate just videos.
            group?.setAssetsFilter(.allVideos())
            
            group?.enumerateAssets({ (asset, index, innerStop) in
                // The end of the enumeration is signaled by asset == nil.
                if let asset = asset {
                    let url = asset.defaultRepresentation().url()!
                    let avAsset = AVURLAsset(url: url)
                    self.videos.append(avAsset)
                } else {
                    DispatchQueue.main.async {
                        self.videoTableView.reloadData()
                    }
                }
            })
        }) { (error) in
            
        }
    }
}

extension ListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(VideoCell.self), for: indexPath) as! VideoCell
        cell.refreshViews(with: videos[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PlayerController(from: videos[indexPath.row])
        present(vc, animated: true, completion: nil)
//        navigationController?.pushViewController(vc, animated: true)
    }
}

