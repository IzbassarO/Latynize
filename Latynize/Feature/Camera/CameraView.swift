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
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    photoPickerButton
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .task {
                viewModel.checkAvailability()
            }
        }
    }
    
    // MARK: - Scanner Layout
    
    private var scannerLayout: some View {
        ZStack(alignment: .bottom) {
            // Live camera
            DataScannerRepresentable(
                onTextRecognized: { text in
                    viewModel.handleRecognizedText(text)
                },
                onError: { error in
                    viewModel.handleError(error)
                },
                isScanning: $viewModel.isScanning
            )
            .ignoresSafeArea(edges: .top)
            
            // Instruction overlay (when no text recognized yet)
            if !viewModel.hasResult {
                instructionOverlay
            }
            
            // Result bottom sheet
            if viewModel.hasResult {
                resultCard
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.hasResult)
    }
    
    private var instructionOverlay: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: "hand.tap")
                    .font(.subheadline)
                Text("Tap on recognized text to convert")
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Result Card
    
    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Label("Result", systemImage: "text.viewfinder")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Button {
                    viewModel.clearResult()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
            
            // Recognized original
            VStack(alignment: .leading, spacing: 4) {
                Text("Original")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.recognizedText)
                    .font(.body)
                    .lineLimit(3)
            }
            
            // Converted
            VStack(alignment: .leading, spacing: 4) {
                Text("Converted")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.convertedText)
                    .font(.body)
                    .fontWeight(.medium)
                    .textSelection(.enabled)
                    .lineLimit(3)
            }
            
            // Actions
            HStack(spacing: 12) {
                Button {
                    UIPasteboard.general.string = viewModel.convertedText
                    HapticService.success()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                ShareLink(item: viewModel.convertedText) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button {
                    viewModel.saveToHistory(context: modelContext)
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .font(.subheadline)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
    
    // MARK: - Photo Picker
    
    private var photoPickerButton: some View {
        PhotosPicker(
            selection: $viewModel.selectedPhoto,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Image(systemName: "photo.on.rectangle")
        }
        .onChange(of: viewModel.selectedPhoto) {
            Task {
                await viewModel.processSelectedPhoto()
            }
        }
    }
    
    // MARK: - Fallback (unsupported device)
    
    private var fallbackLayout: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "camera.badge.ellipsis")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            
            Text("Camera OCR not available")
                .font(.headline)
            
            Text("This device doesn't support live text scanning.\nYou can still select a photo from your library.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            PhotosPicker(
                selection: $viewModel.selectedPhoto,
                matching: .images
            ) {
                Label("Choose Photo", systemImage: "photo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 40)
            .onChange(of: viewModel.selectedPhoto) {
                Task {
                    await viewModel.processSelectedPhoto()
                }
            }
            
            if viewModel.hasResult {
                resultCard
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    CameraView()
        .modelContainer(for: ConversionRecord.self, inMemory: true)
}
