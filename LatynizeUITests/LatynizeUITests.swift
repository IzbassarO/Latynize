//
//  LatynizeUITests.swift
//  LatynizeUITests
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import XCTest

final class LatynizeUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-hasCompletedOnboarding", "YES"]
        app.launch()
    }
    
    // =====================================================
    // MARK: - TAB BAR
    // =====================================================
    
    func testTabBarExists() {
        XCTAssertTrue(app.tabBars.buttons["Convert"].exists)
        XCTAssertTrue(app.tabBars.buttons["Camera"].exists)
        XCTAssertTrue(app.tabBars.buttons["History"].exists)
    }
    
    func testTabSwitching() {
        app.tabBars.buttons["Camera"].tap()
        XCTAssertTrue(app.navigationBars["Camera"].exists)
        
        app.tabBars.buttons["History"].tap()
        XCTAssertTrue(app.navigationBars["History"].exists)
        
        app.tabBars.buttons["Convert"].tap()
        XCTAssertTrue(app.navigationBars["Latynize"].exists)
    }
    
    // =====================================================
    // MARK: - CONVERT SCREEN
    // =====================================================
    
    func testConvertScreenElements() {
        // Navigation title
        XCTAssertTrue(app.navigationBars["Latynize"].exists)
        
        // Direction labels
        XCTAssertTrue(app.staticTexts["Кириллица"].exists)
        XCTAssertTrue(app.staticTexts["Латын"].exists)
        
        // Section labels
        XCTAssertTrue(app.staticTexts["Original"].exists)
        XCTAssertTrue(app.staticTexts["Converted"].exists)
        
        // Paste button
        XCTAssertTrue(app.buttons["Paste"].exists)
    }
    
    func testSettingsButtonOpensSheet() {
        app.navigationBars.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 2))
        app.buttons["Done"].tap()
    }
    
    func testExamplePhrasesVisible() {
        XCTAssertTrue(app.staticTexts["Try an example"].exists)
        XCTAssertTrue(app.staticTexts["Сәлем!"].exists)
    }
    
    func testTapExampleFillsInput() {
        app.staticTexts["Сәлем!"].tap()
        
        // After tapping example, "Try an example" should disappear (input is filled)
        let converted = app.staticTexts["Converted"].waitForExistence(timeout: 2)
        XCTAssertTrue(converted)
    }
    
    // =====================================================
    // MARK: - HISTORY SCREEN
    // =====================================================
    
    func testHistoryEmptyState() {
        app.tabBars.buttons["History"].tap()
        XCTAssertTrue(app.staticTexts["No conversions yet"].waitForExistence(timeout: 2))
    }
    
    // =====================================================
    // MARK: - CAMERA SCREEN
    // =====================================================
    
    func testCameraScreenElements() {
        app.tabBars.buttons["Camera"].tap()
        // On simulator, should show fallback with "Choose Photo"
        XCTAssertTrue(app.staticTexts["Camera OCR"].waitForExistence(timeout: 2))
    }
    
    // =====================================================
    // MARK: - SETTINGS SCREEN
    // =====================================================
    
    func testSettingsElements() {
        app.navigationBars.buttons.element(boundBy: 1).tap()
        
        let settings = app.navigationBars["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 2))
        
        XCTAssertTrue(app.staticTexts["Conversion Standard"].exists)
        XCTAssertTrue(app.staticTexts["Smart direction"].exists)
        XCTAssertTrue(app.staticTexts["Auto-save history"].exists)
        XCTAssertTrue(app.staticTexts["Haptic feedback"].exists)
        XCTAssertTrue(app.staticTexts["Privacy Policy"].exists)
        XCTAssertTrue(app.staticTexts["Version"].exists)
        
        app.buttons["Done"].tap()
    }
    
    func testSettingsStandardToggle() {
        app.navigationBars.buttons.element(boundBy: 1).tap()
        _ = app.navigationBars["Settings"].waitForExistence(timeout: 2)
        
        // Tap 2018 segment
        app.buttons["2018"].tap()
        
        // Tap back to 2021
        app.buttons["2021"].tap()
        
        app.buttons["Done"].tap()
    }
    
    func testCompareStandardsOpens() {
        app.navigationBars.buttons.element(boundBy: 1).tap()
        _ = app.navigationBars["Settings"].waitForExistence(timeout: 2)
        
        app.staticTexts["Compare standards"].tap()
        XCTAssertTrue(app.staticTexts["Standard 2021"].waitForExistence(timeout: 2))
        
        app.buttons["Done"].firstMatch.tap()
    }
}
