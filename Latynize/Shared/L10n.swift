//
//  L10n.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation

/// Centralized string constants.
/// In v1, these are hardcoded English with Kazakh context.
/// In v2+, replace with String(localized:) for full localization.
enum L10n {
    
    // MARK: - Tabs
    
    enum Tab {
        static let convert = "Convert"
        static let camera = "Camera"
        static let history = "History"
    }
    
    // MARK: - Convert Screen
    
    enum Convert {
        static let title = "Latynize"
        static let cyrillic = "Кириллица"
        static let latin = "Латын"
        static let swapDirection = "Swap direction"
        static let clear = "Clear"
        static let paste = "Paste"
        static let copy = "Copy"
        static let share = "Share"
        static let copied = "Copied"
        static let chars = "chars"
        
        static let placeholderCyrToLat = "Мәтінді еңгізіңіз..."
        static let placeholderLatToCyr = "Mätindi eñgiziñiz..."
        static let exampleCyrToLat = "Мысал: Сәлем → Sälem"
        static let exampleLatToCyr = "Example: Sälem → Сәлем"
    }
    
    // MARK: - Camera Screen
    
    enum Camera {
        static let title = "Camera"
        static let tapToConvert = "Tap on recognized text to convert"
        static let result = "Result"
        static let original = "Original"
        static let converted = "Converted"
        static let save = "Save"
        static let choosePhoto = "Choose Photo"
        static let noTextFound = "No text found in the image. Try a clearer photo with better lighting."
        static let cameraNotAvailable = "Camera OCR not available"
        static let cameraNotAvailableDescription = "This device doesn't support live text scanning.\nYou can still select a photo from your library."
    }
    
    // MARK: - History Screen
    
    enum History {
        static let title = "History"
        static let search = "Search conversions..."
        static let clearAll = "Clear All"
        static let deleteAll = "Delete all history?"
        static let deleteAllMessage = "This action cannot be undone."
        static let cancel = "Cancel"
        static let noHistory = "No conversions yet"
        static let noHistoryDescription = "Your conversion history will appear here.\nStart by converting text in the Convert tab."
        static let details = "Details"
        static let info = "Info"
    }
    
    // MARK: - Settings Screen
    
    enum Settings {
        static let title = "Settings"
        static let done = "Done"
        static let alphabet = "Alphabet"
        static let standard = "Standard"
        static let recommended = "Recommended"
        static let alphabetFooter = "The 2021 version uses diacritics (ä, ö, ü, ş, ğ, ñ) and is the latest proposed standard with 31 letters."
        static let conversion = "Conversion"
        static let autoDetect = "Auto-detect direction"
        static let autoSave = "Auto-save to history"
        static let haptic = "Haptic feedback"
        static let data = "Data"
        static let clearHistory = "Clear history"
        static let clearHistoryMessage = "This will permanently delete all saved conversions."
        static let about = "About"
        static let version = "Version"
        static let privacyPolicy = "Privacy Policy"
        static let rateApp = "Rate on App Store"
    }
    
    // MARK: - Metadata
    
    enum Metadata {
        static let direction = "Direction"
        static let source = "Source"
        static let alphabetLabel = "Alphabet"
        static let date = "Date"
    }
}
