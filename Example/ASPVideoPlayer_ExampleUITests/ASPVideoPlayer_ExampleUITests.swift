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
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPressPlayButtons_ShouldSelectPlayButton() {
        let element = XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        let button = element.children(matching: .other).element(boundBy: 1).children(matching: .button).element(boundBy: 0)
        button.tap()

        XCTAssertEqual(button.isSelected, false, "Button is not selected.")
    }

    func testAdjustScrubber_ShouldSeekVideo() {
        let app = XCUIApplication()
        let element = app.children(matching: .window).element(boundBy: 0)
        let labelValue = app.staticTexts.element(boundBy: 0)
        
        let screenSize = element.frame.size
        let scrubberRelativeXOffset = (labelValue.frame.origin.x + labelValue.frame.size.width + 10) / screenSize.width
        let scrubberRelativeYOffset = labelValue.frame.origin.y / screenSize.height
        
        let startCoordinate: XCUICoordinate = element.coordinate(withNormalizedOffset: CGVector(dx: scrubberRelativeXOffset, dy: scrubberRelativeYOffset))
        let destinationCoordinate: XCUICoordinate = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 1.0))
        
        startCoordinate.press(forDuration: 0.0, thenDragTo: destinationCoordinate)

        XCTAssertNotEqual(labelValue.label, "00:00:00", "Values are equal.")
    }
}
