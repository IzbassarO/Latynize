//
//  SettingsView.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation
import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @Environment(LanguageManager.self) private var language
    
    @AppStorage(AppSettings.Key.alphabetVersion) private var alphabetVersion = "2021"
    @AppStorage(AppSettings.Key.autoDetectDirection) private var autoDetect = true
    @AppStorage(AppSettings.Key.autoSaveHistory) private var autoSave = true
    @AppStorage(AppSettings.Key.hapticFeedback) private var hapticEnabled = true
    
    @State private var showClearAlert = false
    @State private var showAlphabetInfo = false
    @State private var showFeedbackMail = false
    @State private var showShareSheet = false
    
    private let appStoreURL = "https://apps.apple.com/kz/app/latynize/id6760948497"
    private let feedbackEmail = "izbassar.eng@gmail.com"
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationStack {
            Form {
                standardSection
                appearanceSection
                languageSection
                preferencesSection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.fontWeight(.semibold)
                }
            }
            .alert("Clear all history?", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) { clearHistory() }
            } message: {
                Text("All saved conversions will be permanently deleted.")
            }
            .sheet(isPresented: $showAlphabetInfo) {
                alphabetSheet
                    .environment(theme)
                    .preferredColorScheme(theme.currentTheme.colorScheme)
            }
        }
    }
    
    // MARK: - Standard Section
    
    private var standardSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Conversion Standard")
                        .font(.system(size: 15))
                    Text(alphabetVersion == "2021" ? "Modern · 31 letters · Diacritics" : "Legacy · 32 letters · Acute accents")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Picker("", selection: $alphabetVersion) {
                    Text("2021").tag("2021")
                    Text("2018").tag("2018")
                }
                .pickerStyle(.segmented)
                .frame(width: 130)
            }
            
            Button {
                showAlphabetInfo = true
            } label: {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(Color.accentTeal)
                    Text("Compare standards")
                        .foregroundStyle(.primary)
                        .font(.system(size: 15))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        } header: {
            Text("Standard")
        }
    }
    
    // MARK: - Appearance
        
    private var appearanceSection: some View {
        @Bindable var themeBinding = theme
        
        return Section {
            HStack(spacing: 10) {
                ForEach(AppTheme.allCases, id: \.self) { option in
                    themeOption(option, isSelected: theme.currentTheme == option) {
                        withAnimation(.smooth(duration: 0.4)) {
                            themeBinding.currentTheme = option
                        }
                        HapticService.selection()
                    }
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Appearance")
        }
    }
    
    private func themeOption(_ theme: AppTheme, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.accentTeal : Color(uiColor: .tertiarySystemFill))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: theme.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .symbolRenderingMode(.hierarchical)
                }
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(.spring(duration: 0.35, bounce: 0.35), value: isSelected)
                
                Text(theme.label)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? Color.accentTeal : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.accentTeal.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Language
        
    private var languageSection: some View {
        @Bindable var langBinding = language
        
        return Section {
            Picker(selection: $langBinding.currentLanguage) {
                ForEach(AppLanguage.allCases, id: \.self) { option in
                    Text(option.label).tag(option)
                }
            } label: {
                Text("Language")
                    .font(.system(size: 15))
            }
            .tint(Color.accentTeal)
            .onChange(of: language.currentLanguage) { _, _ in
                HapticService.selection()
            }
        } header: {
            Text("Language")
        }
    }
    
    // MARK: - Preferences
        
    private var preferencesSection: some View {
        Section {
            Toggle(isOn: $autoDetect) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Smart direction")
                        .font(.system(size: 15))
                    Text("Auto-detect Cyrillic or Latin input")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .tint(Color.accentTeal)
            
            Toggle(isOn: $autoSave) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Auto-save history")
                        .font(.system(size: 15))
                    Text("Save conversions automatically")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .tint(Color.accentTeal)
            
            Toggle("Haptic feedback", isOn: $hapticEnabled)
                .font(.system(size: 15))
                .tint(Color.accentTeal)
        } header: {
            Text("Preferences")
        }
    }
    
    // MARK: - Data
        
    private var dataSection: some View {
        Section {
            Button(role: .destructive) {
                showClearAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Clear conversion history")
                }
                .font(.system(size: 15))
            }
        } header: {
            Text("Data")
        }
    }
    
    // MARK: - About
        
    private var aboutSection: some View {
        Section {
            // Rate the app
            Button {
                requestReview()
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.orange)
                        .frame(width: 24)
                    Text("Rate Latynize")
                        .foregroundStyle(.primary)
                        .font(.system(size: 15))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            
            // Share the app
            ShareLink(
                item: URL(string: appStoreURL)!,
                subject: Text("Latynize"),
                message: Text("Check out Latynize — Kazakh script converter")
            ) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Color.accentTeal)
                        .frame(width: 24)
                    Text("Share Latynize")
                        .foregroundStyle(.primary)
                        .font(.system(size: 15))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            
            // Privacy Policy
            Link(destination: URL(string: "https://izbassar.dev/privacy")!) {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(.gray)
                        .frame(width: 24)
                    Text("Privacy Policy")
                        .foregroundStyle(.primary)
                        .font(.system(size: 15))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
            }
            
            // Version (read-only)
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(.gray)
                    .frame(width: 24)
                Text("Version")
                    .font(.system(size: 15))
                Spacer()
                Text("\(appVersion) (\(buildNumber))")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            
        } header: {
            Text("About")
        } footer: {
            VStack(spacing: 6) {
                Text("Made with care for Kazakhstan")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                Text("All processing happens on-device. No data leaves your phone.")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
        }
    }
    
    // MARK: - Alphabet Info Sheet
    
    private var alphabetSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    standardCard(
                        title: "Standard 2021",
                        badge: "Recommended",
                        badgeColor: Color.accentTeal,
                        description: "31 letters using internationally recognized diacritical marks. Follows the \"one sound — one letter\" principle.",
                        details: "Uses umlauts (ä, ö, ü), macron (ū), cedilla (ş, ğ), and tilde (ñ).",
                        alphabet: "A Ä B D E F G Ğ H İ I J K L M N Ñ O Ö P Q R S Ş T U Ū Ü V Y Z"
                    )
                    
                    standardCard(
                        title: "Legacy 2018",
                        badge: "Decree №637",
                        badgeColor: .secondary,
                        description: "32 letters using acute accents and digraphs. Replaced the 2017 apostrophe version.",
                        details: "Uses á, ǵ, ń, ó, ú, ý, í and digraphs like Sh for Ш.",
                        alphabet: "A Á B V G Ǵ D E J Z I K Q L M N Ń O Ó P R S T U Ú Ý F H Sh Y Í"
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Background")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Kazakhstan is transitioning its Kazakh-language alphabet from Cyrillic to Latin script. The reform started in 2017 with a phased transition planned through 2031. The 2021 version is widely considered the final candidate.")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Standards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showAlphabetInfo = false }
                }
            }
        }
    }
    
    private func standardCard(title: String, badge: String, badgeColor: Color, description: String, details: String, alphabet: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                Text(badge)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(badgeColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(badgeColor.opacity(0.12), in: Capsule())
            }
            
            Text(description)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .lineSpacing(2)
            
            Text(details)
                .font(.system(size: 13))
                .foregroundStyle(.tertiary)
            
            Text(alphabet)
                .font(.system(size: 13, design: .monospaced))
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
    
    // MARK: - About Actions

    private func requestReview() {
        HapticService.light()
        
        // Use SKStoreReviewController for in-app review prompt
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
    }

    private func sendFeedback() {
        HapticService.light()
        
        let subject = "Latynize Feedback (v\(appVersion))"
        let body = """
        
        
        ---
        App: Latynize
        Version: \(appVersion) (\(buildNumber))
        Device: \(UIDevice.current.model)
        iOS: \(UIDevice.current.systemVersion)
        Language: \(language.currentLanguage.rawValue)
        """
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:\(feedbackEmail)?subject=\(encodedSubject)&body=\(encodedBody)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func clearHistory() {
        do {
            try modelContext.delete(model: ConversionRecord.self)
            HapticService.medium()
        } catch {
            print("Failed: \(error)")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: ConversionRecord.self, inMemory: true)
}
