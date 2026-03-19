//
//  Alphabet2018.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation

/// Kazakhstan's 2018 Latin alphabet (Decree No. 637, Feb 19 2018).
/// Replaced the 2017 apostrophe-based version with diacritics and digraphs.
/// Uses acute accents: á, ǵ, ń, ó, ú, ý, í.
/// Note: This version was superseded by the 2021 proposal but is preserved
/// for reference and compatibility.
struct Alphabet2018: AlphabetMapping {
    
    let id = "2018"
    let displayName = "Алфавит 2018 (Указ №637)"
    let version = "2018-v1"
    let yearLabel = "2018"
    let letterCount = 32
    let isRecommended = false
    
    // MARK: - Cyrillic → Latin
    
    let cyrillicToLatin: [String: String] = [
        // === Uppercase ===
        "А": "A",
        "Ә": "Á",
        "Б": "B",
        "В": "V",
        "Г": "G",
        "Ғ": "Ǵ",
        "Д": "D",
        "Е": "E",
        "Ж": "J",
        "З": "Z",
        "И": "I",
        "Й": "I",
        "К": "K",
        "Қ": "Q",
        "Л": "L",
        "М": "M",
        "Н": "N",
        "Ң": "Ń",
        "О": "O",
        "Ө": "Ó",
        "П": "P",
        "Р": "R",
        "С": "S",
        "Т": "T",
        "У": "U",
        "Ұ": "Ú",
        "Ү": "Ý",
        "Ф": "F",
        "Х": "H",
        "Ш": "Sh",
        "Щ": "Shsh",
        "Ы": "Y",
        "І": "Í",
        
        // === Lowercase ===
        "а": "a",
        "ә": "á",
        "б": "b",
        "в": "v",
        "г": "g",
        "ғ": "ǵ",
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
        "ң": "ń",
        "о": "o",
        "ө": "ó",
        "п": "p",
        "р": "r",
        "с": "s",
        "т": "t",
        "у": "u",
        "ұ": "ú",
        "ү": "ý",
        "ф": "f",
        "х": "h",
        "ш": "sh",
        "щ": "shsh",
        "ы": "y",
        "і": "í",
        
        // Russian borrowings
        "Ц": "Ts",  "ц": "ts",
        "Ч": "Ch",   "ч": "ch",
        "Э": "E",    "э": "e",
        "Ю": "Iu",   "ю": "iu",
        "Я": "Ia",   "я": "ia",
        "Ъ": "",     "ъ": "",
        "Ь": "",     "ь": "",
    ]
    
    // MARK: - Latin → Cyrillic
    
    let latinToCyrillic: [String: String] = [
        // Multi-char first
        "Shsh": "Щ", "shsh": "щ",
        "Sh": "Ш",   "sh": "ш",
        "Ts": "Ц",   "ts": "ц",
        "Ch": "Ч",   "ch": "ч",
        "Iu": "Ю",   "iu": "ю",
        "Ia": "Я",   "ia": "я",
        
        // Uppercase
        "A": "А", "Á": "Ә", "B": "Б", "V": "В",
        "G": "Г", "Ǵ": "Ғ", "D": "Д", "E": "Е",
        "J": "Ж", "Z": "З", "I": "И", "K": "К",
        "Q": "Қ", "L": "Л", "M": "М", "N": "Н",
        "Ń": "Ң", "O": "О", "Ó": "Ө", "P": "П",
        "R": "Р", "S": "С", "T": "Т", "U": "У",
        "Ú": "Ұ", "Ý": "Ү", "F": "Ф", "H": "Х",
        "Y": "Ы", "Í": "І",
        
        // Lowercase
        "a": "а", "á": "ә", "b": "б", "v": "в",
        "g": "г", "ǵ": "ғ", "d": "д", "e": "е",
        "j": "ж", "z": "з", "i": "и", "k": "к",
        "q": "қ", "l": "л", "m": "м", "n": "н",
        "ń": "ң", "o": "о", "ó": "ө", "p": "п",
        "r": "р", "s": "с", "t": "т", "u": "у",
        "ú": "ұ", "ý": "ү", "f": "ф", "h": "х",
        "y": "ы", "í": "і",
    ]
}
