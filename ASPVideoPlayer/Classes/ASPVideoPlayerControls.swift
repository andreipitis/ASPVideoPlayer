//
//  ASPVideoPlayerControls.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 12/04/16.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import UIKit

public protocol VideoPlayerControls {
	weak var videoPlayer: ASPVideoPlayer? {get set}
	
	func play()
	func pause()
	func stop()
	func jumpForward()
	func jumpBackward()
	func volume(value: Float)
}

public protocol VideoPlayerSeekControls {
	weak var videoPlayer: ASPVideoPlayer? {get set}
	
	func seek(min: Double, max: Double, value: Double)
}

public extension VideoPlayerSeekControls {
	func seek(min: Double = 0.0, max: Double = 1.0, value: Double) {
		let value = rangeMap(value, min: min, max: max, newMin: 0.0, newMax: 1.0)
		videoPlayer?.seek(Double(value))
	}
	
	private func rangeMap(value: Double, min: Double, max: Double, newMin: Double, newMax: Double) -> Double {
		return (((value - min) * (newMax - newMin)) / (max - min)) + newMin
	}
}

public extension VideoPlayerControls {
	func play() {
		videoPlayer?.playVideo()
	}
	
	func pause() {
		videoPlayer?.pauseVideo()
	}
	
	func stop() {
		videoPlayer?.stopVideo()
	}
	
	func jumpForward() {
		if let currentPercentage = videoPlayer?.progress {
			let newPercentage = min(1.0, max(0.0, currentPercentage + 0.05))
			videoPlayer?.seek(newPercentage)
		}
	}
	
	func jumpBackward() {
		if let currentPercentage = videoPlayer?.progress {
			let newPercentage = min(1.0, max(0.0, currentPercentage - 0.05))
			videoPlayer?.seek(newPercentage)
		}
	}
	
	func volume(value: Float) {
		videoPlayer?.volume = value
	}
}

@IBDesignable public class ASPVideoPlayerControls: UIView, VideoPlayerControls, VideoPlayerSeekControls {
	
	@IBOutlet public weak var videoPlayer: ASPVideoPlayer?
	
	public let playPauseButton = UIButton()
	public let forwardButton = UIButton()
	public let backwardButton = UIButton()
	public let stopButton = UIButton()
	
	public override init(frame: CGRect) {
		super.init(frame: frame)

		commonInit()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		commonInit()
	}
	
	convenience init(videoPlayer: ASPVideoPlayer) {
		self.init(frame: CGRectZero)
		self.videoPlayer = videoPlayer
		
		commonInit()
	}
	
	func playButtonPressed() {
		play()
	}
	
	func stopButtonPressed() {
		stop()
	}
	
	func forwardButtonPressed() {
		jumpForward()
	}
	
	func backwardButtonPressed() {
		jumpBackward()
	}

	private func commonInit() {
		playPauseButton.translatesAutoresizingMaskIntoConstraints = false
		stopButton.translatesAutoresizingMaskIntoConstraints = false
		forwardButton.translatesAutoresizingMaskIntoConstraints = false
		backwardButton.translatesAutoresizingMaskIntoConstraints = false
		
		playPauseButton.backgroundColor = .blackColor()
		stopButton.backgroundColor = .yellowColor()
		forwardButton.backgroundColor = .greenColor()
		backwardButton.backgroundColor = .purpleColor()
		
		playPauseButton.addTarget(self, action: #selector(ASPVideoPlayerControls.playButtonPressed), forControlEvents: .TouchUpInside)
		stopButton.addTarget(self, action: #selector(ASPVideoPlayerControls.stopButtonPressed), forControlEvents: .TouchUpInside)
		forwardButton.addTarget(self, action: #selector(ASPVideoPlayerControls.forwardButtonPressed), forControlEvents: .TouchUpInside)
		backwardButton.addTarget(self, action: #selector(ASPVideoPlayerControls.backwardButtonPressed), forControlEvents: .TouchUpInside)
		
		addSubview(playPauseButton)
		addSubview(stopButton)
		addSubview(forwardButton)
		addSubview(backwardButton)
		
		setupLayout()
	}
	
	private func setupLayout() {
		let viewsDictionary = ["playPauseButton":playPauseButton,
		                       "forwardButton":forwardButton,
		                       "backwardButton":backwardButton,
		                       "stopButton":stopButton]
		
		var constraintsArray = [NSLayoutConstraint]()
		
		constraintsArray.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[backwardButton(==forwardButton)]-[stopButton(==forwardButton)]-[playPauseButton(==forwardButton)]-[forwardButton]-|", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[backwardButton]-|", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[stopButton]-|", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[playPauseButton]-|", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[forwardButton]-|", options: [], metrics: nil, views: viewsDictionary))
		
		addConstraints(constraintsArray)
	}
}
