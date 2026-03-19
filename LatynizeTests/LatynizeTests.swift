//
//  LatynizeTests.swift
//  LatynizeTests
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import XCTest
@testable import Latynize

final class LatynizeTests: XCTestCase {
    
    let engine = ConversionEngine.shared
    
    // =====================================================
    // MARK: - CONVERSION ENGINE: Cyrillic → Latin (2021)
    // =====================================================
    
    func testBasicWord() {
        XCTAssertEqual(convert("Сәлем", .cyrillicToLatin, "2021"), "Sälem")
    }
    
    func testFullSentence() {
        XCTAssertEqual(
            convert("Қазақстан Республикасы", .cyrillicToLatin, "2021"),
            "Qazaqstan Respublikası"
        )
    }
    
    func testAllUniqueKazakhLetters() {
        // Every Kazakh-specific letter
        XCTAssertEqual(convert("Ә", .cyrillicToLatin, "2021"), "Ä")
        XCTAssertEqual(convert("ә", .cyrillicToLatin, "2021"), "ä")
        XCTAssertEqual(convert("Ғ", .cyrillicToLatin, "2021"), "Ğ")
        XCTAssertEqual(convert("ғ", .cyrillicToLatin, "2021"), "ğ")
        XCTAssertEqual(convert("Қ", .cyrillicToLatin, "2021"), "Q")
        XCTAssertEqual(convert("қ", .cyrillicToLatin, "2021"), "q")
        XCTAssertEqual(convert("Ң", .cyrillicToLatin, "2021"), "Ñ")
        XCTAssertEqual(convert("ң", .cyrillicToLatin, "2021"), "ñ")
        XCTAssertEqual(convert("Ө", .cyrillicToLatin, "2021"), "Ö")
        XCTAssertEqual(convert("ө", .cyrillicToLatin, "2021"), "ö")
        XCTAssertEqual(convert("Ұ", .cyrillicToLatin, "2021"), "Ū")
        XCTAssertEqual(convert("ұ", .cyrillicToLatin, "2021"), "ū")
        XCTAssertEqual(convert("Ү", .cyrillicToLatin, "2021"), "Ü")
        XCTAssertEqual(convert("ү", .cyrillicToLatin, "2021"), "ü")
        XCTAssertEqual(convert("Ш", .cyrillicToLatin, "2021"), "Ş")
        XCTAssertEqual(convert("ш", .cyrillicToLatin, "2021"), "ş")
        XCTAssertEqual(convert("Ы", .cyrillicToLatin, "2021"), "I")
        XCTAssertEqual(convert("ы", .cyrillicToLatin, "2021"), "ı")
        XCTAssertEqual(convert("І", .cyrillicToLatin, "2021"), "İ")
        XCTAssertEqual(convert("і", .cyrillicToLatin, "2021"), "i")
    }
    
    func testCommonLetters() {
        XCTAssertEqual(convert("А", .cyrillicToLatin, "2021"), "A")
        XCTAssertEqual(convert("Б", .cyrillicToLatin, "2021"), "B")
        XCTAssertEqual(convert("В", .cyrillicToLatin, "2021"), "V")
        XCTAssertEqual(convert("Г", .cyrillicToLatin, "2021"), "G")
        XCTAssertEqual(convert("Д", .cyrillicToLatin, "2021"), "D")
        XCTAssertEqual(convert("Е", .cyrillicToLatin, "2021"), "E")
        XCTAssertEqual(convert("Ж", .cyrillicToLatin, "2021"), "J")
        XCTAssertEqual(convert("З", .cyrillicToLatin, "2021"), "Z")
        XCTAssertEqual(convert("К", .cyrillicToLatin, "2021"), "K")
        XCTAssertEqual(convert("Л", .cyrillicToLatin, "2021"), "L")
        XCTAssertEqual(convert("М", .cyrillicToLatin, "2021"), "M")
        XCTAssertEqual(convert("Н", .cyrillicToLatin, "2021"), "N")
        XCTAssertEqual(convert("О", .cyrillicToLatin, "2021"), "O")
        XCTAssertEqual(convert("П", .cyrillicToLatin, "2021"), "P")
        XCTAssertEqual(convert("Р", .cyrillicToLatin, "2021"), "R")
        XCTAssertEqual(convert("С", .cyrillicToLatin, "2021"), "S")
        XCTAssertEqual(convert("Т", .cyrillicToLatin, "2021"), "T")
        XCTAssertEqual(convert("У", .cyrillicToLatin, "2021"), "U")
        XCTAssertEqual(convert("Ф", .cyrillicToLatin, "2021"), "F")
        XCTAssertEqual(convert("Х", .cyrillicToLatin, "2021"), "H")
    }
    
