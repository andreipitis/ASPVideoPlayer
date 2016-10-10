//
//  ASPVideoPlayerTests.swift
//  ASPVideoPlayerTests
//
//  Created by Andrei-Sergiu Pițiș on 28/03/16.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import XCTest
@testable import ASPVideoPlayer

class ASPVideoPlayerTests: XCTestCase {
	
	var videoURL: URL!
	
	override func setUp() {
		super.setUp()
		
		videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testInitWithFrame_CreatesPlayerWithFrame() {
		let frame = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
		let player = ASPVideoPlayer(frame: frame)
		
		XCTAssertEqual(player.frame, frame, "Frames are equal.")
	}
	
	func testDeinitCalled_ShouldDeallocatePlayer() {
		weak var player = ASPVideoPlayer()
		
		XCTAssertNil(player, "Player deallocated.")
	}
	
	func testSetVolumeAboveMaximum_ShouldSetPlayerVolumeToMaximum() {
		let player = ASPVideoPlayer()
		player.videoURL = videoURL
		player.volume = 2.0
		
		XCTAssertEqual(player.volume, 1.0, "Volume set to maximum.")
	}
	
	func testSetVolumeBelowMaximum_ShouldSetPlayerVolumeToMinimum() {
		let player = ASPVideoPlayer()
		player.videoURL = videoURL
		player.volume = -1.0
		
		XCTAssertEqual(player.volume, 0.0, "Volume set to minimum.")
	}
	
	func testSetVolumeURLNotSet_ShouldSetPlayerVolumeToMinimum() {
		let player = ASPVideoPlayer()
		
		player.volume = -1.0
		
		XCTAssertEqual(player.volume, 0.0, "Volume set to minimum.")
	}
	
	func testSetGravityAspectFill_ShouldChangeGravityToAspectFill() {
		let player = ASPVideoPlayer()
		
		player.gravity = .aspectFill
		
		XCTAssertEqual(player.gravity, ASPVideoPlayer.PlayerContentMode.aspectFill, "Content Mode is AspectFill.")
	}
	
	func testSetGravityResize_ShouldChangeGravityToResize() {
		let player = ASPVideoPlayer()
		
		player.gravity = .resize
		
		XCTAssertEqual(player.gravity, ASPVideoPlayer.PlayerContentMode.resize, "Content Mode is Resize.")
	}
	
	func testLoadVideoURLWithInvalidURL_ShouldSetVideoURLToNil() {
		let player = ASPVideoPlayer()
		player.error = { (error) in
			XCTAssertNil(player.videoURL, "Video URL is nil.")
			XCTAssertEqual(error.localizedDescription, "Video URL is invalid.")
		}
		player.videoURL = nil
	}
	
	func testLoadVideoURL_ShouldLoadVideoAtURL() {
		let expectation = self.expectation(description: "Timeout expectation")
		
		let player = ASPVideoPlayer()
		player.newVideo = { [weak expectation] in
            XCTAssertEqual(player.status, ASPVideoPlayer.PlayerStatus.new)
			XCTAssertNotNil(player.videoURL, "Video URL is not nil.")
			expectation?.fulfill()
		}
		
		player.videoURL = videoURL
		
		waitForExpectations(timeout: 5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testLoadVideoAndStartPlayingWhenReadySet_ShouldChangeStateToPlaying() {
		let expectation = self.expectation(description: "Timeout expectation")
		
		let player = ASPVideoPlayer()
		
		player.startPlayingWhenReady = true
		
		player.startedVideo = { [weak expectation] in
			XCTAssertEqual(player.status, ASPVideoPlayer.PlayerStatus.playing, "Video is playing.")
			expectation?.fulfill()
		}
		
		player.videoURL = videoURL
		
		waitForExpectations(timeout: 5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
		
	func testSeekToPercentageBelowMinimum_ShouldSetCurrentTimeToZero() {
		let expectation = self.expectation(description: "Timeout expectation")
		
		let player = ASPVideoPlayer()
		player.videoURL = videoURL
		player.readyToPlayVideo = {
			player.seek(-1.0)
			player.pauseVideo()
		}
		
		player.pausedVideo = { [weak expectation] in
			XCTAssertEqual(player.currentTime, 0.0)
			expectation?.fulfill()
		}
		
		waitForExpectations(timeout: 5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
		
	func testPlayVideo_ShouldStartVideoPlayback() {
		let expectation = self.expectation(description: "Timeout expectation")
		
		let player = ASPVideoPlayer()
		player.videoURL = videoURL
		player.readyToPlayVideo = {
			player.playVideo()
		}
		
		player.playingVideo = { [weak expectation] (progress) in
			XCTAssertEqual(player.status, ASPVideoPlayer.PlayerStatus.playing)
			player.stopVideo()
			expectation?.fulfill()
		}
		
		waitForExpectations(timeout: 5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testPlayFinishedVideo_ShouldStartVideoPlaybackFromBeginning() {
		let expectation = self.expectation(description: "Timeout expectation")
		
		let player = ASPVideoPlayer()
		player.videoURL = videoURL
		player.readyToPlayVideo = {
			player.playVideo()
		}
		
		player.playingVideo = { [weak expectation] (progress) in
			XCTAssertEqual(player.status, ASPVideoPlayer.PlayerStatus.playing)
			player.stopVideo()
			expectation?.fulfill()
		}
		
		waitForExpectations(timeout: 5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testStopVideo_ShouldStopVideo() {
		let expectation = self.expectation(description: "Timeout expectation")
		
		let player = ASPVideoPlayer()
		player.videoURL = videoURL
		player.readyToPlayVideo = {
			player.playVideo()
		}
		
		player.playingVideo = { (progress) in
			player.stopVideo()
		}
		
		player.stoppedVideo = { [weak expectation] in
			XCTAssertEqual(player.status, ASPVideoPlayer.PlayerStatus.stopped)
			expectation?.fulfill()
		}
		
		waitForExpectations(timeout: 5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testShouldLoopSet_ShouldLoopVideoWhenFinished() {
		let expectation = self.expectation(description: "Timeout expectationShouldLoop")
		let player = ASPVideoPlayer()
		player.shouldLoop = true
		player.startPlayingWhenReady = true
		player.videoURL = videoURL
		
		player.finishedVideo = {
			XCTAssertEqual(player.status, ASPVideoPlayer.PlayerStatus.playing)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 20.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
}
