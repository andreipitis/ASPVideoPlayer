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
	
	var videoURL: NSURL!
	
	override func setUp() {
		super.setUp()
		
		videoURL = NSBundle.mainBundle().URLForResource("video", withExtension: "mov")
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
		
		player.gravity = .AspectFill
		
		XCTAssertEqual(player.gravity, ASPVideoPlayer.PlayerContentMode.AspectFill, "Content Mode is AspectFill.")
	}
	
	func testSetGravityResize_ShouldChangeGravityToResize() {
		let player = ASPVideoPlayer()
		
		player.gravity = .Resize
		
		XCTAssertEqual(player.gravity, ASPVideoPlayer.PlayerContentMode.Resize, "Content Mode is Resize.")
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
		let expectation = expectationWithDescription("Timeout expectation")
		
		let player = ASPVideoPlayer()
		player.newVideo = { [weak expectation] in
			XCTAssertNotNil(player.videoURL, "Video URL is not nil.")
			XCTAssertEqual(player.status, ASPVideoPlayer.PlayerStatus.New)
			expectation?.fulfill()
		}
		
		player.videoURL = videoURL
		
		waitForExpectationsWithTimeout(5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testLoadVideoAndStartPlayingWhenReadySet_ShouldChangeStateToPlaying() {
		let expectation = expectationWithDescription("Timeout expectation")
		
		let player = ASPVideoPlayer()
		
		player.startPlayingWhenReady = true
		
		player.startedVideo = { [weak expectation] in
			XCTAssertEqual(player.status, ASPVideoPlayer.PlayerStatus.Playing, "Video is playing.")
			expectation?.fulfill()
		}
		
		player.videoURL = videoURL
		
		waitForExpectationsWithTimeout(5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testSeekToPercentage_ShouldSetCurrentTimeDifferentThanZero() {
		let expectation = expectationWithDescription("Timeout expectation")
		
		let player = ASPVideoPlayer()
		player.videoURL = videoURL
		player.readyToPlayVideo = {
			player.seek(0.5)
			player.pauseVideo()
		}
		
		player.pausedVideo = { [weak expectation] in
			XCTAssertEqual(player.currentTime, player.videoLength * 0.5)
			expectation?.fulfill()
		}
		
		waitForExpectationsWithTimeout(5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testSeekToPercentageBelowMinimum_ShouldSetCurrentTimeToZero() {
		let expectation = expectationWithDescription("Timeout expectation")
		
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
		
		waitForExpectationsWithTimeout(5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testSeekToPercentageAboveMaximum_ShouldSetCurrentTimeToMaximum() {
		let expectation = expectationWithDescription("Timeout expectation")
		
		let player = ASPVideoPlayer()
		player.videoURL = videoURL
		player.readyToPlayVideo = {
			player.seek(2.0)
			player.pauseVideo()
		}
		
		player.pausedVideo = { [weak expectation] in
			XCTAssertEqual(player.currentTime, player.videoLength)
			expectation?.fulfill()
		}
		
		waitForExpectationsWithTimeout(5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testPlayVideo_ShouldStartVideoPlayback() {
		let expectation = expectationWithDescription("Timeout expectation")
		
		let player = ASPVideoPlayer()
		player.videoURL = videoURL
		player.readyToPlayVideo = {
			player.playVideo()
		}
		
		player.playingVideo = { [weak expectation] (progress) in
			XCTAssertEqual(player.status, ASPVideoPlayer.PlayerStatus.Playing)
			player.stopVideo()
			expectation?.fulfill()
		}
		
		waitForExpectationsWithTimeout(5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testPlayFinishedVideo_ShouldStartVideoPlaybackFromBeginning() {
		let expectation = expectationWithDescription("Timeout expectation")
		
		let player = ASPVideoPlayer()
		player.videoURL = videoURL
		player.readyToPlayVideo = {
			player.playVideo()
		}
		
		player.playingVideo = { [weak expectation] (progress) in
			XCTAssertEqual(player.status, ASPVideoPlayer.PlayerStatus.Playing)
			player.stopVideo()
			expectation?.fulfill()
		}
		
		waitForExpectationsWithTimeout(5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testPauseVideo_ShouldPauseVideoPlaybackAtTimeGreaterThanZero() {
		let expectation = expectationWithDescription("Timeout expectation")
		
		let player = ASPVideoPlayer()
		player.startPlayingWhenReady = true
		player.videoURL = videoURL

		player.finishedVideo = { (progress) in
			player.playVideo()
		}
		
		player.startedVideo = { [weak expectation] in
			XCTAssertEqual(player.currentTime, 0.0)
			XCTAssertEqual(player.status, ASPVideoPlayer.PlayerStatus.Playing)
			expectation?.fulfill()
		}
		
		waitForExpectationsWithTimeout(5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testStopVideo_ShouldStopVideo() {
		let expectation = expectationWithDescription("Timeout expectation")
		
		let player = ASPVideoPlayer()
		player.videoURL = videoURL
		player.readyToPlayVideo = {
			player.playVideo()
		}
		
		player.playingVideo = { (progress) in
			player.stopVideo()
		}
		
		player.stoppedVideo = { [weak expectation] in
			XCTAssertEqual(player.status, ASPVideoPlayer.PlayerStatus.Stopped)
			expectation?.fulfill()
		}
		
		waitForExpectationsWithTimeout(5.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
	
	func testShouldLoopSet_ShouldLoopVideoWhenFinished() {
		let expectation = expectationWithDescription("Timeout expectationShouldLoop")
		let player = ASPVideoPlayer()
		player.shouldLoop = true
		player.startPlayingWhenReady = true
		player.videoURL = videoURL
		
		player.finishedVideo = { [weak expectation] in
			XCTAssertEqual(player.status, ASPVideoPlayer.PlayerStatus.Playing)
			expectation?.fulfill()
		}

		waitForExpectationsWithTimeout(20.0) { (error) in
			if let error = error {
				print(error)
			}
		}
	}
}
