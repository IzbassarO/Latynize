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
    var confidence: Float = 0
    
    var selectedPhoto: PhotosPickerItem?
    var isProcessingPhoto = false
    
    var showError = false
    var errorMessage = ""
    
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
        confidence = 0
        HapticService.light()
    }
    
    // MARK: - Photo Processing
    
    @MainActor
    func processSelectedPhoto() async {
        guard let item = selectedPhoto else { return }
        
        isProcessingPhoto = true
        defer { isProcessingPhoto = false }
        
        do {
            // Load image data from PhotosPicker
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                errorMessage = "Could not load the selected image"
                showError = true
                return
            }
            
            // Pause live scanner while processing
            isScanning = false
            
            // Run OCR
            let blocks = try await ocrService.recognizeText(from: uiImage)
            
            guard !blocks.isEmpty else {
                errorMessage = "No text found in the image. Try a clearer photo with better lighting."
                showError = true
                isScanning = true
                return
            }
            
            // Combine all blocks
            let fullText = blocks.map(\.text).joined(separator: "\n")
            let avgConfidence = blocks.map(\.confidence).reduce(0, +) / Float(blocks.count)
            
            recognizedText = fullText
            confidence = avgConfidence
            
            // Convert
            let direction = ScriptDetector.suggestedDirection(for: fullText) ?? .cyrillicToLatin
            let result = engine.convert(fullText, direction: direction)
            convertedText = result.output
            
            HapticService.success()
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isScanning = true
        }
        
        // Clear selection so user can pick again
        selectedPhoto = nil
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
        HapticService.success()
    }
}
