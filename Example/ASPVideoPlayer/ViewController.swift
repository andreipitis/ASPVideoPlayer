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
	
	let videoURL = NSBundle.mainBundle().URLForResource("video", withExtension: "mov")
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		self.videoPlayer.videoURL = videoURL
		self.videoPlayer.gravity = .AspectFit
		//        self.videoPlayer.startPlayingWhenReady = true
		self.videoPlayer.shouldLoop = true
		
		self.videoPlayer.backgroundColor = UIColor.blackColor()
		
		self.videoPlayer.newVideo = {
			print("newVideo")
		}
		
		self.videoPlayer.readyToPlayVideo = {
			print("readyToPlay")
			//            self.videoPlayer.playVideo()
		}
		
		self.videoPlayer.startedVideo = {
			print("start")
			
		}
		
		self.videoPlayer.finishedVideo = {
			print("finishedVideo")
			
			//            UIView.animateWithDuration(1.3, delay: 0.0, options: .CurveEaseIn, animations: {
			//                self.videoTopConstraint.constant = 0
			//				self.videoBottomConstraint.constant = 0
			//				self.videoLeadingConstraint.constant = 0
			//				self.videoTrailingConstraint.constant = 0
			//				self.view.layoutIfNeeded()
			//                }, completion: { (finished) in
			//                    UIView.animateWithDuration(1.3, delay: 2.0, options: .CurveEaseIn, animations: {
			//
			//						self.videoTopConstraint.constant = 50
			//						self.videoBottomConstraint.constant = 50
			//						self.videoLeadingConstraint.constant = 50
			//						self.videoTrailingConstraint.constant = 50
			//
			//						self.view.layoutIfNeeded()
			//                        }, completion: { (finished) in
			//
			//                    })
			//            })
		}
		
		self.videoPlayer.playingVideo = { (progress) -> Void in
			print("progress: \(progress)")
			
			//            self.videoPlayer.pauseVideo()
		}
		
		self.videoPlayer.pausedVideo = {
			print("paused")
			//            self.videoPlayer.stopVideo()
		}
		
		self.videoPlayer.stoppedVideo = {
			print("stopped")
			//            self.videoPlayer.playVideo()
		}
		
		self.videoPlayer.error = { (error) -> Void in
			print("Error: \(error.localizedDescription)")
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