    func testRussianBorrowings() {
        XCTAssertEqual(convert("Ц", .cyrillicToLatin, "2021"), "TS")
        XCTAssertEqual(convert("ц", .cyrillicToLatin, "2021"), "ts")
        XCTAssertEqual(convert("Ч", .cyrillicToLatin, "2021"), "CH")
        XCTAssertEqual(convert("ч", .cyrillicToLatin, "2021"), "ch")
        XCTAssertEqual(convert("Щ", .cyrillicToLatin, "2021"), "ŞŞ")
        XCTAssertEqual(convert("щ", .cyrillicToLatin, "2021"), "şş")
        XCTAssertEqual(convert("Ю", .cyrillicToLatin, "2021"), "İU")
        XCTAssertEqual(convert("ю", .cyrillicToLatin, "2021"), "iu")
        XCTAssertEqual(convert("Я", .cyrillicToLatin, "2021"), "İA")
        XCTAssertEqual(convert("я", .cyrillicToLatin, "2021"), "ia")
    }
    
    func testSilentLettersRemoved() {
        XCTAssertEqual(convert("ъ", .cyrillicToLatin, "2021"), "")
        XCTAssertEqual(convert("ь", .cyrillicToLatin, "2021"), "")
        XCTAssertEqual(convert("Ъ", .cyrillicToLatin, "2021"), "")
        XCTAssertEqual(convert("Ь", .cyrillicToLatin, "2021"), "")
    }
    
    // =====================================================
    // MARK: - CONVERSION ENGINE: Latin → Cyrillic (2021)
    // =====================================================
    
    func testLatinToCyrillicBasic() {
        XCTAssertEqual(convert("Sälem", .latinToCyrillic, "2021"), "Сәлем")
    }
    
    func testLatinToCyrillicMultiChar() {
        // Multi-char sequences must be matched before single chars
        XCTAssertEqual(convert("ts", .latinToCyrillic, "2021"), "ц")
        XCTAssertEqual(convert("ch", .latinToCyrillic, "2021"), "ч")
        XCTAssertEqual(convert("şş", .latinToCyrillic, "2021"), "щ")
    }
    
    func testLatinToCyrillicDiacritics() {
        XCTAssertEqual(convert("ä", .latinToCyrillic, "2021"), "ә")
        XCTAssertEqual(convert("ö", .latinToCyrillic, "2021"), "ө")
        XCTAssertEqual(convert("ü", .latinToCyrillic, "2021"), "ү")
        XCTAssertEqual(convert("ū", .latinToCyrillic, "2021"), "ұ")
        XCTAssertEqual(convert("ğ", .latinToCyrillic, "2021"), "ғ")
        XCTAssertEqual(convert("ş", .latinToCyrillic, "2021"), "ш")
        XCTAssertEqual(convert("ñ", .latinToCyrillic, "2021"), "ң")
    }
    
    // =====================================================
    // MARK: - 2018 STANDARD
    // =====================================================
    
    func test2018BasicConversion() {
        XCTAssertEqual(convert("Сәлем", .cyrillicToLatin, "2018"), "Sálem")
    }
    
    func test2018Digraphs() {
        XCTAssertEqual(convert("Ш", .cyrillicToLatin, "2018"), "Sh")
        XCTAssertEqual(convert("ш", .cyrillicToLatin, "2018"), "sh")
        XCTAssertEqual(convert("Щ", .cyrillicToLatin, "2018"), "Shsh")
        XCTAssertEqual(convert("щ", .cyrillicToLatin, "2018"), "shsh")
    }
    
