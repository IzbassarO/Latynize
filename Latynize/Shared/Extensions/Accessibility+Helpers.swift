//
//  Accessibility+Helpers.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation
import SwiftUI

// MARK: - Accessibility Identifiers (for UI testing)

enum AccessibilityID {
    // Convert tab
    static let inputField = "convert_input_field"
    static let outputField = "convert_output_field"
    static let directionToggle = "convert_direction_toggle"
    static let clearButton = "convert_clear_button"
    static let pasteButton = "convert_paste_button"
    static let copyButton = "convert_copy_button"
    static let shareButton = "convert_share_button"
    
    // Camera tab
    static let cameraPreview = "camera_preview"
    static let photoPickerButton = "camera_photo_picker"
    static let scanResultCard = "camera_result_card"
    
    // History tab
    static let historyList = "history_list"
    static let historySearch = "history_search"
    
    // Settings
    static let settingsButton = "settings_button"
    static let alphabetPicker = "settings_alphabet_picker"
}

// MARK: - View Extension for common accessibility patterns

extension View {
    
    /// Adds VoiceOver label and hint for conversion-related buttons
    func conversionAccessibility(label: String, hint: String = "") -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint.isEmpty ? "" : hint)
    }
}
