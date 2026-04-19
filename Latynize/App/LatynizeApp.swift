//
//  LatynizeApp.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import SwiftUI
import SwiftData

@main
struct LatynizeApp: App {
    
    @State private var themeManager = ThemeManager.shared
    @State private var languageManager = LanguageManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
                .environment(themeManager)
                .environment(languageManager)
                .environment(\.locale, languageManager.locale)
        }
        .modelContainer(for: ConversionRecord.self)
    }
}
