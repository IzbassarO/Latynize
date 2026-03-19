//
//  ConversionEngineTests.swift
//  LatynizeTests
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import XCTest
@testable import Latynize

/// Unit tests for the ConversionEngine.
/// These tests verify the correctness of Cyrillic ↔ Latin conversion
/// across both the 2021 and 2018 alphabet standards.
///
/// HOW TO ADD IN XCODE:
/// 1. File → New → Target → Unit Testing Bundle
/// 2. Name it "LatynizeTests"
/// 3. Add this file to the test target
final class ConversionEngineTests: XCTestCase {
    
    let engine = ConversionEngine.shared
    
    // MARK: - 2021 Alphabet: Cyrillic → Latin
    
    func testBasicCyrToLat2021() {
        let result = engine.convert("Сәлем", direction: .cyrillicToLatin, mappingID: "2021")
        XCTAssertEqual(result.output, "Sälem")
    }
    
    func testFullSentenceCyrToLat2021() {
        let result = engine.convert("Қазақстан Республикасы", direction: .cyrillicToLatin, mappingID: "2021")
        XCTAssertEqual(result.output, "Qazaqstan Respublikası")
    }
    
    func testSpecificLettersCyrToLat2021() {
        // Ә → Ä
        XCTAssertEqual(convert("Ә", .cyrillicToLatin, "2021"), "Ä")
        // Ғ → Ğ
        XCTAssertEqual(convert("Ғ", .cyrillicToLatin, "2021"), "Ğ")
        // Қ → Q
        XCTAssertEqual(convert("Қ", .cyrillicToLatin, "2021"), "Q")
        // Ң → Ñ
        XCTAssertEqual(convert("Ң", .cyrillicToLatin, "2021"), "Ñ")
        // Ө → Ö
        XCTAssertEqual(convert("Ө", .cyrillicToLatin, "2021"), "Ö")
        // Ұ → Ū
        XCTAssertEqual(convert("Ұ", .cyrillicToLatin, "2021"), "Ū")
        // Ү → Ü
        XCTAssertEqual(convert("Ү", .cyrillicToLatin, "2021"), "Ü")
        // Ш → Ş
        XCTAssertEqual(convert("Ш", .cyrillicToLatin, "2021"), "Ş")
        // Ы → I
        XCTAssertEqual(convert("Ы", .cyrillicToLatin, "2021"), "I")
        // І → İ
        XCTAssertEqual(convert("І", .cyrillicToLatin, "2021"), "İ")
    }
    
    func testLowercaseSpecificLetters2021() {
        XCTAssertEqual(convert("ә", .cyrillicToLatin, "2021"), "ä")
        XCTAssertEqual(convert("ғ", .cyrillicToLatin, "2021"), "ğ")
        XCTAssertEqual(convert("қ", .cyrillicToLatin, "2021"), "q")
        XCTAssertEqual(convert("ң", .cyrillicToLatin, "2021"), "ñ")
        XCTAssertEqual(convert("ш", .cyrillicToLatin, "2021"), "ş")
        XCTAssertEqual(convert("ы", .cyrillicToLatin, "2021"), "ı")
    }
    
    // MARK: - Russian Borrowings
    
    func testRussianBorrowings2021() {
        XCTAssertEqual(convert("Ц", .cyrillicToLatin, "2021"), "TS")
        XCTAssertEqual(convert("ц", .cyrillicToLatin, "2021"), "ts")
        XCTAssertEqual(convert("Ч", .cyrillicToLatin, "2021"), "CH")
        XCTAssertEqual(convert("ч", .cyrillicToLatin, "2021"), "ch")
        XCTAssertEqual(convert("Щ", .cyrillicToLatin, "2021"), "ŞŞ")
        XCTAssertEqual(convert("Ю", .cyrillicToLatin, "2021"), "İU")
        XCTAssertEqual(convert("Я", .cyrillicToLatin, "2021"), "İA")
    }
    
    func testSilentLettersOmitted2021() {
        XCTAssertEqual(convert("ъ", .cyrillicToLatin, "2021"), "")
        XCTAssertEqual(convert("ь", .cyrillicToLatin, "2021"), "")
    }
    
    // MARK: - 2021: Latin → Cyrillic
    