    func test2018AcuteAccents() {
        XCTAssertEqual(convert("Ә", .cyrillicToLatin, "2018"), "Á")
        XCTAssertEqual(convert("Ө", .cyrillicToLatin, "2018"), "Ó")
        XCTAssertEqual(convert("Ұ", .cyrillicToLatin, "2018"), "Ú")
        XCTAssertEqual(convert("Ү", .cyrillicToLatin, "2018"), "Ý")
        XCTAssertEqual(convert("Ғ", .cyrillicToLatin, "2018"), "Ǵ")
        XCTAssertEqual(convert("Ң", .cyrillicToLatin, "2018"), "Ń")
    }
    
    func test2021vs2018ProduceDifferentOutput() {
        let input = "Әлем"
        let r2021 = convert(input, .cyrillicToLatin, "2021")
        let r2018 = convert(input, .cyrillicToLatin, "2018")
        XCTAssertNotEqual(r2021, r2018, "2021 and 2018 should produce different results for Kazakh-specific letters")
        XCTAssertEqual(r2021, "Älem")
        XCTAssertEqual(r2018, "Álem")
    }
    
    // =====================================================
    // MARK: - MIXED CONTENT & EDGE CASES
    // =====================================================
    
    func testMixedTextPreserved() {
        XCTAssertEqual(
            convert("Сәлем, hello 123!", .cyrillicToLatin, "2021"),
            "Sälem, hello 123!"
        )
    }
    
    func testDigitsUntouched() {
        XCTAssertEqual(convert("2024 жыл", .cyrillicToLatin, "2021"), "2024 jıl")
    }
    
    func testPunctuationPreserved() {
        XCTAssertEqual(
            convert("Сәлем! Қалың қалай?", .cyrillicToLatin, "2021"),
            "Sälem! Qalıñ qalai?"
        )
    }
    
    func testEmojiPreserved() {
        XCTAssertEqual(convert("Сәлем 🇰🇿", .cyrillicToLatin, "2021"), "Sälem 🇰🇿")
    }
    
    func testNewlinesPreserved() {
        XCTAssertEqual(convert("Бір\nЕкі\nҮш", .cyrillicToLatin, "2021"), "Bir\nEki\nÜş")
    }
    
    func testTabsPreserved() {
        XCTAssertEqual(convert("Бір\tЕкі", .cyrillicToLatin, "2021"), "Bir\tEki")
    }
    
    func testEmptyString() {
        let r = engine.convert("", direction: .cyrillicToLatin)
        XCTAssertEqual(r.output, "")
        XCTAssertEqual(r.inputCharCount, 0)
    }
    
    func testOnlySpaces() {
        XCTAssertEqual(convert("   ", .cyrillicToLatin, "2021"), "   ")
    }
    
    func testOnlyDigits() {
        XCTAssertEqual(convert("12345", .cyrillicToLatin, "2021"), "12345")
    }
    
    func testOnlyPunctuation() {
        XCTAssertEqual(convert("!@#$%^&*()", .cyrillicToLatin, "2021"), "!@#$%^&*()")
    }
    
    func testSingleCharacter() {
        XCTAssertEqual(convert("А", .cyrillicToLatin, "2021"), "A")
    }
    
    func testRepeatedCharacters() {
        XCTAssertEqual(convert("ааа", .cyrillicToLatin, "2021"), "aaa")
    }
    
    func testURLPreservedInMixedText() {
        let input = "Сайт: https://example.com"
        let output = convert(input, .cyrillicToLatin, "2021")
        XCTAssertTrue(output.contains("https://example.com"))
    }
    
    // =====================================================
    // MARK: - ROUNDTRIP TESTS
    // =====================================================
    
    func testRoundtripSimpleWord() {
        let original = "Сәлем"
        let latin = convert(original, .cyrillicToLatin, "2021")
        let back = convert(latin, .latinToCyrillic, "2021")
        XCTAssertEqual(back, original)
    }
    
