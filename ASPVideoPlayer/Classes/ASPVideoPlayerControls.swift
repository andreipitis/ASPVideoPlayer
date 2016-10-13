//
//  ASPVideoPlayerControls.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 12/04/16.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import UIKit

/**
Protocol defining the player controls behaviour.
*/
public protocol VideoPlayerControls {
	/**
	Reference to the video player.
	*/
	weak var videoPlayer: ASPVideoPlayer? {get set}
	
	/**
	Starts the video playback.
	*/
	func play()
	
	/**
	Pauses the video playback.
	*/
	func pause()
	
	/**
	Stops the video playback.
	*/
	func stop()
	
	/**
	Jumps forward in the video playback.
	- Parameter value: The amount by which the current progress percentage will be increased.
	*/
	func jumpForward(_ value: Double)
	
	/**
	Jumps backwards in the video playback.
	- Parameter value: The amount by which the current progress percentage will be decreased.
	*/
	func jumpBackward(_ value: Double)
	
	/**
	Set the volume of the video.
	- Parameter value: The new volume value.
	*/
	func volume(_ value: Float)
}

/**
Protocol defining the player seek behaviour.
*/
public protocol VideoPlayerSeekControls {
	/**
	Reference to the video player.
	*/
	weak var videoPlayer: ASPVideoPlayer? {get set}
	
	/**
	Set the new position in the video playback.
	- Parameter min: The minimum value of the used range.
	- Parameter max: The maximum value of the used range.
	- Parameter value: The value where the new video position should be, in the range [min, max].
	*/
	func seek(min: Double, max: Double, value: Double)
}

/**
	Default implementation of the `VideoPlayerSeekControls` protocol.
*/
public extension VideoPlayerSeekControls {
	func seek(min: Double = 0.0, max: Double = 1.0, value: Double) {
		let value = rangeMap(value, min: min, max: max, newMin: 0.0, newMax: 1.0)
		videoPlayer?.seek(Double(value))
	}
	
	fileprivate func rangeMap(_ value: Double, min: Double, max: Double, newMin: Double, newMax: Double) -> Double {
		return (((value - min) * (newMax - newMin)) / (max - min)) + newMin
	}
}

/**
Default implementation of the `VideoPlayerControls` protocol.
*/
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
	
	func jumpForward(_ value: Double = 0.05) {
		if let currentPercentage = videoPlayer?.progress {
			let newPercentage = min(1.0, max(0.0, currentPercentage + value))
			videoPlayer?.seek(newPercentage)
		}
	}
	
	func jumpBackward(_ value: Double = 0.05) {
		if let currentPercentage = videoPlayer?.progress {
			let newPercentage = min(1.0, max(0.0, currentPercentage - value))
			videoPlayer?.seek(newPercentage)
		}
	}
	
	func volume(_ value: Float) {
		videoPlayer?.volume = value
	}
}

@IBDesignable open class ASPVideoPlayerControls: UIView, VideoPlayerControls, VideoPlayerSeekControls {
	
	@IBOutlet open weak var videoPlayer: ASPVideoPlayer?
	
	open let playPauseButton = UIButton()
	open let forwardButton = UIButton()
	open let backwardButton = UIButton()
	open let stopButton = UIButton()
	
	public override init(frame: CGRect) {
		super.init(frame: frame)

		commonInit()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		commonInit()
	}
	
	convenience init(videoPlayer: ASPVideoPlayer) {
		self.init(frame: CGRect.zero)
		self.videoPlayer = videoPlayer
		
		commonInit()
	}
	
	func playButtonPressed() {
		if videoPlayer?.status == .playing {
			pause()
		} else {
			play()
		}
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

	fileprivate func commonInit() {
		playPauseButton.translatesAutoresizingMaskIntoConstraints = false
		stopButton.translatesAutoresizingMaskIntoConstraints = false
		forwardButton.translatesAutoresizingMaskIntoConstraints = false
		backwardButton.translatesAutoresizingMaskIntoConstraints = false
		
		playPauseButton.backgroundColor = .black
		stopButton.backgroundColor = .yellow
		forwardButton.backgroundColor = .green
		backwardButton.backgroundColor = .purple
		
		playPauseButton.addTarget(self, action: #selector(ASPVideoPlayerControls.playButtonPressed), for: .touchUpInside)
		stopButton.addTarget(self, action: #selector(ASPVideoPlayerControls.stopButtonPressed), for: .touchUpInside)
		forwardButton.addTarget(self, action: #selector(ASPVideoPlayerControls.forwardButtonPressed), for: .touchUpInside)
		backwardButton.addTarget(self, action: #selector(ASPVideoPlayerControls.backwardButtonPressed), for: .touchUpInside)
		
		addSubview(playPauseButton)
		addSubview(stopButton)
		addSubview(forwardButton)
		addSubview(backwardButton)
		
		setupLayout()
	}
	
	fileprivate func setupLayout() {
		let viewsDictionary = ["playPauseButton":playPauseButton,
		                       "forwardButton":forwardButton,
		                       "backwardButton":backwardButton,
		                       "stopButton":stopButton]
		
		var constraintsArray = [NSLayoutConstraint]()
		
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[backwardButton(==forwardButton)]-[stopButton(==forwardButton)]-[playPauseButton(==forwardButton)]-[forwardButton]-|", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[backwardButton]-|", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[stopButton]-|", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[playPauseButton]-|", options: [], metrics: nil, views: viewsDictionary))
		constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[forwardButton]-|", options: [], metrics: nil, views: viewsDictionary))
		
		addConstraints(constraintsArray)
	}
}
