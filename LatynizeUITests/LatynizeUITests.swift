//
//  LatynizeUITests.swift
//  LatynizeUITests
//

import XCTest

final class LatynizeUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-hasCompletedOnboarding", "YES"]
        app.launch()
    }
    
    /// Smoke test: app launches and core tabs exist
    func testAppLaunchesWithCoreTabs() {
        XCTAssertTrue(app.tabBars.buttons["Convert"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["Camera"].exists)
        XCTAssertTrue(app.tabBars.buttons["History"].exists)
    }
    
    /// Smoke test: tab switching works
    func testTabsSwitch() {
        app.tabBars.buttons["History"].tap()
        XCTAssertTrue(app.navigationBars["History"].waitForExistence(timeout: 2))
        
        app.tabBars.buttons["Convert"].tap()
        XCTAssertTrue(app.navigationBars["Latynize"].waitForExistence(timeout: 2))
    }
}
