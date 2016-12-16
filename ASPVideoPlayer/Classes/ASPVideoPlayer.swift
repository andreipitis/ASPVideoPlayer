//
//  ASPVideoPlayer.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 09/12/2016.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import UIKit

/**
A video player implementation with basic functionality.
*/
@IBDesignable open class ASPVideoPlayer: UIView {
	
	//MARK: - Private Variables and Constants -
	
	fileprivate var videoPlayerView: ASPVideoPlayerView!
	
	//MARK: - Public Variables -
	
	/**
	Sets the controls to use for the player. By default the controls are ASPVideoPlayerControls.
	*/
	open var videoPlayerControls: ASPBasicControls! {
		didSet {
			videoPlayerControls.videoPlayer = videoPlayerView
			updateControls()
		}
	}
	
	/**
	The duration of the fade animation.
	*/
	open var fadeDuration = 0.3
	
	/**
	An array of URLs that the player will load. Can be local or remote URLs.
	*/
	open var videoURLs: [URL] = [] {
		didSet {
			videoPlayerView.videoURL = videoURLs.first
		}
	}
	
	/**
	The gravity of the video. Adjusts how the video fills the space of the container.
	*/
	open var gravity: ASPVideoPlayerView.PlayerContentMode {
		set {
			videoPlayerView.gravity = newValue
		}
		get {
			return videoPlayerView.gravity
		}
	}
	
	/**
	Sets wether the playlist should loop. Once the last video has finished playing, the first one will start.
	*/
	open var shouldLoop: Bool {
		set {
			videoPlayerView.shouldLoop = newValue
		}
		get {
			return videoPlayerView.shouldLoop
		}
	}
	
	/**
	Sets the color of the controls.
	*/
	override open var tintColor: UIColor! {
		didSet {
			videoPlayerControls.tintColor = tintColor
		}
	}
	
	//MARK: - Superclass methods -
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		commonInit()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		commonInit()
	}
	
	//MARK: - Private methods -
	
	@objc fileprivate func toggleControls() {
		if videoPlayerControls.alpha == 1.0 && videoPlayerView.status == .playing {
			hideControls()
		} else {
			NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ASPVideoPlayer.hideControls), object: nil)
			showControls()
			
			if videoPlayerView.status == .playing {
				perform(#selector(ASPVideoPlayer.hideControls), with: nil, afterDelay: 3.0)
			}
		}
	}
	
	fileprivate func showControls() {
		UIView.animate(withDuration: fadeDuration, animations: {
			self.videoPlayerControls.alpha = 1.0
		})
	}
	
	@objc fileprivate func hideControls() {
		UIView.animate(withDuration: fadeDuration, animations: {
			self.videoPlayerControls.alpha = 0.0
		})
	}
	
	fileprivate func updateControls() {
		videoPlayerControls.tintColor = tintColor
		
		videoPlayerControls.newVideo = {
			if let videoURL = videoPlayerView.videoURL {
				if let currentURLIndex = videoURLs.index(of: videoURL) {
					videoPlayerControls.nextButtonHidden = currentURLIndex == videoURLs.count - 1
					videoPlayerControls.previousButtonHidden = currentURLIndex == 0
				}
			}
		}
		
		videoPlayerControls.finishedVideo = {
			if let videoURL = videoPlayerView.videoURL {
				if videoURL == videoURLs.last && videoPlayerView.shouldLoop == true {
					videoPlayerView.videoURL = videoURLs.first
				} else {
					let currentURLIndex = videoURLs.index(of: videoURL)
					let nextURL = videoURLs[currentURLIndex! + 1]
					
					videoPlayerView.videoURL = nextURL
				}
			}
		}
		
		videoPlayerControls.didPressNextButton = {
			if let videoURL = videoPlayerView.videoURL {
				if let currentURLIndex = videoURLs.index(of: videoURL), currentURLIndex + 1 < videoURLs.count {
					let nextURL = videoURLs[currentURLIndex + 1]
					
					videoPlayerView.videoURL = nextURL
				}
			}
		}
		
		videoPlayerControls.didPressPreviousButton = {
			if let videoURL = videoPlayerView.videoURL {
				if let currentURLIndex = videoURLs.index(of: videoURL), currentURLIndex > 0 {
					let nextURL = videoURLs[currentURLIndex - 1]
					
					videoPlayerView.videoURL = nextURL
				}
			}
		}
		
		videoPlayerControls.interacting = { (isInteracting) in
			if isInteracting == true {
				NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ASPVideoPlayer.hideControls), object: nil)
				showControls()
			} else {
				if videoPlayerView.status == .playing {
					perform(#selector(ASPVideoPlayer.hideControls), with: nil, afterDelay: 3.0)
				}
			}
		}
	}
	
	fileprivate func commonInit() {
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ASPVideoPlayer.toggleControls))
		tapGestureRecognizer.delegate = self
		addGestureRecognizer(tapGestureRecognizer)
		
		videoPlayerView = ASPVideoPlayerView()
		videoPlayerControls = ASPVideoPlayerControls(videoPlayer: videoPlayerView)
		
		videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
		videoPlayerControls.translatesAutoresizingMaskIntoConstraints = false
		
		videoPlayerControls.backgroundColor = UIColor.black.withAlphaComponent(0.15)
		
		updateControls()
		
		addSubview(videoPlayerView)
		addSubview(videoPlayerControls)
		
		setupLayout()
	}
	
	fileprivate func setupLayout() {
		let viewsDictionary: [String: Any] = ["videoPlayerView":videoPlayerView,
		                                      "videoPlayerControls":videoPlayerControls]
		
		var constraintsArray = [NSLayoutConstraint]()
		
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[videoPlayerView]|", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[videoPlayerView]|", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[videoPlayerControls]|", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[videoPlayerControls]|", options: [], metrics: nil, views: viewsDictionary))
		
		addConstraints(constraintsArray)
	}
}

extension ASPVideoPlayer: UIGestureRecognizerDelegate {
	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		if let view = touch.view, view.isDescendant(of: self) == true, view != videoPlayerView, view != videoPlayerControls || touch.location(in: videoPlayerControls).y > videoPlayerControls.bounds.size.height - 50 {
			return false
		} else {
			return true
		}
	}
}
