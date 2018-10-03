//
//  ASPVideoPlayerTests.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 17/12/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
@testable import ASPVideoPlayer

class ASPVideoPlayerTests: XCTestCase {

    var videoURL: URL!
    var invalidVideoURL: URL!

    override func setUp() {
        super.setUp()

        videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")
        invalidVideoURL = URL(string: "www.google.com")
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSetConfiguration_ShouldSetConfiguration() {
        let sut = ASPVideoPlayer()

        let configuration = ASPVideoPlayer.Configuration(videoGravity: .aspectFill, shouldLoop: true, startPlayingWhenReady: false, controlsInitiallyHidden: true)

        sut.configuration = configuration

        XCTAssertEqual(sut.configuration.videoGravity, configuration.videoGravity, "Player gravity not set correctly.")
        XCTAssertEqual(sut.configuration.shouldLoop, configuration.shouldLoop, "Player shouldLoop not set correctly.")
        XCTAssertEqual(sut.configuration.startPlayingWhenReady, configuration.startPlayingWhenReady, "Player startPlayingWhenReady not set correctly.")
        XCTAssertEqual(sut.configuration.controlsInitiallyHidden, configuration.controlsInitiallyHidden, "Player controlsInitiallyHidden not set correctly.")
    }

    func testSetVideoURLs_ShouldSetVideoURLs() {
        let sut = ASPVideoPlayer()

        sut.videoURLs = [videoURL]

        XCTAssertEqual(sut.videoURLs.first, videoURL, "Player URLs not set correctly.")
        XCTAssertEqual(sut.videoURLs.count, 1, "Player URLs not set correctly.")
    }

    func testSetTintColor_ShouldSetTintColorForVideoControls() {
        let sut = ASPVideoPlayer()

        sut.tintColor = UIColor.blue

        XCTAssertEqual(sut.tintColor, UIColor.blue, "Player tint color not set correctly.")
        XCTAssertEqual(sut.tintColor, sut.videoPlayerControls.tintColor, "Player tint color not set correctly.")
    }

    func testApplicationDidEnterBackgroundReceived_ShouldPauseVideo() {
        let sut = ASPVideoPlayer()
        sut.videoURLs = [videoURL]
        sut.videoPlayerControls.play()

        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)

        XCTAssertEqual(sut.videoPlayerControls.videoPlayer?.status, .paused, "Video is not paused.")
    }

    func testControlsVisibleAndPlayerRunningToggleControls_ShouldHideControls() {
        let sut = ASPVideoPlayer()
        sut.videoURLs = [videoURL]
        sut.videoPlayerControls.play()
        sut.toggleControls()

        XCTAssertEqual(sut.videoPlayerControls.alpha, 0.0, "Player controls are visible.")
    }

    func testControlsHiddenAndPlayerRunningToggleControls_ShouldShowControls() {
        let sut = ASPVideoPlayer()
        sut.videoURLs = [videoURL]
        sut.videoPlayerControls.play()
        sut.hideControls()

        sut.toggleControls()

        XCTAssertEqual(sut.videoPlayerControls.alpha, 1.0, "Player controls are not visible.")
    }

