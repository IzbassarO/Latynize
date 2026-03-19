//
//  AppSettings.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation

final class AppSettings {
    
    static let shared = AppSettings()
    
    // MARK: - Keys
    
    enum Key {
        static let alphabetVersion = "settings_alphabet_version"
        static let autoDetectDirection = "settings_auto_detect"
        static let autoSaveHistory = "settings_auto_save"
        static let hapticFeedback = "settings_haptic"
        static let lastUsedDirection = "settings_last_direction"
    }
    
    // MARK: - Properties
    
    private let defaults = UserDefaults.standard
    
    var alphabetVersion: String {
        get { defaults.string(forKey: Key.alphabetVersion) ?? "2021" }
        set { defaults.set(newValue, forKey: Key.alphabetVersion) }
    }
    
    var autoDetectDirection: Bool {
        get { defaults.object(forKey: Key.autoDetectDirection) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.autoDetectDirection) }
    }
    
    var autoSaveHistory: Bool {
        get { defaults.object(forKey: Key.autoSaveHistory) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.autoSaveHistory) }
    }
    
    var hapticEnabled: Bool {
        get { defaults.object(forKey: Key.hapticFeedback) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.hapticFeedback) }
    }
    
    var lastUsedDirectionRaw: String {
        get { defaults.string(forKey: Key.lastUsedDirection) ?? ConversionDirection.cyrillicToLatin.rawValue }
        set { defaults.set(newValue, forKey: Key.lastUsedDirection) }
    }
    
    var lastUsedDirection: ConversionDirection {
        get { ConversionDirection(rawValue: lastUsedDirectionRaw) ?? .cyrillicToLatin }
        set { lastUsedDirectionRaw = newValue.rawValue }
    }
}
