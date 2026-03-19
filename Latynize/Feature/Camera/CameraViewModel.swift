//
//  CameraViewModel.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation
import SwiftUI
import SwiftData
import PhotosUI
import VisionKit

@Observable
final class CameraViewModel {
    
    // MARK: - State
    
    var isScanning = true
    var deviceSupportsScanner = false
    
    var recognizedText = ""
    var convertedText = ""
    var selectedPhoto: PhotosPickerItem?
    var isProcessingPhoto = false
    
    // Smart OCR stats
    var recognizedBlockCount = 0
    var averageConfidence: Float = 0
    var detectedScript: String = ""
    var wordCount: Int { convertedText.split(separator: " ").count }
    
    var showError = false
    var errorMessage = ""
    var showSavedToast = false
    
    var hasResult: Bool { !recognizedText.isEmpty }
    
    // MARK: - Private
    
    private let engine = ConversionEngine.shared
    private let ocrService = OCRService.shared
    
    // MARK: - Availability
    
    func checkAvailability() {
        deviceSupportsScanner = DataScannerViewController.isSupported &&
                                DataScannerViewController.isAvailable
    }
    
    // MARK: - Live Scanner
    
    func handleRecognizedText(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        recognizedText = text
        recognizedBlockCount = 1
        averageConfidence = 0.95 // DataScanner doesn't expose confidence per tap
        
        let script = ScriptDetector.detect(text)
        detectedScript = script == .cyrillic ? "Cyrillic" : script == .latin ? "Latin" : "Mixed"
        
        let direction = ScriptDetector.suggestedDirection(for: text) ?? .cyrillicToLatin
        let result = engine.convert(text, direction: direction)
        convertedText = result.output
        
        HapticService.light()
    }
    
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
    
    func clearResult() {
        recognizedText = ""
        convertedText = ""
        recognizedBlockCount = 0
        averageConfidence = 0
        detectedScript = ""
        isScanning = true
        HapticService.light()
    }
    
    // MARK: - Photo Processing
    
    @MainActor
    func processSelectedPhoto() async {
        guard let item = selectedPhoto else { return }
        
        isProcessingPhoto = true
        defer {
            isProcessingPhoto = false
            selectedPhoto = nil
        }
        
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                errorMessage = "Could not load the selected image."
                showError = true
                return
            }
            
            isScanning = false
            
            let blocks = try await ocrService.recognizeText(from: uiImage)
            
            guard !blocks.isEmpty else {
                errorMessage = "No text detected in this image.\n\nTips:\n• Use a well-lit photo\n• Make sure text is clearly visible\n• Try a closer crop of the text area"
                showError = true
                isScanning = true
                return
            }
            
            // Aggregate results
            let fullText = blocks.map(\.text).joined(separator: "\n")
            let avgConf = blocks.map(\.confidence).reduce(0, +) / Float(blocks.count)
            
            recognizedText = fullText
            recognizedBlockCount = blocks.count
            averageConfidence = avgConf
            
            let script = ScriptDetector.detect(fullText)
            detectedScript = script == .cyrillic ? "Cyrillic" : script == .latin ? "Latin" : "Mixed"
            
            let direction = ScriptDetector.suggestedDirection(for: fullText) ?? .cyrillicToLatin
            let result = engine.convert(fullText, direction: direction)
            convertedText = result.output
            
            HapticService.success()
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isScanning = true
        }
    }
    
    // MARK: - History
    
    func saveToHistory(context: ModelContext) {
        guard hasResult else { return }
        let direction = ScriptDetector.suggestedDirection(for: recognizedText) ?? .cyrillicToLatin
        let record = ConversionRecord(
            inputText: recognizedText,
            outputText: convertedText,
            direction: direction,
            source: .camera,
            alphabetVersion: AppSettings.shared.alphabetVersion
        )
        context.insert(record)
        showSavedToast = true
        HapticService.success()
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            showSavedToast = false
        }
    }
    
    func copyConverted() {
        UIPasteboard.general.string = convertedText
        HapticService.success()
    }
}
