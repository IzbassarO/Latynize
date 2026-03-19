//
//  Alphabet2021.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation

/// Kazakhstan's 2021 Latin alphabet (31 letters with diacritics).
/// Presented by the Baitursynov Institute of Linguistics.
/// Uses: umlauts (ä, ö, ü), macron (ū), cedilla (ş, ğ), tilde (ñ).
/// Principle: "one sound — one letter".
struct Alphabet2021: AlphabetMapping {
    
    let id = "2021"
    let displayName = "Алфавит 2021"
    let version = "2021-v1"
    let yearLabel = "2021"
    let letterCount = 31
    let isRecommended = true
    
    // MARK: - Cyrillic → Latin
    
    let cyrillicToLatin: [String: String] = [
        // === Uppercase ===
        "А": "A",
        "Ә": "Ä",
        "Б": "B",
        "В": "V",
        "Г": "G",
        "Ғ": "Ğ",
        "Д": "D",
        "Е": "E",
        "Ж": "J",
        "З": "Z",
        "И": "İ",
        "Й": "İ",
        "К": "K",
        "Қ": "Q",
        "Л": "L",
        "М": "M",
        "Н": "N",
        "Ң": "Ñ",
        "О": "O",
        "Ө": "Ö",
        "П": "P",
        "Р": "R",
        "С": "S",
        "Т": "T",
        "У": "U",
        "Ұ": "Ū",
        "Ү": "Ü",
        "Ф": "F",
        "Х": "H",
        "Ш": "Ş",
        "Ы": "I",
        "І": "İ",
        
        // === Lowercase ===
        "а": "a",
        "ә": "ä",
        "б": "b",
        "в": "v",
        "г": "g",
        "ғ": "ğ",
        "д": "d",
        "е": "e",
        "ж": "j",
        "з": "z",
        "и": "i",
        "й": "i",
        "к": "k",
        "қ": "q",
        "л": "l",
        "м": "m",
        "н": "n",
        "ң": "ñ",
        "о": "o",
        "ө": "ö",
        "п": "p",
        "р": "r",
        "с": "s",
        "т": "t",
        "у": "u",
        "ұ": "ū",
        "ү": "ü",
        "ф": "f",
        "х": "h",
        "ш": "ş",
        "ы": "ı",
        "і": "i",
        
        // === Russian-specific letters (borrowings) ===
        // These letters don't exist in native Kazakh words
        // but appear in Russian loanwords still used in Kazakh text.
        "Ц": "TS",
        "ц": "ts",
        "Ч": "CH",
        "ч": "ch",
        "Щ": "ŞŞ",
        "щ": "şş",
        "Э": "E",
        "э": "e",
        
        // Compound vowels
        "Ю": "İU",
        "ю": "iu",
        "Я": "İA",
        "я": "ia",
        
        // Silent / modifier letters — omitted in Latin
        "Ъ": "",
        "ъ": "",
        "Ь": "",
        "ь": "",
    ]
    
    // MARK: - Latin → Cyrillic
    
    /// Built by inverting cyrillicToLatin + adding multi-char reverse mappings.
    /// Multi-char sequences (TS, CH, ŞŞ, İU, İA) must be matched first.
    let latinToCyrillic: [String: String] = [
        // === Multi-char (checked first) ===
        "TS": "Ц", "ts": "ц", "Ts": "Ц",
        "CH": "Ч", "ch": "ч", "Ch": "Ч",
        "ŞŞ": "Щ", "şş": "щ", "Şş": "Щ",
        "İU": "Ю", "iu": "ю", "İu": "Ю",
        "İA": "Я", "ia": "я", "İa": "Я",
        
        // === Uppercase ===
        "A": "А",
        "Ä": "Ә",
        "B": "Б",
        "V": "В",
        "G": "Г",
        "Ğ": "Ғ",
        "D": "Д",
        "E": "Е",
        "J": "Ж",
        "Z": "З",
        "İ": "І",
        "K": "К",
        "Q": "Қ",
        "L": "Л",
        "M": "М",
        "N": "Н",
        "Ñ": "Ң",
        "O": "О",
        "Ö": "Ө",
        "P": "П",
        "R": "Р",
        "S": "С",
        "T": "Т",
        "U": "У",
        "Ū": "Ұ",
        "Ü": "Ү",
        "F": "Ф",
        "H": "Х",
        "Ş": "Ш",
        "I": "Ы",
        "Y": "Й",
        
        // === Lowercase ===
        "a": "а",
        "ä": "ә",
        "b": "б",
        "v": "в",
        "g": "г",
        "ğ": "ғ",
        "d": "д",
        "e": "е",
        "j": "ж",
        "z": "з",
        "i": "і",    // note: both і and и map to i in Latin
        "k": "к",
        "q": "қ",
        "l": "л",
        "m": "м",
        "n": "н",
        "ñ": "ң",
        "o": "о",
        "ö": "ө",
        "p": "п",
        "r": "р",
        "s": "с",
        "t": "т",
        "u": "у",
        "ū": "ұ",
        "ü": "ү",
        "f": "ф",
        "h": "х",
        "ş": "ш",
        "ı": "ы",
        "y": "й",
    ]
}
