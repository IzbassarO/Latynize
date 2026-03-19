//
//  SettingsView.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation
import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage(AppSettings.Key.alphabetVersion)
    private var alphabetVersion = "2021"
    
    @AppStorage(AppSettings.Key.autoDetectDirection)
    private var autoDetect = true
    
    @AppStorage(AppSettings.Key.autoSaveHistory)
    private var autoSave = true
    
    @AppStorage(AppSettings.Key.hapticFeedback)
    private var hapticEnabled = true
    
    @State private var showClearAlert = false
    @State private var showAlphabetInfo = false
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationStack {
            Form {
                alphabetSection
                conversionSection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.medium)
                }
            }
            .alert("Clear all history?", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) { clearHistory() }
            } message: {
                Text("This will permanently delete all saved conversions.")
            }
            .sheet(isPresented: $showAlphabetInfo) {
                alphabetInfoSheet
            }
        }
    }
    
    // MARK: - Alphabet Section
    
    private var alphabetSection: some View {
        Section {
            Picker("Standard", selection: $alphabetVersion) {
                ForEach(ConversionEngine.shared.availableMappings, id: \.id) { mapping in
                    HStack {
                        Text(mapping.displayName)
                        if mapping.isRecommended {
                            Text("✓")
                                .foregroundStyle(.green)
                        }
                    }
                    .tag(mapping.id)
                }
            }
            
            Button {
                showAlphabetInfo = true
            } label: {
                HStack {
                    Text("About alphabet versions")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Alphabet")
        } footer: {
            Text("The 2021 standard uses diacritics (ä, ö, ü, ş, ğ, ñ) with 31 letters. Recommended for most users.")
        }
    }
    
    // MARK: - Conversion Section
    
    private var conversionSection: some View {
        Section {
            Toggle("Auto-detect direction", isOn: $autoDetect)
            Toggle("Auto-save to history", isOn: $autoSave)
            Toggle("Haptic feedback", isOn: $hapticEnabled)
        } header: {
            Text("Conversion")
        } footer: {
            Text("Auto-detect analyzes your input text and sets the conversion direction automatically.")
        }
    }
    
    // MARK: - Data Section
    
    private var dataSection: some View {
        Section("Data") {
            Button("Clear history", role: .destructive) {
                showClearAlert = true
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("\(appVersion) (\(buildNumber))")
                    .foregroundStyle(.secondary)
            }
            
            Link(destination: URL(string: "https://izbassar.dev/latynize/privacy")!) {
                HStack {
                    Text("Privacy Policy")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // MARK: - Alphabet Info Sheet
    
    private var alphabetInfoSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 2021 version
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("2021 Standard")
                                .font(.headline)
                            Text("Recommended")
                                .font(.caption)
                                .foregroundStyle(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.green.opacity(0.1), in: Capsule())
                        }
                        
                        Text("31 letters with diacritical marks based on international practice. Uses umlauts (ä, ö, ü), macron (ū), cedilla (ş, ğ), and tilde (ñ).")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("A Ä B D E F G Ğ H İ I J K L M N Ñ O Ö P Q R S Ş T U Ū Ü V Y Z")
                            .font(.system(.caption, design: .monospaced))
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Divider()
                    
                    // 2018 version
                    VStack(alignment: .leading, spacing: 8) {
                        Text("2018 Standard (Decree №637)")
                            .font(.headline)
                        
                        Text("32 letters with acute accents and digraphs. Replaced the 2017 apostrophe-based version. Uses á, ǵ, ń, ó, ú, ý, í and digraphs like Sh for Ш.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("A Á B V G Ǵ D E J Z I K Q L M N Ń O Ó P R S T U Ú Ý F H Sh Y Í")
                            .font(.system(.caption, design: .monospaced))
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Divider()
                    
                    // Context
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Background")
                            .font(.headline)
                        
                        Text("Kazakhstan is transitioning its Kazakh alphabet from Cyrillic to Latin script. The reform was initiated in 2017 with a phased transition planned through 2031. Multiple versions of the Latin alphabet have been proposed — the 2021 version is widely considered the final candidate.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Alphabet Versions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showAlphabetInfo = false }
                }
            }
        }
        .presentationDetents([.large])
    }
    
    // MARK: - Actions
    
    private func clearHistory() {
        do {
            try modelContext.delete(model: ConversionRecord.self)
            HapticService.medium()
        } catch {
            print("Failed to clear history: \(error)")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: ConversionRecord.self, inMemory: true)
}
