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
	@IBOutlet weak var videoPlayer: ASPVideoPlayer!
	
	let firstVideoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")
	let secondVideoURL = Bundle.main.url(forResource: "video2", withExtension: "mp4")
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		self.videoPlayer.videoURL = firstVideoURL
		self.videoPlayer.gravity = .aspectFit
		self.videoPlayer.shouldLoop = true
		
		self.videoPlayer.backgroundColor = UIColor.black
		
		self.videoPlayer.newVideo = {
			print("newVideo")
		}
		
		self.videoPlayer.readyToPlayVideo = {
			print("readyToPlay")
		}
		
		self.videoPlayer.startedVideo = {
			print("start")
			
		}
		
		self.videoPlayer.finishedVideo = {
			print("finishedVideo")
			if self.videoPlayer.videoURL == self.firstVideoURL {
				self.videoPlayer.startPlayingWhenReady = true
				self.videoPlayer.videoURL = self.secondVideoURL
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
		
		self.videoPlayer.playingVideo = { (progress) -> Void in
            let progressString = String.localizedStringWithFormat("%.2f", progress)
			print("progress: \(progressString) % complete.")
		}
		
		self.videoPlayer.pausedVideo = {
			print("paused")
		}
		
		self.videoPlayer.stoppedVideo = {
			print("stopped")
		}
		
		self.videoPlayer.error = { (error) -> Void in
			print("Error: \(error.localizedDescription)")
		}
	}
}

