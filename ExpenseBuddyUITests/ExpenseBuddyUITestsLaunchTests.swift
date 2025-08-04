//
//  ExpenseBuddyUITestsLaunchTests.swift
//  ExpenseBuddyUITests
//
//  Created by RajPratapSingh on 31/07/25.
//

import XCTest

final class ExpenseBuddyUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchAndLoginScreenDisplayed() throws {
        let app = XCUIApplication()
        app.launch()

        // Check if Login screen is shown
        let loginTitle = app.staticTexts["Login"]
        XCTAssertTrue(loginTitle.exists, "Login screen is not displayed")

        // Screenshot after launch
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen - Login"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
