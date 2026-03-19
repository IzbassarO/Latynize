//
//  LatynizeUITestsLaunchTests.swift
//  LatynizeUITests
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import XCTest

final class LatynizeUITestsLaunchTests: XCTestCase {
    
    override class var runsForEachTargetApplicationUIConfiguration: Bool { true }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-hasCompletedOnboarding", "YES"]
        app.launch()
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    @MainActor
    func testOnboardingLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-hasCompletedOnboarding", "NO"]
        app.launch()
        
        // Should show onboarding
        XCTAssertTrue(app.staticTexts["Latynize"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Kazakh Script Converter"].exists)
        XCTAssertTrue(app.buttons["Continue"].exists)
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Onboarding Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
