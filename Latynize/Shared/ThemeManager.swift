//
//  ThemeManager.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.04.2026.
//

import Foundation
import SwiftUI

enum AppTheme: String, CaseIterable {
    case system, light, dark
    
    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }
    
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

@Observable
final class ThemeManager {
    static let shared = ThemeManager()
    
    var currentTheme: AppTheme {
        didSet {
            AppSettings.shared.themeMode = currentTheme.rawValue
        }
    }
    
    private init() {
        let saved = AppSettings.shared.themeMode
        self.currentTheme = AppTheme(rawValue: saved) ?? .system
    }
}