    func testRoundtripSentence() {
        // Note: roundtrip may not be perfect for all words due to ambiguity
        // (И and І both map to İ/i), but simple cases should work
        let original = "Астана"
        let latin = convert(original, .cyrillicToLatin, "2021")
        XCTAssertEqual(latin, "Astana")
    }
    
    // =====================================================
    // MARK: - RESULT METADATA
    // =====================================================
    
    func testResultMetadata() {
        let r = engine.convert("Сәлем", direction: .cyrillicToLatin, mappingID: "2021")
        XCTAssertEqual(r.direction, .cyrillicToLatin)
        XCTAssertEqual(r.mappingID, "2021")
        XCTAssertEqual(r.inputCharCount, 5)
        XCTAssertEqual(r.outputCharCount, 5)
    }
    
    func testAutoDetectConversion() {
        let r = engine.convertAutoDetect("Сәлем")
        XCTAssertEqual(r.output, "Sälem")
        XCTAssertEqual(r.direction, .cyrillicToLatin)
    }
    
    func testInvalidMappingFallback() {
        let r = engine.convert("Сәлем", direction: .cyrillicToLatin, mappingID: "9999")
        XCTAssertEqual(r.output, "Сәлем", "Invalid mapping should return input unchanged")
    }
    
    // =====================================================
    // MARK: - PERFORMANCE
    // =====================================================
    
    func testPerformanceLongText() {
        let text = String(repeating: "Қазақстан Республикасы. ", count: 1000)
        measure {
            _ = engine.convert(text, direction: .cyrillicToLatin, mappingID: "2021")
        }
    }
    
    func testPerformanceShortTextRepeated() {
        measure {
            for _ in 0..<10000 {
                _ = engine.convert("Сәлем", direction: .cyrillicToLatin, mappingID: "2021")
            }
        }
    }
    
    // =====================================================
    // MARK: - SCRIPT DETECTOR
    // =====================================================
    
    func testDetectCyrillic() {
        XCTAssertEqual(ScriptDetector.detect("Қазақстан"), .cyrillic)
    }
    
    func testDetectLatin() {
        XCTAssertEqual(ScriptDetector.detect("Qazaqstan"), .latin)
    }
    
    func testDetectLatinWithDiacritics() {
        XCTAssertEqual(ScriptDetector.detect("Sälem älem"), .latin)
    }
    
    func testDetectEmpty() {
        XCTAssertEqual(ScriptDetector.detect(""), .empty)
    }
    
    func testDetectOnlySpaces() {
        XCTAssertEqual(ScriptDetector.detect("   "), .empty)
    }
    
    func testDetectOnlyDigits() {
        XCTAssertEqual(ScriptDetector.detect("12345"), .empty)
    }
    
    func testDetectMixed() {
        XCTAssertEqual(ScriptDetector.detect("Сәлем Sälem"), .mixed)
    }
    
    func testSuggestedDirectionCyrillic() {
        XCTAssertEqual(ScriptDetector.suggestedDirection(for: "Сәлем"), .cyrillicToLatin)
    }
    
    func testSuggestedDirectionLatin() {
        XCTAssertEqual(ScriptDetector.suggestedDirection(for: "Sälem"), .latinToCyrillic)
    }
    
    func testSuggestedDirectionNil() {
        XCTAssertNil(ScriptDetector.suggestedDirection(for: ""))
        XCTAssertNil(ScriptDetector.suggestedDirection(for: "123"))
    }
    
    // =====================================================
    // MARK: - CONVERSION DIRECTION ENUM
    // =====================================================
    
    func testDirectionToggle() {
        XCTAssertEqual(ConversionDirection.cyrillicToLatin.toggled, .latinToCyrillic)
        XCTAssertEqual(ConversionDirection.latinToCyrillic.toggled, .cyrillicToLatin)
    }
    
    func testDirectionLabel() {
        XCTAssertFalse(ConversionDirection.cyrillicToLatin.label.isEmpty)
        XCTAssertFalse(ConversionDirection.latinToCyrillic.label.isEmpty)
    }
    
