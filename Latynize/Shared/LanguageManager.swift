//
//  LanguageManager.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.04.2026.
//

import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable {
    case system, en, ru, kk
    
    var label: String {
        switch self {
        case .system: return String(localized: "System")
        case .en:     return "English"
        case .ru:     return "Русский"
        case .kk:     return "Қазақша"
        }
    }
    
    var localeIdentifier: String? {
        switch self {
        case .system: return nil
        case .en:     return "en"
        case .ru:     return "ru"
        case .kk:     return "kk"
        }
    }
}

@Observable
final class LanguageManager {
    static let shared = LanguageManager()
    
    var currentLanguage: AppLanguage {
        didSet {
            AppSettings.shared.appLanguage = currentLanguage.rawValue
            applyLanguage()
        }
    }
    
    private init() {
        let saved = AppSettings.shared.appLanguage
        self.currentLanguage = AppLanguage(rawValue: saved) ?? .system
        applyLanguage()
    }
    
    private func applyLanguage() {
        if let id = currentLanguage.localeIdentifier {
            UserDefaults.standard.set([id], forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        }
    }
    
    // Returns Locale for forcing specific language in SwiftUI
    var locale: Locale {
        if let id = currentLanguage.localeIdentifier {
            return Locale(identifier: id)
        }
        return Locale.current
    }
}
