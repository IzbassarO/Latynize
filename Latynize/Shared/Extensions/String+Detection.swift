//
//  String+Detection.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation

extension String {
    
    /// Returns true if the string contains any Cyrillic characters
    var containsCyrillic: Bool {
        self.unicodeScalars.contains { scalar in
            (0x0400...0x04FF).contains(scalar.value)
        }
    }
    
    /// Returns true if the string contains any Latin characters (including diacritics)
    var containsLatin: Bool {
        self.unicodeScalars.contains { scalar in
            (0x0041...0x024F).contains(scalar.value)
        }
    }
    
    /// Returns true if string has meaningful content (not just whitespace/punctuation)
    var hasLetterContent: Bool {
        self.unicodeScalars.contains { CharacterSet.letters.contains($0) }
    }
    
    /// Trims whitespace and newlines
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
