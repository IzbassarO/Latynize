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
    @State private var whatsNewService = WhatsNewService.shared
    @State private var showWhatsNew = false
    
    init() {
        // Support UI test launch arguments
        if CommandLine.arguments.contains("-resetOnboarding") {
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
            UserDefaults.standard.removeObject(forKey: "WhatsNew.lastSeenVersion")
            UserDefaults.standard.removeObject(forKey: "WhatsNew.hasLaunchedBefore")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
                .environment(themeManager)
                .environment(languageManager)
                .environment(\.locale, languageManager.locale)
                .onAppear {
                    if whatsNewService.shouldShowWhatsNew {
                        // Slight delay to let UI settle
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showWhatsNew = true
                        }
                    }
                }
                .sheet(isPresented: $showWhatsNew) {
                    WhatsNewSheet()
                        .environment(themeManager)
                        .preferredColorScheme(themeManager.currentTheme.colorScheme)
                }
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
