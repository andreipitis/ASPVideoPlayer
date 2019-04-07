//
//  ASPVideoPlayer.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 28/03/16.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

/**
 A simple UIView subclass that can play a video and allows animations to be applied during playback.
 */
@IBDesignable open class ASPVideoPlayerView: UIView {

    // MARK: - Type definitions -

    /**
     Basic closure type.
     */
    public typealias VoidClosure = (() -> Void)?

    /**
     Closure type for recurring actions.
     - Parameter progress: The progress indicator value. Value is in range [0.0, 1.0].
     */
    public typealias ProgressClosure = ((_ progress: Double) -> Void)?

    /**
     Closure type for error handling.
     - Parameter error: The error that occured.
     */
    public typealias ErrorClosure = ((_ error: NSError) -> Void)?

    // MARK: - Enumerations -

    /**
     Specifies how the video is displayed within a player layer’s bounds.
     */
    public enum PlayerContentMode {
        case aspectFill
        case aspectFit
        case resize
    }
    
    /**
     Specifies how the video is rotated within a player layer’s bounds.
     */
    public enum PlayerRotation {
        case none
        case left
        case right
        case upsideDown
        
        func radians() -> CGFloat {
            switch self {
            case .none:
                return 0.0
            case .left:
                return .pi / 2.0
            case .right:
                return -.pi / 2.0
            case .upsideDown:
                return .pi
            }
        }
    }

    /**
     Specifies the current status of the player.
     */
    public enum PlayerStatus {
        /**
         A new video has been assigned.
         */
        case new
        /**
         The video is ready to be played.
         */
        case readyToPlay
        /**
         The video is currently being played.
         */
        case playing
        /**
         The video has been paused.
         */
        case paused
        /**
         The video playback has been stopped.
         */
        case stopped
        /**
         An error occured. For more details use the `error` closure.
         */
        case error
    }

    // MARK: - Closures -

    /**
     A closure that will be called when a new video is loaded.
     */
    open var newVideo: VoidClosure = nil

    /**
     A closure that will be called when the video is ready to play.
     */
    open var readyToPlayVideo: VoidClosure = nil

    /**
     A closure that will be called when a video is started.
     */
    open var startedVideo: VoidClosure = nil

    /**
     A closure that will be called repeatedly while the video is playing.
     */
    open var playingVideo: ProgressClosure = nil

    /**
     A closure that will be called when a video is paused.
     */
    open var pausedVideo: VoidClosure = nil

    /**
     A closure that will be called when the end of the video has been reached.
     */
    open var finishedVideo: VoidClosure = nil

    /**
     A closure that will be called when a video is stopped.
     */
    open var stoppedVideo: VoidClosure = nil

    /**
     A closure that will be called when a seek is triggered.
     */
    open var seekStarted: VoidClosure = nil

    /**
     A closure that will be called when a seek has ended.
     */
    open var seekEnded: VoidClosure = nil

    /**
     A closure that will be called when an error occured.
     */
    open var error: ErrorClosure = nil

    // MARK: - Public Variables -

    /**
     Sets whether the video should loop.
     */
    open var shouldLoop: Bool = false

    /**
     Sets the preferred player rate. (ex. 0.5x, 1x, 2x, etc).

     The default value is 1.0
     */
    open var preferredRate: Float = 1.0

    /**
     Sets whether the video should start automatically after it has been successfuly loaded.
     */
    open var startPlayingWhenReady: Bool = false

    /**
     The current status of the video player.
     */
    open fileprivate(set) var status: PlayerStatus = .new

    /**
     The url of the video that should be loaded.
     */
    open var videoURL: URL? = nil {
        didSet {
            guard let url = videoURL else {
                status = .error

                let userInfo = [NSLocalizedDescriptionKey: "Video URL is invalid."]
                let videoError = NSError(domain: "com.andreisergiupitis.aspvideoplayer", code: 99, userInfo: userInfo)

                error?(videoError)

                delegate?.error?(error: videoError)
                return
            }

            let asset = AVAsset(url: url)
            setVideoAsset(asset: asset)
        }
    }

