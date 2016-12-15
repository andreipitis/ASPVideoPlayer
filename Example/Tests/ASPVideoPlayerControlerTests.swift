//
//  ASPVideoPlayerViewControlerTests.swift
//  ASPVideoPlayerView
//
//  Created by Andrei-Sergiu Pițiș on 12/04/16.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import XCTest
@testable import ASPVideoPlayer

class ASPVideoPlayerControlerTests: XCTestCase {
	
	var videoURL: URL!
	
	override func setUp() {
		super.setUp()
		
		videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testInitPlayerControler_ShouldSetWeakReferenceToViedeoPlayer() {
		let videoPlayer = ASPVideoPlayerView()
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		XCTAssertEqual(sut.videoPlayer, videoPlayer, "Players are equal.")
	}
	
	func testPlayCalled_ShoudStartVideoPlayback() {
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.play()
		
		XCTAssertEqual(sut.videoPlayer?.status, ASPVideoPlayerView.PlayerStatus.playing, "Video is playing.")
	}
	
	func testPauseCalled_ShouldPauseVideoPlayback() {
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.pause()
		
		XCTAssertEqual(sut.videoPlayer?.status, ASPVideoPlayerView.PlayerStatus.paused, "Video is paused.")
	}
	
	func testStopCalled_ShouldStopVideoPlayback() {
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.stop()
		
		XCTAssertEqual(sut.videoPlayer?.status, ASPVideoPlayerView.PlayerStatus.stopped, "Video is stopped.")
	}
 
	func testJumpForwardCalled_ShouldJumpVideoPlaybackForward() {
		let expectation = self.expectation(description: "Timeout expectation")
		
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		videoPlayer.readyToPlayVideo = {
			videoPlayer.seek(0.5)
			let initialProgress = videoPlayer.progress
			
			sut.jumpForward()
			
			XCTAssertGreaterThan(sut.videoPlayer!.progress, initialProgress, "Video jumped forwards.")
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testJumpBackwardCalled_ShouldJumpVideoPlaybackBackward() {
		let expectation = self.expectation(description: "Timeout expectation")
		
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		videoPlayer.readyToPlayVideo = {
			videoPlayer.seek(0.5)
			let initialProgress = videoPlayer.progress
			
			sut.jumpBackward()
			
			XCTAssertLessThan(sut.videoPlayer!.progress, initialProgress, "Video jumped backwards.")
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testVolumeSet_ShouldChangeVolumeToNewValue () {
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.volume(0.5)
		
		XCTAssertEqual(sut.videoPlayer!.volume, 0.5, "Video volume set.")
	}
	
	func testSeekToSpecificLocation_ShouldSeekVideoToPercentage() {
		let expectation = self.expectation(description: "Timeout expectation")
		
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		let minimumValue = 0.0
		let maximumValue = 3.0
		let value = 1.5
		
		videoPlayer.seekEnded = {
			let progress = sut.videoPlayer!.progress
			
			XCTAssertEqual(progress, 0.5, "Video set to specified percentage.")
			expectation.fulfill()
		}
		
		videoPlayer.readyToPlayVideo = {
			sut.seek(min: minimumValue, max: maximumValue, value: value)
		}
		
		waitForExpectations(timeout: 5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
}
