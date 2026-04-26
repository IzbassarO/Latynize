//
//  WhatsNewService.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 26.04.2026.
//

import Foundation

/// Tracks which app version the user has last "seen" (i.e. opened the What's New sheet for).
/// Decides whether to show What's New on launch.
@Observable
final class WhatsNewService {
    
    static let shared = WhatsNewService()
    private init() {}
    
    private let lastSeenVersionKey = "WhatsNew.lastSeenVersion"
    private let firstLaunchKey = "WhatsNew.hasLaunchedBefore"
    
    /// Whether to show What's New sheet on this launch
    var shouldShowWhatsNew: Bool {
        // Don't show on the very first install ever — those users see onboarding instead
        guard UserDefaults.standard.bool(forKey: firstLaunchKey) else {
            return false
        }
        
        let currentVersion = currentAppVersion
        let lastSeen = UserDefaults.standard.string(forKey: lastSeenVersionKey)
        
        // No prior version recorded → user is new (post-onboarding) → don't show
        guard let lastSeen else {
            return false
        }
        
        // Only show if major version differs (1.x → 2.x), not for patches (2.0.0 → 2.0.1)
        let currentMajor = majorVersion(currentVersion)
        let lastMajor = majorVersion(lastSeen)
        
        return currentMajor != lastMajor
    }
    
    /// Mark current version as "seen" so we don't show again
    func markAsSeen() {
        UserDefaults.standard.set(currentAppVersion, forKey: lastSeenVersionKey)
    }
    
    /// Called from onboarding completion or app first launch
    func markFirstLaunchComplete() {
        UserDefaults.standard.set(true, forKey: firstLaunchKey)
        UserDefaults.standard.set(currentAppVersion, forKey: lastSeenVersionKey)
    }
    
    // MARK: - Helpers
    
    var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private func majorVersion(_ version: String) -> String {
        version.split(separator: ".").first.map(String.init) ?? "0"
    }
}
