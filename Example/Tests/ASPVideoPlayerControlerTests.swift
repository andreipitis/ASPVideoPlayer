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
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		videoPlayer.seek(0.5)
		let initialProgress = videoPlayer.progress
		
		sut.jumpForward()
		
		XCTAssertGreaterThan(sut.videoPlayer!.progress, initialProgress, "Video jumped forwards.")
	}
	
	func testJumpBackwardCalled_ShouldJumpVideoPlaybackBackward() {
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		videoPlayer.seek(0.5)
		let initialProgress = videoPlayer.progress
		
		sut.jumpBackward()
		
		XCTAssertLessThan(sut.videoPlayer!.progress, initialProgress, "Video jumped backwards.")
	}
	
	func testVolumeSet_ShouldChangeVolumeToNewValue () {
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)

		sut.volume(0.5)
		
		XCTAssertEqual(sut.videoPlayer!.volume, 0.5, "Video volume set.")
	}
	
	func testSeekToSpecificLocation_ShouldSeekVideoToPercentage() {
		let videoPlayer = ASPVideoPlayerView()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		let minimumValue = 0.0
		let maximumValue = 3.0
		let value = 1.5
		
		sut.seek(min: minimumValue, max: maximumValue, value: value)
		XCTAssertEqual(sut.videoPlayer!.progress, 0.5, "Video set to specified percentage.")
	}
	
//	func testPressPlayButton_ShouldStartVideoPlayback() {
//		let videoPlayer = ASPVideoPlayerView()
//		videoPlayer.videoURL = videoURL
//		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
//		sut.playButtonPressed()
//		
//		XCTAssertEqual(sut.videoPlayer?.status, ASPVideoPlayerView.PlayerStatus.playing, "Video is playing.")
//	}
//	
//	func testPressPlayButtonWhileVideoIsPlaying_ShouldPauseVideoPlayback() {
//		let videoPlayer = ASPVideoPlayerView()
//		videoPlayer.videoURL = videoURL
//		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
//		sut.playButtonPressed()
//		sut.playButtonPressed()
//		
//		XCTAssertEqual(sut.videoPlayer?.status, ASPVideoPlayerView.PlayerStatus.paused, "Video is paused.")
//	}
	
//	func testPressStopButton_ShouldStopVideoPlayback() {
//		let videoPlayer = ASPVideoPlayerView()
//		videoPlayer.videoURL = videoURL
//		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
//		
//		sut.stopButtonPressed()
//		
//		XCTAssertEqual(sut.videoPlayer?.status, ASPVideoPlayerView.PlayerStatus.stopped, "Video playback has stopped.")
//	}
//	
//	func testPressJumpForwardButton_ShouldStopVideoPlayback() {
//		let videoPlayer = ASPVideoPlayerView()
//		videoPlayer.videoURL = videoURL
//		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
//		videoPlayer.seek(0.5)
//		let initialProgress = videoPlayer.progress
//		
//		sut.forwardButtonPressed()
//		
//		XCTAssertGreaterThan(sut.videoPlayer!.progress, initialProgress, "Video jumped forward.")
//	}
//	
//	func testPressJumpBackwardButton_ShouldStopVideoPlayback() {
//		let videoPlayer = ASPVideoPlayerView()
//		videoPlayer.videoURL = videoURL
//		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
//		videoPlayer.seek(0.5)
//		let initialProgress = videoPlayer.progress
//		
//		sut.backwardButtonPressed()
//		
//		XCTAssertLessThan(sut.videoPlayer!.progress, initialProgress, "Video jumped backwards.")
//	}
}
