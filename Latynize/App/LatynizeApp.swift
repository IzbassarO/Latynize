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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
                .environment(themeManager)
        }
        .modelContainer(for: ConversionRecord.self)
    }
}
