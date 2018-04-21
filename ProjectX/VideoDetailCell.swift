//
//  VideoDetailCell.swift
//  ProjectX
//
//  Created by amir lahav on 25.10.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import Cartography
import AVFoundation

protocol VideoDetailCellDelegate:class {
    func playButtonDidPress()
    func tapOnceOnVideoLayer()
    func videoDidReachToEnd()
}
extension VideoDetailCellDelegate
{
    func playButtonDidPress(){}
    func tapOnceOnVideoLayer(){}
    func videoDidReachToEnd(){}

}

protocol GeustureHendler {
    
}

class VideoDetailCell: UICollectionViewCell,GeustureHendler, Blurable {
    
    
    let playButtonSize:CGFloat = 70.0
    var imageView:ImageScrollView
    var videoView:UIView
    var avPlayer:AVPlayer
    var avPlayerLayer:AVPlayerLayer
    var cellFrame:CGRect
    var shouldPlay:Bool = true
    var playButton:UIButton
    var itemSpace:CGFloat = 44.0
    var isPlaying: Bool = false
    var reachEnd: Bool = false
    var blurView:BlurView
    var blurEffectView: UIVisualEffectView

    weak var delegate:VideoDetailCellDelegate?
    
    
    override init(frame: CGRect) {
        
        imageView = ImageScrollView(frame: frame)
        videoView = UIView(frame: frame)
        avPlayer = AVPlayer()
        avPlayerLayer = AVPlayerLayer()
        cellFrame = frame
        playButton = UIButton(frame: frame)
        blurView = BlurView(frame: CGRect(x: 0, y: 0, width: playButtonSize, height: playButtonSize))
        blurEffectView = UIVisualEffectView(frame: frame)
        super.init(frame: frame)
        setupView()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        print("deinit video cell")
    }
    
    func playerItemDidReachEnd(notification: Notification) {
        if let _: AVPlayerItem = notification.object as? AVPlayerItem {
                reachEnd = true
                self.pauseVideo()
                self.delegate?.videoDidReachToEnd()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView()
    {
        self.contentView.addSubview(videoView)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(blurView)
        blurView.addSubview(playButton)
        
        let tapOnce = UITapGestureRecognizer(target: self, action: #selector(self.tapOnce))
        videoView.addGestureRecognizer(tapOnce)
        
        constrain(videoView,self.contentView){video, cell in
            video.edges == cell.edges
        }
        constrain(imageView,self.contentView){image, cell in
            image.edges == cell.edges
        }
        constrain(blurView,self.contentView){view, cell in
            view.height == playButtonSize
            view.width == playButtonSize
            view.centerX == cell.centerX - itemSpace / 2
            view.centerY == cell.centerY
        }
        constrain(playButton,blurView){button, view in
            button.edges == view.edges
        }
        
        
        setupPlayer()
        setupPlayButton()
    }
    
    func tapOnce()
    {
        delegate?.tapOnceOnVideoLayer()
    }
    
    func setupPlayButton()
    {
        blurView.addBlurEffect()
        blurView.setupPlayButton()
        playButton.addTarget(self, action: #selector(self.playVideo), for: .touchUpInside)
    }
    
    func pauseVideo()
    {
        avPlayer.pause()
        imageView.isHidden = true
        blurView.isHidden = false
    }
    
    func showPlayButton()
    {
        if !blurView.isHidden {blurView.isHidden = true }
    }
    
    func resetVideo()
    {
        pauseVideo()
        avPlayer.seek(to: kCMTimeZero)
    }
    
    
    func playVideo()
    {
        if reachEnd {resetVideo()}
        reachEnd = false
        delegate?.playButtonDidPress()
        if avPlayer.rate == 0 {
            avPlayer.play()
            imageView.isHidden = true
            blurView.isHidden = true
        }
    }
    
    func setupPlayer()
    {
        avPlayer = AVPlayer()
        avPlayer.actionAtItemEnd = .pause
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.player?.actionAtItemEnd = .none
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        avPlayerLayer.frame = UIScreen.main.bounds
        videoView.layer.addSublayer(avPlayerLayer)
    }
    
    func setupVideo(url:URL)  {

        
        let item = AVPlayerItem(url: url)
        avPlayer.replaceCurrentItem(with: item)
        avPlayerLayer.frame = UIScreen.main.bounds
    }
    
    func replaceVideoWith(item:AVPlayerItem)
    {
        avPlayer.replaceCurrentItem(with: item)
        avPlayerLayer.frame = UIScreen.main.bounds
    }
    
    func playerItemDidReachEnd()
    {
        avPlayer.pause()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.zoomView?.image = nil
        avPlayer.replaceCurrentItem(with: nil)
    }
    
}
