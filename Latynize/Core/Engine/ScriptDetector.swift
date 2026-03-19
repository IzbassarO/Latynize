//
//  ScriptDetector.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation

/// Detects whether input text is primarily Cyrillic or Latin.
/// Used to auto-set conversion direction.
enum ScriptDetector {
    
    enum DetectedScript {
        case cyrillic
        case latin
        case mixed
        case empty
    }
    
    /// Cyrillic Unicode range: U+0400..U+04FF (Basic Cyrillic)
    private static let cyrillicRange: ClosedRange<UInt32> = 0x0400...0x04FF
    
    /// Basic Latin + Latin Extended (covers diacritics like ä, ö, ü, ş, ğ, ñ, ū)
    private static let latinRange: ClosedRange<UInt32> = 0x0041...0x024F
    
    /// Threshold for determining dominant script (70%)
    private static let dominanceThreshold: Double = 0.7
    
    static func detect(_ text: String) -> DetectedScript {
        let letters = text.unicodeScalars.filter { CharacterSet.letters.contains($0) }
        
        guard !letters.isEmpty else { return .empty }
        
        var cyrillicCount = 0
        var latinCount = 0
        
        for scalar in letters {
            if cyrillicRange.contains(scalar.value) {
                cyrillicCount += 1
            } else if latinRange.contains(scalar.value) {
                latinCount += 1
            }
        }
        
        let total = cyrillicCount + latinCount
        guard total > 0 else { return .empty }
        
        let cyrillicRatio = Double(cyrillicCount) / Double(total)
        let latinRatio = Double(latinCount) / Double(total)
        
        if cyrillicRatio >= dominanceThreshold {
            return .cyrillic
        } else if latinRatio >= dominanceThreshold {
            return .latin
        } else {
            return .mixed
        }
    }
    
    /// Suggests a conversion direction based on detected script.
    /// Returns nil if detection is ambiguous.
    static func suggestedDirection(for text: String) -> ConversionDirection? {
        switch detect(text) {
        case .cyrillic: return .cyrillicToLatin
        case .latin:    return .latinToCyrillic
        case .mixed:    return nil
        case .empty:    return nil
        }
    }
}
