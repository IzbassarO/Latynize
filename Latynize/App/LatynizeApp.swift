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
    @State private var deepLinkLetter: String?
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
                .environment(themeManager)
                .environment(languageManager)
                .environment(\.locale, languageManager.locale)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .modelContainer(for: ConversionRecord.self)
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "latynize" else { return }
        
        if url.host == "letter" {
            let letter = url.lastPathComponent
            deepLinkLetter = letter
            // Post notification so ConvertView can pre-fill
            NotificationCenter.default.post(
                name: .openLetterFromWidget,
                object: nil,
                userInfo: ["letter": letter]
            )
        }
    }
}

extension Notification.Name {
    static let openLetterFromWidget = Notification.Name("openLetterFromWidget")
}
