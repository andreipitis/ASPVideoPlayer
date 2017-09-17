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
	
	//MARK: - Type definitions -
	
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
	
	//MARK: - Enumerations -
	
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
	
	//MARK: - Closures -
	
	/**
	A closure that will be called when a new video is loaded.
	*/
	open var newVideo: VoidClosure
	
	/**
	A closure that will be called when the video is ready to play.
	*/
	open var readyToPlayVideo: VoidClosure
	
	/**
	A closure that will be called when a video is started.
	*/
	open var startedVideo: VoidClosure
	
	/**
	A closure that will be called repeatedly while the video is playing.
	*/
	open var playingVideo: ProgressClosure
	
	/**
	A closure that will be called when a video is paused.
	*/
	open var pausedVideo: VoidClosure
	
	/**
	A closure that will be called when the end of the video has been reached.
	*/
	open var finishedVideo: VoidClosure
	
	/**
	A closure that will be called when a video is stopped.
	*/
	open var stoppedVideo: VoidClosure
	
	/**
	A closure that will be called when a seek is triggered.
	*/
	open var seekStarted: VoidClosure
	
	/**
	A closure that will be called when a seek has ended.
	*/
	open var seekEnded: VoidClosure
	
	/**
	A closure that will be called when an error occured.
	*/
	open var error: ErrorClosure
	
	//MARK: - Public Variables -
	
	/**
	Sets whether the video should loop.
	*/
	open var shouldLoop: Bool = false
	
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
			videoPlayerLayer.player?.volume = value
		}
		get {
			return videoPlayerLayer.player?.volume ?? 0.0
		}
	}
	
	/**
	The current playback time in seconds.
	*/
	open var currentTime: Double {
		if let time = videoPlayerLayer.player?.currentItem?.currentTime() {
			return time.seconds
		}
		
		return 0.0
	}
	
	/**
	The length of the video in seconds.
	*/
	open var videoLength: Double {
		if let duration = videoPlayerLayer.player?.currentItem?.asset.duration {
			return duration.seconds
		}
		
		return 0.0
	}
	
	fileprivate(set) var progress: Double = 0.0
	
	//MARK: - Private Variables and Constants -
	
	private let videoPlayerLayer: AVPlayerLayer = AVPlayerLayer()
	
	private var animationForwarder: AnimationForwarder!
	
	private var videoGravity: AVLayerVideoGravity! = AVLayerVideoGravity.resizeAspectFill
	
	private var timeObserver: AnyObject?
	
	//MARK: - Superclass methods -
	
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
		deinitObservers()
	}
	
	//MARK: - Public methods -
	
	/**
	Starts the video player from the beginning.
	*/
	open func playVideo() {
		if progress >= 1.0 {
			seekToZero()
		}
		
		status = .playing
		videoPlayerLayer.player?.rate = 1.0
		startedVideo?()
		
		NotificationCenter.default.removeObserver(self)
		if let currentItem = videoPlayerLayer.player?.currentItem {
			NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)) , name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: currentItem)
		}
	}
	
	/**
	Pauses the video.
	*/
	open func pauseVideo() {
		videoPlayerLayer.player?.rate = 0.0
		status = .paused
		pausedVideo?()
	}
	
	/**
	Stops the video.
	*/
	open func stopVideo() {
		videoPlayerLayer.player?.rate = 0.0
		seekToZero()
		status = .stopped
		stoppedVideo?()
	}
	
	/**
	Seek to specific position in video. Should be a value in the range [0.0, 1.0].
	*/
	open func seek(_ percentage: Double) {
		progress = min(1.0, max(0.0, percentage))
		if let currentItem = videoPlayerLayer.player?.currentItem {
			if progress == 0.0 {
				seekToZero()
				playingVideo?(progress)
			} else {
				let time = CMTime(seconds: progress * currentItem.asset.duration.seconds, preferredTimescale: currentItem.asset.duration.timescale)
				videoPlayerLayer.player?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (finished) in
					if finished == false {
						self.seekStarted?()
					} else {
						self.seekEnded?()
						self.playingVideo?(self.progress)
					}
				})
			}
		}
	}
	
	//MARK: - KeyValueObserving methods -
	
	open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard let asset = object as? AVPlayerItem, let keyPath = keyPath else { return }
		
		if asset == videoPlayerLayer.player?.currentItem && keyPath == "status" {
			if asset.status == .readyToPlay {
				if status == .new {
					status = .readyToPlay
				}
				addTimeObserver()
				
				if startPlayingWhenReady == true {
					playVideo()
				} else {
					readyToPlayVideo?()
				}
			} else if asset.status == .failed {
				status = .error
				
				let userInfo = [NSLocalizedDescriptionKey: "Error loading video."]
				let videoError = NSError(domain: "com.andreisergiupitis.aspvideoplayer", code: 99, userInfo: userInfo)
				
				error?(videoError)
			}
		}
	}
	
	//MARK: - Private methods -

    private func setVideoAsset(asset: AVAsset) {
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["duration", "tracks"])

        deinitObservers()

        videoPlayerLayer.player?.replaceCurrentItem(with: playerItem)
        videoPlayerLayer.videoGravity = videoGravity

        videoPlayerLayer.player?.currentItem?.addObserver(self, forKeyPath: "status", options: [], context: nil)

        status = .new
        newVideo?()
    }

    private func commonInit() {
        videoPlayerLayer.player = AVPlayer()
        videoPlayerLayer.contentsScale = UIScreen.main.scale
    }
	
	fileprivate func seekToZero() {
		progress = 0.0
		let time = CMTime(seconds: 0.0, preferredTimescale: 1)
		videoPlayerLayer.player?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
	}
	
	fileprivate func addTimeObserver() {
		if let observer = timeObserver {
			videoPlayerLayer.player?.removeTimeObserver(observer)
		}
		
		timeObserver = videoPlayerLayer.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil, using: { [weak self] (time) in
			guard let weakSelf = self , self?.status == .playing else { return }
			
			let currentTime = time.seconds
			weakSelf.progress = currentTime / (weakSelf.videoLength != 0.0 ? weakSelf.videoLength : 1.0)
			
			weakSelf.playingVideo?(weakSelf.progress)
		}) as AnyObject?
	}
	
	fileprivate func deinitObservers() {
		NotificationCenter.default.removeObserver(self)
        if let video = videoPlayerLayer.player?.currentItem, video.observationInfo != nil {
            video.removeObserver(self, forKeyPath: "status")
        }
        
		if let observer = timeObserver {
			videoPlayerLayer.player?.removeTimeObserver(observer)
			timeObserver = nil
		}
	}
	
    @objc internal func itemDidFinishPlaying(_ notification: Notification) {
		let currentItem = videoPlayerLayer.player?.currentItem
		let notificationObject = notification.object as! AVPlayerItem
		
		finishedVideo?()
		if currentItem == notificationObject && shouldLoop == true {
			status = .playing
			seekToZero()
			videoPlayerLayer.player?.rate = 1.0
		} else {
			stopVideo()
		}
	}
}
