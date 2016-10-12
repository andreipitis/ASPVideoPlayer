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
@IBDesignable open class ASPVideoPlayer: UIView {
	
	//MARK: - Enumerations -
	public enum PlayerContentMode {
		case aspectFill
		case aspectFit
		case resize
	}
	
	public enum PlayerStatus {
		case new
		case readyToPlay
		case playing
		case paused
		case stopped
		case error
	}
	
	//MARK: - Closures -
	
	/**
	Basic closure type.
	*/
	public typealias VoidClosure = (() -> Void)?
	/**
	Closure type for recurring actions.
	- parameter progress: The progress indicator value. Between 0.0 and 1.0.
	*/
	public typealias ProgressClosure = ((_ progress: Double) -> Void)?
	/**
	Closure type for error handling.
	- parameter error: The error that occured.
	*/
	public typealias ErrorClosure = ((_ error: NSError) -> Void)?
	
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
	A closure that will be called when an error occured.
	*/
	open var error: ErrorClosure
	
	//MARK: - Public Variables -
	
	/**
	Sets wether the video should loop.
	*/
	open var shouldLoop: Bool = false
	
	/**
	Sets wether the video should start automatically after it has been successfuly loaded.
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
			
			deinitObservers()
			
			videoPlayerLayer.player = AVPlayer(url: url)
			videoPlayerLayer.player?.rate = 0.0
			videoPlayerLayer.videoGravity = videoGravity
			
			videoPlayerLayer.player?.addObserver(self, forKeyPath: "status", options: [], context: nil)
			
			status = .new
			DispatchQueue.main.async { [weak self] () -> Void in
				self?.newVideo?()
			}
		}
	}
	
	/**
	The gravity of the video. Adjusts how the video fills the space of the container.
	*/
	open var gravity: PlayerContentMode = .aspectFill {
		didSet {
			switch gravity {
			case .aspectFill:
				videoGravity = AVLayerVideoGravityResizeAspectFill
			case .aspectFit:
				videoGravity = AVLayerVideoGravityResizeAspect
			case .resize:
				videoGravity = AVLayerVideoGravityResize
			}
			
			videoPlayerLayer.videoGravity = videoGravity
		}
	}
	
	/**
	The volume of the player. Should be a value between 0.0 and 1.0.
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
	
	fileprivate let videoPlayerLayer: AVPlayerLayer = AVPlayerLayer()
	
	fileprivate var animationForwarder: AnimationForwarder!
	
	fileprivate var videoGravity: String! = AVLayerVideoGravityResizeAspectFill
	
	fileprivate var timeObserver: AnyObject?
	
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
			seek(0.0)
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
		seek(0.0)
		status = .stopped
		stoppedVideo?()
	}
	
	/**
	Seek to specific position in video. Should be a value between 0.0 and 1.0.
	*/
	open func seek(_ percentage: Double) {
		progress = min(1.0, max(0.0, percentage))
		if let currentItem = videoPlayerLayer.player?.currentItem {
			let time = CMTime(seconds: progress * currentItem.asset.duration.seconds, preferredTimescale: currentItem.asset.duration.timescale)
			videoPlayerLayer.player?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
		}
	}
	
	//MARK: - KeyValueObserving methods -
	
	open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard let player = object as? AVPlayer, let keyPath = keyPath else { return }
		
		if player == videoPlayerLayer.player && keyPath == "status" {
			if player.status == .readyToPlay {
				if status == .new {
					status = .readyToPlay
				}
				addTimeObserver()
				
				if startPlayingWhenReady == true {
					playVideo()
				} else {
					readyToPlayVideo?()
				}
			} else if player.status == .failed {
				status = .error
				
				let userInfo = [NSLocalizedDescriptionKey: "Error loading video."]
				let videoError = NSError(domain: "com.andreisergiupitis.aspvideoplayer", code: 99, userInfo: userInfo)
				
				error?(videoError)
			}
		}
	}
	
	//MARK: - Private methods -
	
	fileprivate func commonInit() {
		layer.addSublayer(videoPlayerLayer)
		animationForwarder = AnimationForwarder(view: self)
		videoPlayerLayer.delegate = animationForwarder
	}
	
	fileprivate func addTimeObserver() {
		if let observer = timeObserver {
			videoPlayerLayer.player?.removeTimeObserver(observer)
		}
		
		timeObserver = videoPlayerLayer.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil, using: { [weak self] (time) in
			guard let weakSelf = self , self?.status == .playing else { return }
			
			let currentTime = time.seconds
			weakSelf.progress = currentTime / weakSelf.videoLength
			
			DispatchQueue.main.async(execute: {
				weakSelf.playingVideo?(weakSelf.progress)
			})
			}) as AnyObject?
	}
	
	fileprivate func deinitObservers() {
		NotificationCenter.default.removeObserver(self)
		videoPlayerLayer.player?.removeObserver(self, forKeyPath: "status")
		if let observer = timeObserver {
			videoPlayerLayer.player?.removeTimeObserver(observer)
			timeObserver = nil
		}
	}
	
	@objc internal func itemDidFinishPlaying(_ notification: Notification) {
		let currentItem = videoPlayerLayer.player?.currentItem
		let notificationObject = notification.object as! AVPlayerItem
		
		DispatchQueue.main.async(execute: { [weak self] () -> Void in
			self?.finishedVideo?()
			if currentItem == notificationObject && self?.shouldLoop == true {
				self?.status = .playing
				self?.seek(0.0)
				self?.videoPlayerLayer.player?.rate = 1.0
			}
			})
	}
}
