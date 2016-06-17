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

@IBDesignable public class ASPVideoPlayer: UIView {
	
	//MARK: - Enumerations -
	public enum PlayerContentMode {
		case AspectFill
		case AspectFit
		case Resize
	}
	
	public enum PlayerStatus {
		case New
		case ReadyToPlay
		case Playing
		case Paused
		case Stopped
		case Error
	}
	
	//MARK: - Clojures -
	
	public typealias VoidClojure = (() -> Void)?
	public typealias ProgressClojure = ((progress: Double) -> Void)?
	public typealias ErrorClojure = ((error: NSError) -> Void)?
	
	public var newVideo: VoidClojure
	public var readyToPlayVideo: VoidClojure
	public var startedVideo: VoidClojure
	public var playingVideo: ProgressClojure
	public var pausedVideo: VoidClojure
	public var finishedVideo: VoidClojure
	public var stoppedVideo: VoidClojure
	public var error: ErrorClojure
	
	//MARK: - Public Variables -
	
	public var shouldLoop: Bool = false
	public var startPlayingWhenReady: Bool = false
	
	public var status: PlayerStatus = .New
	
	public var videoURL: NSURL? = nil {
		didSet {
			guard let url = videoURL else {
				status = .Error
				
				let userInfo = [NSLocalizedDescriptionKey: "Video URL is invalid."]
				let videoError = NSError(domain: "com.andreisergiupitis.aspvideoplayer", code: 99, userInfo: userInfo)
				
				error?(error: videoError)
				return
			}
			
			deinitObservers()
			
			videoPlayerLayer.player = AVPlayer(URL: url)
			videoPlayerLayer.player?.rate = 0.0
			videoPlayerLayer.videoGravity = videoGravity
			
			videoPlayerLayer.player?.addObserver(self, forKeyPath: "status", options: [], context: nil)
			
			status = .New
			dispatch_async(dispatch_get_main_queue()) { [weak self] () -> Void in
				self?.newVideo?()
			}
		}
	}
	
	public var gravity: PlayerContentMode = .AspectFill {
		didSet {
			switch gravity {
			case .AspectFill:
				videoGravity = AVLayerVideoGravityResizeAspectFill
			case .AspectFit:
				videoGravity = AVLayerVideoGravityResizeAspect
			case .Resize:
				videoGravity = AVLayerVideoGravityResize
			}
			
			videoPlayerLayer.videoGravity = videoGravity
		}
	}
	
	public var volume: Float {
		set {
			let value = min(1.0, max(0.0, newValue))
			videoPlayerLayer.player?.volume = value
		}
		get {
			return videoPlayerLayer.player?.volume ?? 0.0
		}
	}
	
	public var currentTime: Double {
		if let time = videoPlayerLayer.player?.currentItem?.currentTime() {
			return time.seconds
		}
		
		return 0.0
	}
	
	public var videoLength: Double {
		if let duration = videoPlayerLayer.player?.currentItem?.asset.duration {
			return duration.seconds
		}
		
		return 0.0
	}
	
	private(set) var progress: Double = 0.0
	
	//MARK: - Private Variables and Constants -
	
	private let videoPlayerLayer: AVPlayerLayer = AVPlayerLayer()
	
	private var animationForwarder: AnimationForwarder!
	
	private var videoGravity: String! = AVLayerVideoGravityResizeAspectFill
	
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
	
	public override var frame: CGRect {
		didSet {
			videoPlayerLayer.frame = bounds
		}
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		videoPlayerLayer.frame = bounds
	}
	
	deinit {
		deinitObservers()
		print("ASPVideoPlayer deinit called")
	}
	
	//MARK: - Public methods -
	
	public func playVideo() {
		if progress >= 1.0 {
			seek(0.0)
		}
		
		status = .Playing
		videoPlayerLayer.player?.rate = 1.0
		startedVideo?()
		
		NSNotificationCenter.defaultCenter().removeObserver(self)
		if let currentItem = videoPlayerLayer.player?.currentItem {
			NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(itemDidFinishPlaying(_:)) , name: AVPlayerItemDidPlayToEndTimeNotification, object: currentItem)
		}
	}
	
	public func pauseVideo() {
		videoPlayerLayer.player?.rate = 0.0
		status = .Paused
		pausedVideo?()
	}
	
	public func stopVideo() {
		videoPlayerLayer.player?.rate = 0.0
		seek(0.0)
		status = .Stopped
		stoppedVideo?()
	}
	
	public func seek(percentage: Double) {
		progress = min(1.0, max(0.0, percentage))
		if let currentItem = videoPlayerLayer.player?.currentItem {
			let time = CMTime(seconds: progress * currentItem.asset.duration.seconds, preferredTimescale: currentItem.asset.duration.timescale)
			videoPlayerLayer.player?.seekToTime(time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
		}
	}
	
	//MARK: - KeyValueObserving methods -
	
	public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		guard let player = object as? AVPlayer, let keyPath = keyPath else { return }
		
		if player == videoPlayerLayer.player && keyPath == "status" {
			if player.status == .ReadyToPlay {
				if status == .New {
					status = .ReadyToPlay
				}
				addTimeObserver()
				
				if startPlayingWhenReady == true {
					playVideo()
				} else {
					readyToPlayVideo?()
				}
			} else if player.status == .Failed {
				status = .Error
				
				let userInfo = [NSLocalizedDescriptionKey: "Error loading video."]
				let videoError = NSError(domain: "com.andreisergiupitis.aspvideoplayer", code: 99, userInfo: userInfo)
				
				error?(error: videoError)
			}
		}
	}
	
	//MARK: - Private methods -
	
	private func commonInit() {
		layer.addSublayer(videoPlayerLayer)
		animationForwarder = AnimationForwarder(view: self)
		videoPlayerLayer.delegate = animationForwarder
	}
	
	private func addTimeObserver() {
		if let observer = timeObserver {
			videoPlayerLayer.player?.removeTimeObserver(observer)
		}
		
		timeObserver = videoPlayerLayer.player?.addPeriodicTimeObserverForInterval(CMTime(seconds: 0.5, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil, usingBlock: { [weak self] (time) in
			guard let weakSelf = self where self?.status == .Playing else { return }
			
			let currentTime = time.seconds
			weakSelf.progress = currentTime / weakSelf.videoLength
			
			dispatch_async(dispatch_get_main_queue(), {
				weakSelf.playingVideo?(progress: weakSelf.progress)
			})
			})
	}
	
	private func deinitObservers() {
		NSNotificationCenter.defaultCenter().removeObserver(self)
		videoPlayerLayer.player?.removeObserver(self, forKeyPath: "status")
		if let observer = timeObserver {
			videoPlayerLayer.player?.removeTimeObserver(observer)
			timeObserver = nil
		}
	}
	
	@objc internal func itemDidFinishPlaying(notification: NSNotification) {
		let currentItem = videoPlayerLayer.player?.currentItem
		let notificationObject = notification.object as! AVPlayerItem
		
		finishedVideo?()
		dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
			if currentItem == notificationObject && self?.shouldLoop == true {
				self?.seek(0.0)
				self?.videoPlayerLayer.player?.rate = 1.0
			}
			})
	}
}