    func testBasicLatToCyr2021() {
        let result = engine.convert("Sälem", direction: .latinToCyrillic, mappingID: "2021")
        XCTAssertEqual(result.output, "Сәлем")
    }
    
    // MARK: - Mixed Content
    
    func testMixedTextPreserved() {
        let result = engine.convert("Сәлем, hello 123!", direction: .cyrillicToLatin, mappingID: "2021")
        XCTAssertEqual(result.output, "Sälem, hello 123!")
    }
    
    func testDigitsPreserved() {
        let result = engine.convert("2024 жыл", direction: .cyrillicToLatin, mappingID: "2021")
        XCTAssertEqual(result.output, "2024 jıl")
    }
    
    func testPunctuationPreserved() {
        let result = engine.convert("Сәлем! Қалың қалай?", direction: .cyrillicToLatin, mappingID: "2021")
        XCTAssertEqual(result.output, "Sälem! Qalıñ qalai?")
    }
    
    // MARK: - Empty / Edge Cases
    
    func testEmptyString() {
        let result = engine.convert("", direction: .cyrillicToLatin)
        XCTAssertEqual(result.output, "")
    }
    
    func testOnlySpaces() {
        let result = engine.convert("   ", direction: .cyrillicToLatin)
        XCTAssertEqual(result.output, "   ")
    }
    
    func testOnlyDigits() {
        let result = engine.convert("12345", direction: .cyrillicToLatin)
        XCTAssertEqual(result.output, "12345")
    }
    
    func testEmoji() {
        let result = engine.convert("Сәлем 🇰🇿", direction: .cyrillicToLatin, mappingID: "2021")
        XCTAssertEqual(result.output, "Sälem 🇰🇿")
    }
    
    // MARK: - Long Text Performance
    
    func testLongTextPerformance() {
        let longText = String(repeating: "Қазақстан Республикасы. ", count: 1000)
        
        measure {
            _ = engine.convert(longText, direction: .cyrillicToLatin, mappingID: "2021")
        }
        // Should complete well under 1 second even for 24,000+ character strings
    }
    
    // MARK: - 2018 Alphabet
    
    func testBasicCyrToLat2018() {
        let result = engine.convert("Сәлем", direction: .cyrillicToLatin, mappingID: "2018")
        XCTAssertEqual(result.output, "Sálem")
    }
    
    func test2018ShDigraph() {
        XCTAssertEqual(convert("Ш", .cyrillicToLatin, "2018"), "Sh")
        XCTAssertEqual(convert("ш", .cyrillicToLatin, "2018"), "sh")
    }
    
    // MARK: - ScriptDetector
    
    func testDetectCyrillic() {
        let detected = ScriptDetector.detect("Қазақстан Республикасы")
        XCTAssertEqual(detected, .cyrillic)
    }
    
    func testDetectLatin() {
        let detected = ScriptDetector.detect("Qazaqstan Respublikası")
        XCTAssertEqual(detected, .latin)
    }
    
    func testDetectEmpty() {
        XCTAssertEqual(ScriptDetector.detect(""), .empty)
        XCTAssertEqual(ScriptDetector.detect("   "), .empty)
        XCTAssertEqual(ScriptDetector.detect("123"), .empty)
    }
    
    func testSuggestedDirection() {
        XCTAssertEqual(
            ScriptDetector.suggestedDirection(for: "Сәлем"),
            .cyrillicToLatin
        )
        XCTAssertEqual(
            ScriptDetector.suggestedDirection(for: "Sälem"),
            .latinToCyrillic
        )
        XCTAssertNil(ScriptDetector.suggestedDirection(for: ""))
    }
    
    // MARK: - ConversionResult Metadata
    
    func testResultMetadata() {
        let result = engine.convert("Сәлем", direction: .cyrillicToLatin, mappingID: "2021")
        XCTAssertEqual(result.direction, .cyrillicToLatin)
        XCTAssertEqual(result.mappingID, "2021")
        XCTAssertEqual(result.inputCharCount, 5)
        XCTAssertEqual(result.outputCharCount, 5) // "Sälem" is also 5 chars
    }
    
    // MARK: - Helpers
    
    private func convert(_ input: String, _ dir: ConversionDirection, _ id: String) -> String {
        engine.convert(input, direction: dir, mappingID: id).output
    }
}
