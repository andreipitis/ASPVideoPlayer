//
//  ASPVideoPlayer_ExampleUITests.swift
//  ASPVideoPlayer_ExampleUITests
//
//  Created by Andrei-Sergiu Pițiș on 17/12/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

class ASPVideoPlayer_ExampleUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        XCUIDevice.shared.orientation = .portrait

        app = XCUIApplication()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPressPlayButtons_ShouldSelectPlayButton() {
        let button = app.buttons["PlayPauseButton"]
        button.tap()

        XCTAssertEqual(button.isSelected, true, "Button is selected.")
    }

    func testAdjustScrubber_ShouldSeekVideo() {
        let app = XCUIApplication()
        let element = app.otherElements["Scrubber"]

        let labelValue = app.staticTexts["CurrentTimeLabel"]

        let startCoordinate = element.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.0))
        let endCoordinate = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.0))

        startCoordinate.press(forDuration: 0.0, thenDragTo: endCoordinate)

        XCTAssertNotEqual(labelValue.label, "00:00:00", "Values are equal.")
    }
}
