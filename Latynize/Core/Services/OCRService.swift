//
//  OCRService.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation
import Vision
import UIKit

/// Handles text recognition from images using Apple Vision framework.
/// Works on-device, no network required.
final class OCRService {
    
    static let shared = OCRService()
    
    /// Recognition configuration optimized for Kazakh Cyrillic text
    struct Configuration {
        var recognitionLevel: VNRequestTextRecognitionLevel = .accurate
        var recognitionLanguages: [String] = ["kk-KZ", "ru-RU", "en-US"]
        var usesLanguageCorrection: Bool = true
        var minimumTextHeight: Float = 0.0 // 0 = no minimum
    }
    
    var configuration = Configuration()
    
    // MARK: - Recognition from UIImage
    
    /// Recognizes text from a UIImage.
    /// Returns array of recognized text blocks sorted top-to-bottom.
    func recognizeText(from image: UIImage) async throws -> [RecognizedBlock] {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: OCRError.visionError(error))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let blocks = observations.compactMap { observation -> RecognizedBlock? in
                    guard let candidate = observation.topCandidates(1).first else { return nil }
                    return RecognizedBlock(
                        text: candidate.string,
                        confidence: candidate.confidence,
                        boundingBox: observation.boundingBox
                    )
                }
                
                // Sort top-to-bottom (Vision uses bottom-left origin,
                // so higher Y = higher on screen)
                let sorted = blocks.sorted { $0.boundingBox.origin.y > $1.boundingBox.origin.y }
                continuation.resume(returning: sorted)
            }
            
            request.recognitionLevel = configuration.recognitionLevel
            request.recognitionLanguages = configuration.recognitionLanguages
            request.usesLanguageCorrection = configuration.usesLanguageCorrection
            
            if configuration.minimumTextHeight > 0 {
                request.minimumTextHeight = configuration.minimumTextHeight
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: OCRError.visionError(error))
            }
        }
    }
    
    /// Convenience: returns all recognized text joined as a single string.
    func recognizeFullText(from image: UIImage) async throws -> String {
        let blocks = try await recognizeText(from: image)
        return blocks.map(\.text).joined(separator: "\n")
    }
    
    /// Returns supported languages for text recognition on this device.
    func supportedLanguages() -> [String] {
        let revision = VNRecognizeTextRequest.currentRevision
        do {
            return try VNRecognizeTextRequest.supportedRecognitionLanguages(
                for: .accurate,
                revision: revision
            )
        } catch {
            return []
        }
    }
}

// MARK: - Models

struct RecognizedBlock: Identifiable {
    let id = UUID()
    let text: String
    let confidence: Float
    let boundingBox: CGRect // Normalized (0..1), bottom-left origin
    
    /// Confidence as percentage string: "95%"
    var confidenceLabel: String {
        "\(Int(confidence * 100))%"
    }
}

// MARK: - Errors

enum OCRError: LocalizedError {
    case invalidImage
    case visionError(Error)
    case cameraNotAvailable
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Could not process the image"
        case .visionError(let error):
            return "Recognition failed: \(error.localizedDescription)"
        case .cameraNotAvailable:
            return "Camera is not available on this device"
        case .permissionDenied:
            return "Camera access denied. Enable in Settings."
        }
    }
}
