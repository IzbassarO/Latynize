//
//  ConvertViewModel.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@Observable
final class ConvertViewModel {
    
    // MARK: - State
    
    var inputText: String = ""
    var outputText: String = ""
    var direction: ConversionDirection = .cyrillicToLatin
    var selectedMappingID: String = AppSettings.shared.alphabetVersion
    
    var showCopiedToast = false
    var characterCount: Int { inputText.count }
    var hasInput: Bool { !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    // MARK: - Private
    
    private let engine = ConversionEngine.shared
    private var debounceTask: Task<Void, Never>?
    private var autoSaveTask: Task<Void, Never>?
    
    // MARK: - Actions
    
    func onInputChanged() {
        // Debounce conversion: 80ms
        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(80))
            guard !Task.isCancelled else { return }
            performConversion()
        }
    }
    
    func toggleDirection() {
        direction = direction.toggled
        HapticService.selection()
        
        // Swap: move output to input and re-convert
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
        
        // Auto-detect direction if enabled
        if AppSettings.shared.autoDetectDirection {
            if let detected = ScriptDetector.suggestedDirection(for: text) {
                direction = detected
            }
        }
        
        performConversion()
        HapticService.light()
    }
    
    func copyOutput() {
        guard hasInput else { return }
        UIPasteboard.general.string = outputText
        showCopiedToast = true
        HapticService.success()
        
        // Auto-hide toast
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            showCopiedToast = false
        }
    }
    
    /// Called when auto-saving to history after idle period.
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
    
    // MARK: - Private
    
    private func performConversion() {
        guard hasInput else {
            outputText = ""
            return
        }
        
        let result = engine.convert(inputText, direction: direction, mappingID: selectedMappingID)
        outputText = result.output
    }
}
