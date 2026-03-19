//
//  Date+Relative.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation

extension Date {
    
    /// Returns a human-readable relative time string.
    /// Examples: "Just now", "2 min ago", "Yesterday", "Mar 15"
    var relativeDisplay: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale.current
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}
