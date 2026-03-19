//
//  CameraView.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation
import SwiftUI
import SwiftData
import PhotosUI
import VisionKit

struct CameraView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CameraViewModel()
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.deviceSupportsScanner {
                    scannerLayout
                } else {
                    fallbackLayout
                }
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    photoPickerButton
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .alert("OCR Result", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .task { viewModel.checkAvailability() }
        }
    }
    
    // MARK: - Scanner Layout
    
    private var scannerLayout: some View {
        ZStack(alignment: .bottom) {
            DataScannerRepresentable(
                onTextRecognized: { viewModel.handleRecognizedText($0) },
                onError: { viewModel.handleError($0) },
                isScanning: $viewModel.isScanning
            )
            .ignoresSafeArea(edges: .top)
            
            if !viewModel.hasResult {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "hand.tap")
                        Text("Tap recognized text to convert")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 40)
                }
            }
            
            if viewModel.hasResult {
                resultCard
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: viewModel.hasResult)
        .overlay(alignment: .top) {
            if viewModel.showSavedToast {
                savedToast.transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: viewModel.showSavedToast)
    }
    
    // MARK: - Result Card
    
    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with stats
            HStack {
                Image(systemName: "text.viewfinder")
                    .foregroundStyle(Color.accentTeal)
                Text("Scan Result")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                
                // OCR stats badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(confidenceColor)
                        .frame(width: 6, height: 6)
                    Text("\(Int(viewModel.averageConfidence * 100))%")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                    Text("·")
                    Text(viewModel.detectedScript)
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(.secondary)
                
                Button { viewModel.clearResult() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.tertiary)
                }
            }
            
            // Original
            VStack(alignment: .leading, spacing: 4) {
                Text("Recognized")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(viewModel.recognizedText)
                    .font(.system(size: 14))
                    .lineLimit(3)
                    .textSelection(.enabled)
            }
            
            // Converted
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Converted")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(viewModel.wordCount) words")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
                Text(viewModel.convertedText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.accentTeal)
                    .textSelection(.enabled)
                    .lineLimit(3)
            }
            
            // Actions
            HStack(spacing: 8) {
                Button {
                    viewModel.copyConverted()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "doc.on.doc").font(.system(size: 12))
                        Text("Copy").font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(Color.accentTeal, in: Capsule())
                }
                
                ShareLink(item: viewModel.convertedText) {
                    HStack(spacing: 5) {
                        Image(systemName: "square.and.arrow.up").font(.system(size: 12))
                        Text("Share").font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(Color(uiColor: .tertiarySystemFill), in: Capsule())
                }
                
                Button {
                    viewModel.saveToHistory(context: modelContext)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "bookmark").font(.system(size: 12))
                        Text("Save").font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(Color(uiColor: .tertiarySystemFill), in: Capsule())
                }
                
                Spacer()
            }
        }
        .padding(18)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
    
    private var confidenceColor: Color {
        if viewModel.averageConfidence >= 0.9 { return .green }
        if viewModel.averageConfidence >= 0.7 { return .orange }
        return .red
    }
    
    private var savedToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "bookmark.fill")
            Text("Saved to history")
        }
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Capsule().fill(Color.accentTeal))
        .padding(.top, 60)
    }
    
    // MARK: - Photo Picker
    
    private var photoPickerButton: some View {
        PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
            Image(systemName: "photo.on.rectangle.angled")
                .symbolRenderingMode(.hierarchical)
        }
        .onChange(of: viewModel.selectedPhoto) {
            Task { await viewModel.processSelectedPhoto() }
        }
        .overlay {
            if viewModel.isProcessingPhoto {
                ProgressView()
                    .scaleEffect(0.7)
            }
        }
    }
    
    // MARK: - Fallback
    
    private var fallbackLayout: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 60)
                
                ZStack {
                    Circle()
                        .fill(Color.accentTeal.opacity(0.08))
                        .frame(width: 120, height: 120)
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(Color.accentTeal.opacity(0.6))
                }
                
                VStack(spacing: 8) {
                    Text("Camera OCR")
                        .font(.system(size: 22, weight: .bold))
                    Text("Live scanning requires a physical device.\nChoose a photo to scan text from an image.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo")
                        Text("Choose Photo")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: 260)
                    .padding(.vertical, 14)
                    .background(Color.accentTeal, in: RoundedRectangle(cornerRadius: 14))
                }
                .onChange(of: viewModel.selectedPhoto) {
                    Task { await viewModel.processSelectedPhoto() }
                }
                
                if viewModel.isProcessingPhoto {
                    ProgressView("Scanning text...")
                        .font(.system(size: 14))
                }
                
                if viewModel.hasResult {
                    resultCard
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    CameraView()
        .modelContainer(for: ConversionRecord.self, inMemory: true)
}