    /**
     The video asset that should be loaded.
     */
    open var videoAsset: AVAsset? = nil {
        didSet {
            guard let asset = videoAsset else {
                status = .error

                let userInfo = [NSLocalizedDescriptionKey: "Video asset is invalid."]
                let videoError = NSError(domain: "com.andreisergiupitis.aspvideoplayer", code: 99, userInfo: userInfo)
                
                error?(videoError)
                
                delegate?.error?(error: videoError)
                return
            }

            setVideoAsset(asset: asset)
        }
    }

    /**
     The gravity of the video. Adjusts how the video fills the space of the container.
     */
    open var gravity: PlayerContentMode = .aspectFill {
        didSet {
            switch gravity {
            case .aspectFill:
                videoGravity = AVLayerVideoGravity.resizeAspectFill
            case .aspectFit:
                videoGravity = AVLayerVideoGravity.resizeAspect
            case .resize:
                videoGravity = AVLayerVideoGravity.resize
            }

            videoPlayerLayer.videoGravity = videoGravity
        }
    }
    
    /**
     The rotation of the video.
     */
    open var rotation: PlayerRotation = .none {
        didSet {
            videoPlayerLayer.setAffineTransform(CGAffineTransform(rotationAngle: rotation.radians()))
        }
    }

    /**
     The volume of the player. Should be a value in the range [0.0, 1.0].
     */
    open var volume: Float {
        set {
            let value = min(1.0, max(0.0, newValue))
            player.volume = value
        }
        get {
            return player.volume
        }
    }

    /**
     The current playback time in seconds.
     */
    open var currentTime: Double {
        if let time = player.currentItem?.currentTime() {
            return time.seconds
        }

        return 0.0
    }

    /**
     The length of the video in seconds.
     */
    open var videoLength: Double {
        if let duration = player.currentItem?.asset.duration {
            return duration.seconds
        }

        return 0.0
    }

    fileprivate(set) var progress: Double = 0.0

    // MARK: - Private Variables and Constants -

    private let videoPlayerLayer: AVPlayerLayer = AVPlayerLayer()
    private let player = AVPlayer()

    private var animationForwarder: AnimationForwarder!

    private var videoGravity: AVLayerVideoGravity! = AVLayerVideoGravity.resizeAspectFill

    private var timeObserver: AnyObject?

    //TODO: Replace the delegate with a better implementation for event registration
    internal weak var delegate: ASPVideoPlayerViewDelegate?

    // MARK: - Superclass methods -

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    open override var frame: CGRect {
        didSet {
            videoPlayerLayer.frame = bounds
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if layer.sublayers == nil || !layer.sublayers!.contains(videoPlayerLayer) {
            layer.addSublayer(videoPlayerLayer)
            animationForwarder = AnimationForwarder(view: self)
            videoPlayerLayer.delegate = animationForwarder
        }

        videoPlayerLayer.frame = bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        deinitObservers()
    }

    // MARK: - Public methods -

    /**
     Starts the video player from the beginning.
     */
    @objc open func playVideo() {
        guard let playerItem = player.currentItem else { return }

        if progress >= 1.0 {
            seekToZero()
        }

        status = .playing
        player.rate = preferredRate
        startedVideo?()
        delegate?.startedVideo?()

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)) , name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    /**
     Pauses the video.
     */
    open func pauseVideo() {
        player.rate = 0.0
        status = .paused
        pausedVideo?()

        delegate?.pausedVideo?()
    }

    /**
     Stops the video.
     */
    open func stopVideo() {
        player.rate = 0.0
        seekToZero()
        status = .stopped
        stoppedVideo?()

        delegate?.stoppedVideo?()
    }

