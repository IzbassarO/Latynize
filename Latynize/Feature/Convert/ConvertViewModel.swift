//
//  ConvertViewModel.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
final class ConvertViewModel {
    
    // MARK: - State
    
    var inputText: String = ""
    var outputText: String = ""
    var direction: ConversionDirection = .cyrillicToLatin
    var selectedMappingID: String = AppSettings.shared.alphabetVersion
    
    var showCopiedToast = false
    var showClipboardSuggestion = false
    var clipboardText: String = ""
    var showAlphabetReference = false
    
    var characterCount: Int { inputText.count }
    var wordCount: Int {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? 0
            : inputText.split(separator: " ").count
    }
    var hasInput: Bool { !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    // MARK: - Stats for output
    
    var convertedWordCount: Int {
        guard hasInput else { return 0 }
        return outputText.split(separator: " ").count
    }
    var isCurrentFavorited: Bool = false
    
    // MARK: - Example phrases
    
    let examplePhrases: [(cyrillic: String, latin: String)] = [
        ("Сәлем!", "Sälem!"),
        ("Қазақстан Республикасы", "Qazaqstan Respublikası"),
        ("Менің атым...", "Meniñ atım..."),
        ("Астана — Қазақстанның астанасы", "Astana — Qazaqstannnıñ astanası"),
        ("Қайырлы таң!", "Qaiırlı tañ!"),
    ]
    
    // MARK: - Private
    
    private let engine = ConversionEngine.shared
    private var debounceTask: Task<Void, Never>?
    private var autoSaveTask: Task<Void, Never>?
    
    // MARK: - Smart Clipboard
    
    func checkClipboard() {
        guard let text = UIPasteboard.general.string,
              !text.isEmpty,
              text.count >= 3,
              text.count <= 500,
              text != inputText else {
            showClipboardSuggestion = false
            return
        }
        
        // Check if clipboard has Kazakh Cyrillic or Latin text
        let detected = ScriptDetector.detect(text)
        if detected == .cyrillic || detected == .latin {
            clipboardText = text
            showClipboardSuggestion = true
        }
    }
    
    func applyClipboardSuggestion() {
        inputText = clipboardText
        if let detected = ScriptDetector.suggestedDirection(for: clipboardText) {
            direction = detected
        }
        performConversion()
        showClipboardSuggestion = false
        HapticService.light()
    }
    
    func dismissClipboardSuggestion() {
        showClipboardSuggestion = false
    }
    
    // MARK: - Example Phrase
    
    func applyExample(_ phrase: String) {
        inputText = phrase
        direction = .cyrillicToLatin
        performConversion()
        HapticService.light()
    }
    
    // MARK: - Core Actions
    
    func onInputChanged() {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(80))
            guard !Task.isCancelled else { return }
            performConversion()
            isCurrentFavorited = false
        }
    }
    
    func toggleDirection() {
        direction = direction.toggled
        HapticService.selection()
        if hasInput {
            let previousOutput = outputText
            inputText = previousOutput
            performConversion()
        }
        AppSettings.shared.lastUsedDirection = direction
    }
    
    func clearInput() {
        inputText = ""
        outputText = ""
        HapticService.light()
    }
    
    func pasteFromClipboard() {
        guard let text = UIPasteboard.general.string, !text.isEmpty else { return }
        inputText = text
        if AppSettings.shared.autoDetectDirection {
            if let detected = ScriptDetector.suggestedDirection(for: text) {
                direction = detected
            }
        }
        performConversion()
        showClipboardSuggestion = false
        HapticService.light()
    }
    
    func copyOutput() {
        guard hasInput else { return }
        UIPasteboard.general.string = outputText
        showCopiedToast = true
        HapticService.success()
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            showCopiedToast = false
        }
    }
    
    func saveToHistory(context: ModelContext) {
        guard hasInput, inputText.count >= 3 else { return }
        let record = ConversionRecord(
            inputText: inputText,
            outputText: outputText,
            direction: direction,
            source: .text,
            alphabetVersion: selectedMappingID
        )
        context.insert(record)
    }
    
    func scheduleAutoSave(context: ModelContext) {
        guard AppSettings.shared.autoSaveHistory else { return }
        autoSaveTask?.cancel()
        autoSaveTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled, hasInput else { return }
            saveToHistory(context: context)
        }
    }
    
    private func performConversion() {
        guard hasInput else {
            outputText = ""
            return
        }
        let result = engine.convert(inputText, direction: direction, mappingID: selectedMappingID)
        outputText = result.output
    }
    
    func toggleCurrentFavorite(context: ModelContext) {
        guard hasInput, !outputText.isEmpty else { return }
        
        let currentInput = inputText
        let currentOutput = outputText
        
        let predicate = #Predicate<ConversionRecord> { record in
            record.inputText == currentInput &&
            record.outputText == currentOutput
        }
        
        let descriptor = FetchDescriptor<ConversionRecord>(predicate: predicate)
        
        do {
            if let existing = try context.fetch(descriptor).first {
                existing.isFavorite.toggle()
                isCurrentFavorited = existing.isFavorite
            } else {
                let record = ConversionRecord(
                    inputText: inputText,
                    outputText: outputText,
                    direction: direction,
                    source: .text,
                    alphabetVersion: selectedMappingID,
                    isFavorite: true
                )
                context.insert(record)
                isCurrentFavorited = true
            }
            
            try context.save()
            HapticService.success()
        } catch {
            print("Failed to toggle favorite: \(error)")
        }
    }
}
