//
//  ViewController.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pitis on 06/18/2016.
//  Copyright (c) 2016 Andrei-Sergiu Pitis. All rights reserved.
//

import UIKit
import ASPVideoPlayer

class ViewController: UIViewController {
	@IBOutlet weak var videoTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var videoBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var videoLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var videoTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var videoPlayer: ASPVideoPlayerView!
	
	let firstVideoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")
	let secondVideoURL = Bundle.main.url(forResource: "video2", withExtension: "mp4")
	
	override func viewDidLoad() {
		super.viewDidLoad()

		videoPlayer.videoURL = firstVideoURL
		videoPlayer.gravity = .aspectFit
		videoPlayer.shouldLoop = true
		videoPlayer.startPlayingWhenReady = true
		
		videoPlayer.backgroundColor = UIColor.black
		
		videoPlayer.newVideo = {
			print("newVideo")
		}
		
		videoPlayer.readyToPlayVideo = {
			print("readyToPlay")
		}
		
		videoPlayer.startedVideo = {
			print("start")
			
		}
		
		videoPlayer.finishedVideo = {
			print("finishedVideo")
			if videoPlayer.videoURL == firstVideoURL {
				videoPlayer.startPlayingWhenReady = true
				videoPlayer.videoURL = secondVideoURL
			}
			
			UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
				self.videoTopConstraint.constant = 150.0
				self.videoBottomConstraint.constant = 150.0
				self.videoLeadingConstraint.constant = 150.0
				self.videoTrailingConstraint.constant = 150.0
				self.view.layoutIfNeeded()
				}, completion: { (finished) in
					UIView.animate(withDuration: 0.3, delay: 1.0, options: .curveEaseIn, animations: {
						
						self.videoTopConstraint.constant = 0.0
						self.videoBottomConstraint.constant = 0.0
						self.videoLeadingConstraint.constant = 0.0
						self.videoTrailingConstraint.constant = 0.0
						
						self.view.layoutIfNeeded()
						}, completion: { (finished) in
							
					})
			})
		}
		
		videoPlayer.playingVideo = { (progress) -> Void in
            let progressString = String.localizedStringWithFormat("%.2f", progress)
			print("progress: \(progressString) % complete.")
		}
		
		videoPlayer.pausedVideo = {
			print("paused")
		}
		
		videoPlayer.stoppedVideo = {
			print("stopped")
		}
		
		videoPlayer.error = { (error) -> Void in
			print("Error: \(error.localizedDescription)")
		}
	}
}