    /**
     Seek to specific position in video. Should be a value in the range [0.0, 1.0].
     */
    open func seek(_ percentage: Double) {
        progress = min(1.0, max(0.0, percentage))
        guard let currentItem = player.currentItem else { return }

        if progress == 0.0 {
            seekToZero()
            playingVideo?(progress)

            delegate?.playingVideo?(progress: progress)
        } else {
            let time = CMTime(seconds: progress * currentItem.asset.duration.seconds, preferredTimescale: currentItem.asset.duration.timescale)
            player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { [weak self] (finished) in
                guard let strongSelf = self else { return }

                if finished == false {
                    strongSelf.seekStarted?()
                    strongSelf.delegate?.seekStarted?()
                } else {
                    strongSelf.seekEnded?()
                    strongSelf.playingVideo?(strongSelf.progress)

                    strongSelf.delegate?.seekEnded?()
                    strongSelf.delegate?.playingVideo?(progress: strongSelf.progress)
                }
            })
        }
    }

    // MARK: - KeyValueObserving methods -

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let asset = object as? AVPlayerItem, let keyPath = keyPath else { return }

        if asset == player.currentItem && keyPath == "status" {
            if asset.status == .readyToPlay {
                if status == .new {
                    status = .readyToPlay
                }
                addTimeObserver()

                if startPlayingWhenReady == true {
                    playVideo()
                } else {
                    readyToPlayVideo?()

                    delegate?.readyToPlayVideo?()
                }
            } else if asset.status == .failed {
                status = .error

                let userInfo = [NSLocalizedDescriptionKey: "Error loading video."]
                let videoError = NSError(domain: "com.andreisergiupitis.aspvideoplayer", code: 99, userInfo: userInfo)

                error?(videoError)

                delegate?.error?(error: videoError)
            }
        }
    }

    // MARK: - Private methods -

    private func setVideoAsset(asset: AVAsset) {
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["duration", "tracks"])

        deinitObservers()

        player.replaceCurrentItem(with: playerItem)
        videoPlayerLayer.videoGravity = videoGravity

        player.currentItem?.addObserver(self, forKeyPath: "status", options: [], context: nil)

        status = .new
        newVideo?()

        delegate?.newVideo?()
    }

    private func commonInit() {
        videoPlayerLayer.player = player
        videoPlayerLayer.contentsScale = UIScreen.main.scale

        NotificationCenter.default.addObserver(self, selector: #selector(ASPVideoPlayerView.applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ASPVideoPlayerView.applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    fileprivate func seekToZero() {
        progress = 0.0
        let time = CMTime(seconds: 0.0, preferredTimescale: 1)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    fileprivate func addTimeObserver() {
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
        }

        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil, using: { [weak self] (time) in
            guard let strongSelf = self, strongSelf.status == .playing else { return }

            let currentTime = time.seconds
            strongSelf.progress = currentTime / (strongSelf.videoLength != 0.0 ? strongSelf.videoLength : 1.0)

            strongSelf.playingVideo?(strongSelf.progress)

            strongSelf.delegate?.playingVideo?(progress: strongSelf.progress)
        }) as AnyObject?
    }

    fileprivate func deinitObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        if let video = player.currentItem, video.observationInfo != nil {
            video.removeObserver(self, forKeyPath: "status")
        }
        
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    @objc fileprivate func applicationDidEnterBackground() {
        videoPlayerLayer.player = nil
    }

    @objc fileprivate func applicationWillEnterForeground() {
        videoPlayerLayer.player = player
    }

    @objc internal func itemDidFinishPlaying(_ notification: Notification) {
        let currentItem = player.currentItem
        let notificationObject = notification.object as? AVPlayerItem

        finishedVideo?()

        delegate?.finishedVideo?()

        if currentItem == notificationObject && shouldLoop == true {
            status = .playing
            seekToZero()
            player.rate = preferredRate
        } else {
            stopVideo()
        }
    }
}