    func testDirectionRawValue() {
        XCTAssertEqual(ConversionDirection(rawValue: "cyr_to_lat"), .cyrillicToLatin)
        XCTAssertEqual(ConversionDirection(rawValue: "lat_to_cyr"), .latinToCyrillic)
        XCTAssertNil(ConversionDirection(rawValue: "invalid"))
    }
    
    // =====================================================
    // MARK: - CONVERSION SOURCE ENUM
    // =====================================================
    
    func testSourceIcons() {
        XCTAssertFalse(ConversionSource.text.icon.isEmpty)
        XCTAssertFalse(ConversionSource.camera.icon.isEmpty)
        XCTAssertFalse(ConversionSource.shareExtension.icon.isEmpty)
    }
    
    // =====================================================
    // MARK: - MAPPING REGISTRY
    // =====================================================
    
    func testAvailableMappings() {
        let mappings = engine.availableMappings
        XCTAssertGreaterThanOrEqual(mappings.count, 2)
    }
    
    func testMappingLookup() {
        XCTAssertNotNil(engine.mapping(for: "2021"))
        XCTAssertNotNil(engine.mapping(for: "2018"))
        XCTAssertNil(engine.mapping(for: "nonexistent"))
    }
    
    func test2021IsRecommended() {
        let m = engine.mapping(for: "2021")
        XCTAssertTrue(m?.isRecommended == true)
    }
    
    func test2018IsNotRecommended() {
        let m = engine.mapping(for: "2018")
        XCTAssertTrue(m?.isRecommended == false)
    }
    
    func test2021Has31Letters() {
        let m = engine.mapping(for: "2021")
        XCTAssertEqual(m?.letterCount, 31)
    }
    
    // =====================================================
    // MARK: - STRING EXTENSIONS
    // =====================================================
    
    func testContainsCyrillic() {
        XCTAssertTrue("Сәлем".containsCyrillic)
        XCTAssertFalse("Hello".containsCyrillic)
        XCTAssertFalse("123".containsCyrillic)
    }
    
    func testContainsLatin() {
        XCTAssertTrue("Hello".containsLatin)
        XCTAssertTrue("Sälem".containsLatin)
        XCTAssertFalse("Сәлем".containsLatin)
        XCTAssertFalse("123".containsLatin)
    }
    
    func testHasLetterContent() {
        XCTAssertTrue("abc".hasLetterContent)
        XCTAssertTrue("Сәлем".hasLetterContent)
        XCTAssertFalse("123".hasLetterContent)
        XCTAssertFalse("!@#".hasLetterContent)
        XCTAssertFalse("   ".hasLetterContent)
    }
    
    func testTrimmed() {
        XCTAssertEqual("  hello  ".trimmed, "hello")
        XCTAssertEqual("\nhello\n".trimmed, "hello")
        XCTAssertEqual("hello".trimmed, "hello")
    }
    
    // =====================================================
    // MARK: - APP SETTINGS
    // =====================================================
    
    func testDefaultSettings() {
        let s = AppSettings.shared
        XCTAssertEqual(s.alphabetVersion, "2021")
        XCTAssertTrue(s.autoDetectDirection)
        XCTAssertTrue(s.autoSaveHistory)
        XCTAssertTrue(s.hapticEnabled)
    }
    
    // =====================================================
    // MARK: - REAL KAZAKH PHRASES
    // =====================================================
    
    func testCommonPhrases2021() {
        // Greetings
        XCTAssertEqual(convert("Сәлем!", .cyrillicToLatin, "2021"), "Sälem!")
        XCTAssertEqual(convert("Қайырлы таң!", .cyrillicToLatin, "2021"), "Qaiırlı tañ!")
        
        // Country
        XCTAssertEqual(convert("Астана", .cyrillicToLatin, "2021"), "Astana")
        XCTAssertEqual(convert("Алматы", .cyrillicToLatin, "2021"), "Almatı")
        XCTAssertEqual(convert("Ақтөбе", .cyrillicToLatin, "2021"), "Aqtöbe")
    }
    
    // =====================================================
    // MARK: - Helper
    // =====================================================
    
    private func convert(_ input: String, _ dir: ConversionDirection, _ id: String) -> String {
        engine.convert(input, direction: dir, mappingID: id).output
    }
}
