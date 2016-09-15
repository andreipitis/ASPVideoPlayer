//
//  ASPVideoPlayerControlerTests.swift
//  ASPVideoPlayer
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
		
		videoURL = Bundle.main.url(forResource: "video", withExtension: "mov")
	}
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testInitPlayerControler_ShouldSetWeakReferenceToViedeoPlayer() {
		let videoPlayer = ASPVideoPlayer()
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		XCTAssertEqual(sut.videoPlayer, videoPlayer, "Players are equal.")
	}
    
	func testPlayCalled_ShoudStartVideoPlayback() {
		let videoPlayer = ASPVideoPlayer()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.play()
		
		XCTAssertEqual(sut.videoPlayer?.status, ASPVideoPlayer.PlayerStatus.playing, "Video is playing.")
	}
	
	func testPauseCalled_ShouldPauseVideoPlayback() {
		let videoPlayer = ASPVideoPlayer()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.pause()
		
		XCTAssertEqual(sut.videoPlayer?.status, ASPVideoPlayer.PlayerStatus.paused, "Video is paused.")
	}
	
	func testStopCalled_ShouldStopVideoPlayback() {
		let videoPlayer = ASPVideoPlayer()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		sut.stop()
		
		XCTAssertEqual(sut.videoPlayer?.status, ASPVideoPlayer.PlayerStatus.stopped, "Video is stopped.")
	}
 
	func testJumpForwardCalled_ShouldJumpVideoPlaybackForward() {
		let videoPlayer = ASPVideoPlayer()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		videoPlayer.seek(0.5)
		let initialProgress = videoPlayer.progress
		
		sut.jumpForward()
		
		XCTAssertGreaterThan(sut.videoPlayer!.progress, initialProgress, "Video jumped forwards.")
	}
	
	func testJumpBackwardCalled_ShouldJumpVideoPlaybackBackward() {
		let videoPlayer = ASPVideoPlayer()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		videoPlayer.seek(0.5)
		let initialProgress = videoPlayer.progress
		
		sut.jumpBackward()
		
		XCTAssertLessThan(sut.videoPlayer!.progress, initialProgress, "Video jumped backwards.")
	}
	
	func testVolumeSet_ShouldChangeVolumeToNewValue () {
		let videoPlayer = ASPVideoPlayer()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)

		sut.volume(0.5)
		
		XCTAssertEqual(sut.videoPlayer!.volume, 0.5, "Video volume set.")
	}
	
	func testSeekToSpecificLocation_ShouldSeekVideoToPercentage() {
		let videoPlayer = ASPVideoPlayer()
		videoPlayer.videoURL = videoURL
		let sut = ASPVideoPlayerControls(videoPlayer: videoPlayer)
		
		let minimumValue = 0.0
		let maximumValue = 3.0
		let value = 1.5
		
		sut.seek(minimumValue, max: maximumValue, value: value)
		XCTAssertEqual(sut.videoPlayer!.progress, 0.5, "Video set to specified percentage.")
	}
}
