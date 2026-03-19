//
//  HapticService.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation
import UIKit

enum HapticService {
    
    static func light() {
        guard AppSettings.shared.hapticEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    static func medium() {
        guard AppSettings.shared.hapticEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    static func success() {
        guard AppSettings.shared.hapticEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    static func error() {
        guard AppSettings.shared.hapticEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    static func selection() {
        guard AppSettings.shared.hapticEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
