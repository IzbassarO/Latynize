//
//  DataScannerRepresentable.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation
import SwiftUI
import VisionKit

/// Provides live camera text recognition with bounding box overlays.
struct DataScannerRepresentable: UIViewControllerRepresentable {
    
    let onTextRecognized: (String) -> Void
    let onError: (Error) -> Void
    
    @Binding var isScanning: Bool
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ scanner: DataScannerViewController, context: Context) {
        if isScanning {
            if !scanner.isScanning {
                try? scanner.startScanning()
            }
        } else {
            if scanner.isScanning {
                scanner.stopScanning()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onTextRecognized: onTextRecognized, onError: onError)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        let onTextRecognized: (String) -> Void
        let onError: (Error) -> Void
        
        init(onTextRecognized: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
            self.onTextRecognized = onTextRecognized
            self.onError = onError
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                onTextRecognized(text.transcript)
            default:
                break
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            onError(OCRError.cameraNotAvailable)
        }
    }
}
