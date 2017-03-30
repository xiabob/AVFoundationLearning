//
//  PlayerController.swift
//  AVFoundationLearning
//
//  Created by xiabob on 17/3/28.
//  Copyright © 2017年 xiabob. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class PlayerController: UIViewController {
    
    fileprivate lazy var topToolBar: PlayerTopToolBar = {
        let bar = PlayerTopToolBar(frame: CGRect.zero, title: ((self.asset as? AVURLAsset)?.url.lastPathComponent))
        bar.delegate = self
        return bar
    }()
    
    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapAction))
        return tap
    }()
    
    fileprivate var isEdgeViewHidden = true
    
    fileprivate var playerView: PlayerView?
    fileprivate var playerItem: AVPlayerItem?
    fileprivate var player: AVPlayer?
    fileprivate var asset: AVAsset!
    
    //MARK: - init
    
    init(from asset: AVAsset) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
        self.addNotification()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeNotification()
        playerItem?.removeObserver(self, forKeyPath: "status")
        print("\(self) deinit")
    }

    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
        loadAsset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeToLandscapeRight()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        changeToPortrait()
    }
    
    //MARK: - config views
    
    fileprivate func commonInit() {
        view.backgroundColor = UIColor.black
    }
    
    fileprivate func configViews() {
        view.addSubview(topToolBar)
        setLayout()
        configPlayerView()
        setEdgeViewHidden(isHidden: true)
    }
    
    fileprivate func configPlayerView() {
        playerView?.addGestureRecognizer(tapGesture)
        view.insertSubview(playerView!, at: 0)
        playerView?.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(self.view)
        }
    }
    
    fileprivate func setLayout() {
        topToolBar.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(view)
            make.height.equalTo(64)
        }
    }
    
    override func updateViewConstraints() {
        //topToolBar
        let height: CGFloat = isEdgeViewHidden ? 0 : 64
        topToolBar.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        
        super.updateViewConstraints()
    }
    
    //MARK: -
    
    fileprivate func setEdgeViewHidden(isHidden: Bool) {
        isEdgeViewHidden = isHidden
        setNeedsStatusBarAppearanceUpdate()
        
        //以动画的方式更新约束条件
        //这个会触发updateViewConstraints方法调用
        view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.25) {
            //这个是更新约束能够以动画方式进行的关键，事实上updateViewConstraints里面的实现放在这里也是一样
            self.view.layoutIfNeeded()
        }
    }
    
    @objc fileprivate func handleTapAction() {
        setEdgeViewHidden(isHidden: !isEdgeViewHidden)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

}


//MARK: - StatusBar

extension PlayerController {
    //设置状态栏隐藏的状态
    override var prefersStatusBarHidden: Bool {
        return isEdgeViewHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
}

//MARK: - UIDeviceOrientation
extension PlayerController {
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait.union(.landscapeRight)
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    fileprivate func removeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleOrientationChange(notification: Notification) {
//        let value = notification.userInfo?[UIDeviceOrientationRotateAnimatedUserInfoKey]
        
    }
    
    fileprivate func changeScreenOrientation() {
        //默认竖屏状态，则切换到横屏
        if UIDeviceOrientationIsPortrait(.portrait) {
            changeToLandscapeRight()
        } else {
            changeToPortrait()
        }
    }
    
    fileprivate func changeToPortrait() {
        let device = UIDevice.current
        device.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    fileprivate func changeToLandscapeRight() {
        let device = UIDevice.current
        device.setValue(UIDeviceOrientation.landscapeRight.rawValue, forKey: "orientation")
    }
}


//MARK: - PlayerTopToolBarDelegate
extension PlayerController: PlayerTopToolBarDelegate {
    func topToolBar(_ toolBar: PlayerTopToolBar, didClickBackButton button: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - play


fileprivate var kItemStatusContext = 0

extension PlayerController {
    //加载媒体资源，初始化播放器
    fileprivate func loadAsset() {
        let tracksKey = "tracks"
        //异步加载tracks数据，解析原始数据的过程需要时间
        asset.loadValuesAsynchronously(forKeys: [tracksKey]) {
            DispatchQueue.main.async {
                self.initPlayer()
            }
        }
    }
    
    //初始化播放器
    fileprivate func initPlayer() {
        let tracksKey = "tracks"
        var error: NSError?
        let status = asset.statusOfValue(forKey: tracksKey, error: &error)
        //判断是否加载完成
        if status == .loaded {
            //初始化
            playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: playerItem)
            playerView = PlayerView(player: player)
            configViews()
            
            //观测playerItem的状态
            playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: &kItemStatusContext)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        } else {
            print("error:\(error ?? NSError(domain: "load video file failed", code: -1, userInfo: nil))")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kItemStatusContext {
            DispatchQueue.main.async {
                return self.syncUI()
            }
        }
        
    }
    
    //播放结束，这里直接回到开头
    @objc fileprivate func playerItemDidReachEnd(notification: Notification) {
        player?.seek(to: kCMTimeZero)
    }
    
    
    @objc fileprivate func syncUI() {
        if let item = self.player?.currentItem {
            if item.status == .readyToPlay {
                player?.play()
            } else {
                print("can't play:\(item.error)")
            }
        } else {
            print("no asset")
        }
    }
    
    fileprivate func play() {
        
    }
}
