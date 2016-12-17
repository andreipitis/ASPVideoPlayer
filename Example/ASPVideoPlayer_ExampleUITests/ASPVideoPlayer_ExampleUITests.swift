//
//  ASPVideoPlayer_ExampleUITests.swift
//  ASPVideoPlayer_ExampleUITests
//
//  Created by Andrei-Sergiu Pițiș on 17/12/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

class ASPVideoPlayer_ExampleUITests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		
		// Put setup code here. This method is called before the invocation of each test method in the class.
		
		// In UI tests it is usually best to stop immediately when a failure occurs.
		continueAfterFailure = false
		// UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
		XCUIApplication().launch()
		
		// In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testPressPlayButtons_ShouldSelectPlayButton() {
		let element = XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
		let button = element.children(matching: .other).element(boundBy: 1).children(matching: .button).element(boundBy: 0)
		button.tap()

		XCTAssertEqual(button.isSelected, true, "Button is not selected.")
	}
	
	func testAdjustScrubber_ShouldSeekVideo() {
		let app = XCUIApplication()
		app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).swipeRight()
		
		let labelValue = app.staticTexts.element(boundBy: 0).label
		
		XCTAssertNotEqual(labelValue, "00:00:00", "Values are equal.")
	}
	
	func testTapVideo_ShouldHideControls() {
		let element = XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1)
		let button = element.children(matching: .button).element(boundBy: 0)
		button.tap()
		
		sleep(4)

		XCTAssertEqual(element.exists, false, "Controls are visible.")
	}
	
	func testTapVideoWhenControlsHidden_ShouldShowControls() {
		let element = XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
		let button = element.children(matching: .other).element(boundBy: 1).children(matching: .button).element(boundBy: 0)
		button.tap()
		
		sleep(4)
		
		element.children(matching: .other).element.tap()

		XCTAssertEqual(element.exists, true, "Controls are not visible.")
	}
}