    func testResize_ShouldCallResizeCallback() {
        let expectation = self.expectation(description: "Timeout expectation")

        let expanded = true

        let sut = ASPVideoPlayer()
        sut.videoURLs = [videoURL]
        sut.resizeClosure = { isExpanded in
            XCTAssertEqual(isExpanded, expanded)
            expectation.fulfill()
        }

        sut.videoPlayerControls.didPressResizeButton?(expanded)

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    //Delegate tests

    func testLoadValidURL_ShouldCallReadyToPlayVideoDelegateMethod() {
        class TestDelegate: ASPVideoPlayerViewDelegate {
            var asyncExpectation: XCTestExpectation?

            func readyToPlayVideo() {
                guard let _ = asyncExpectation else {
                    XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                asyncExpectation?.fulfill()
            }
        }

        let delegate: TestDelegate = TestDelegate()
        delegate.asyncExpectation = self.expectation(description: "Timeout expectation")

        let sut = ASPVideoPlayer()
        sut.delegate = delegate
        sut.videoURLs = [videoURL]

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testLoadValidURL_ShouldCallNewVideoDelegateMethod() {
        class TestDelegate: ASPVideoPlayerViewDelegate {
            var asyncExpectation: XCTestExpectation?

            func newVideo() {
                guard let _ = asyncExpectation else {
                    XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                asyncExpectation?.fulfill()
            }
        }

        let delegate: TestDelegate = TestDelegate()
        delegate.asyncExpectation = self.expectation(description: "Timeout expectation")

        let sut = ASPVideoPlayer()
        sut.delegate = delegate
        sut.videoURLs = [videoURL]

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testStartVideo_ShouldCallStartedVideoDelegateMethod() {
        class TestDelegate: ASPVideoPlayerViewDelegate {
            var asyncExpectation: XCTestExpectation?

            func startedVideo() {
                guard let _ = asyncExpectation else {
                    XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                asyncExpectation?.fulfill()
            }
        }

        let delegate: TestDelegate = TestDelegate()
        delegate.asyncExpectation = self.expectation(description: "Timeout expectation")

        let sut = ASPVideoPlayer()
        sut.delegate = delegate
        sut.videoURLs = [videoURL]
        sut.videoPlayerControls.play()

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testStartVideo_ShouldCallPlayingVideoDelegateMethod() {
        class TestDelegate: ASPVideoPlayerViewDelegate {
            var asyncExpectation: XCTestExpectation?

            func playingVideo(progress: Double) {
                guard let _ = asyncExpectation else {
                    XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                asyncExpectation?.fulfill()
            }
        }

        let delegate: TestDelegate = TestDelegate()
        delegate.asyncExpectation = self.expectation(description: "Timeout expectation")

        let sut = ASPVideoPlayer()
        sut.delegate = delegate
        sut.videoURLs = [videoURL]

        sut.videoPlayerControls.play()

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testPauseVideo_ShouldCallPausedVideoDelegateMethod() {
        class TestDelegate: ASPVideoPlayerViewDelegate {
            var asyncExpectation: XCTestExpectation?

            func pausedVideo() {
                guard let _ = asyncExpectation else {
                    XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                asyncExpectation?.fulfill()
            }
        }

        let delegate: TestDelegate = TestDelegate()
        delegate.asyncExpectation = self.expectation(description: "Timeout expectation")

        let sut = ASPVideoPlayer()
        sut.delegate = delegate
        sut.videoURLs = [videoURL]

        sut.videoPlayerControls.pause()

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testStopVideo_ShouldCallStoppedVideoDelegateMethod() {
        class TestDelegate: ASPVideoPlayerViewDelegate {
            var asyncExpectation: XCTestExpectation?

            func stoppedVideo() {
                guard let _ = asyncExpectation else {
                    XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                asyncExpectation?.fulfill()
            }
        }

        let delegate: TestDelegate = TestDelegate()
        delegate.asyncExpectation = self.expectation(description: "Timeout expectation")

        let sut = ASPVideoPlayer()
        sut.delegate = delegate
        sut.videoURLs = [videoURL]

        sut.videoPlayerControls.stop()

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testFinishVideo_ShouldCallFinishedVideoDelegateMethod() {
        class TestDelegate: ASPVideoPlayerViewDelegate {
            var asyncExpectation: XCTestExpectation?

            func finishedVideo() {
                guard let _ = asyncExpectation else {
                    XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                asyncExpectation?.fulfill()
            }
        }

        let delegate: TestDelegate = TestDelegate()
        delegate.asyncExpectation = self.expectation(description: "Timeout expectation")

        let sut = ASPVideoPlayer()
        sut.delegate = delegate
        sut.videoURLs = [videoURL]

        sut.videoPlayerControls.play()
        sut.videoPlayerControls.seek(value: 0.99)

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testLoadedInvalidURL_ShouldCallErrorDelegateMethod() {
        class TestDelegate: ASPVideoPlayerViewDelegate {
            var asyncExpectation: XCTestExpectation?

            func error(error: Error) {
                guard let _ = asyncExpectation else {
                    XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                asyncExpectation?.fulfill()
            }
        }

        let delegate: TestDelegate = TestDelegate()
        delegate.asyncExpectation = self.expectation(description: "Timeout expectation")

        let sut = ASPVideoPlayer()
        sut.delegate = delegate
        sut.videoURLs = [invalidVideoURL]

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testSeekVideo_ShouldCallSeekEndedDelegateMethod() {
        class TestDelegate: ASPVideoPlayerViewDelegate {
            var asyncExpectation: XCTestExpectation?

            func seekEnded() {
                guard let _ = asyncExpectation else {
                    XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                asyncExpectation?.fulfill()
            }
        }

        let delegate: TestDelegate = TestDelegate()
        delegate.asyncExpectation = self.expectation(description: "Timeout expectation")

        let sut = ASPVideoPlayer()
        sut.delegate = delegate
        sut.videoURLs = [videoURL]

        sut.videoPlayerControls.play()
        sut.videoPlayerControls.seek(value: 0.5)

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testShowControls_ShouldCallWillShowControlsDelegateMethod() {
        class TestDelegate: ASPVideoPlayerViewDelegate {
            var asyncExpectation: XCTestExpectation?

            func willShowControls() {
                guard let _ = asyncExpectation else {
                    XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                asyncExpectation?.fulfill()
            }
        }

        let delegate: TestDelegate = TestDelegate()
        delegate.asyncExpectation = self.expectation(description: "Timeout expectation")

        let sut = ASPVideoPlayer()
        sut.delegate = delegate
        sut.videoURLs = [videoURL]

        sut.showControls()

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testShowControls_ShouldCallDidShowControlsDelegateMethod() {
        class TestDelegate: ASPVideoPlayerViewDelegate {
            var asyncExpectation: XCTestExpectation?

            func didShowControls() {
                guard let _ = asyncExpectation else {
                    XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                asyncExpectation?.fulfill()
            }
        }

        let delegate: TestDelegate = TestDelegate()
        delegate.asyncExpectation = self.expectation(description: "Timeout expectation")

        let sut = ASPVideoPlayer()
        sut.delegate = delegate
        sut.videoURLs = [videoURL]

        sut.showControls()

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testHideControls_ShouldCallWillHideControlsDelegateMethod() {
        class TestDelegate: ASPVideoPlayerViewDelegate {
            var asyncExpectation: XCTestExpectation?

            func willHideControls() {
                guard let _ = asyncExpectation else {
                    XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                asyncExpectation?.fulfill()
            }
        }

        let delegate: TestDelegate = TestDelegate()
        delegate.asyncExpectation = self.expectation(description: "Timeout expectation")

        let sut = ASPVideoPlayer()
        sut.delegate = delegate
        sut.videoURLs = [videoURL]

        sut.hideControls()

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testHideControls_ShouldCallDidHideControlsDelegateMethod() {
        class TestDelegate: ASPVideoPlayerViewDelegate {
            var asyncExpectation: XCTestExpectation?

            func didHideControls() {
                guard let _ = asyncExpectation else {
                    XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                asyncExpectation?.fulfill()
            }
        }

        let delegate: TestDelegate = TestDelegate()
        delegate.asyncExpectation = self.expectation(description: "Timeout expectation")

        let sut = ASPVideoPlayer()
        sut.delegate = delegate
        sut.videoURLs = [videoURL]

        sut.hideControls()

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
}
