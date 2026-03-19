//
//  ConvertView.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation
import SwiftUI
import SwiftData

struct ConvertView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ConvertViewModel()
    @State private var showSettings = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        directionCard
                        inputCard
                        outputCard
                        mappingInfo
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 100) // space for keyboard
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Latynize")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .overlay(alignment: .top) {
                if viewModel.showCopiedToast {
                    toastBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(duration: 0.3), value: viewModel.showCopiedToast)
        }
    }
    
    // MARK: - Direction Card
    
    private var directionCard: some View {
        HStack(spacing: 0) {
            // Source label
            VStack(spacing: 2) {
                Text(directionSourceLabel)
                    .font(.subheadline.weight(.medium))
                Text(directionSourceScript)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
            
            // Swap button
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    viewModel.toggleDirection()
                }
            } label: {
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .font(.system(size: 36))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.primary)
                    .rotationEffect(.degrees(viewModel.direction == .cyrillicToLatin ? 0 : 180))
            }
            .accessibilityLabel("Swap direction")
            
            // Target label
            VStack(spacing: 2) {
                Text(directionTargetLabel)
                    .font(.subheadline.weight(.medium))
                Text(directionTargetScript)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
    
    private var directionSourceLabel: String {
        viewModel.direction == .cyrillicToLatin ? "Кириллица" : "Латын"
    }
    
    private var directionTargetLabel: String {
        viewModel.direction == .cyrillicToLatin ? "Латын" : "Кириллица"
    }
    
    private var directionSourceScript: String {
        viewModel.direction == .cyrillicToLatin ? "Cyrillic" : "Latin"
    }
    
    private var directionTargetScript: String {
        viewModel.direction == .cyrillicToLatin ? "Latin" : "Cyrillic"
    }
    
    // MARK: - Input Card
    
    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Label("Input", systemImage: "text.cursor")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(viewModel.characterCount)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Text editor
            ZStack(alignment: .topLeading) {
                if !viewModel.hasInput {
                    Text(inputPlaceholder)
                        .foregroundStyle(.quaternary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: $viewModel.inputText)
                    .focused($isInputFocused)
                    .frame(minHeight: 90, maxHeight: 180)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 8)
                    .onChange(of: viewModel.inputText) {
                        viewModel.onInputChanged()
                        viewModel.scheduleAutoSave(context: modelContext)
                    }
            }
            
            // Action bar
            HStack(spacing: 16) {
                Spacer()
                
                if viewModel.hasInput {
                    actionButton(icon: "xmark.circle", label: "Clear") {
                        viewModel.clearInput()
                        isInputFocused = false
                    }
                }
                
                actionButton(icon: "doc.on.clipboard", label: "Paste") {
                    viewModel.pasteFromClipboard()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }
    
    private var inputPlaceholder: String {
        viewModel.direction == .cyrillicToLatin
            ? "Мәтінді еңгізіңіз..."
            : "Mätindi eñgiziñiz..."
    }
    
    // MARK: - Output Card
    
    private var outputCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Label("Result", systemImage: "text.badge.checkmark")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if viewModel.hasInput {
                    Text(viewModel.selectedMappingID)
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.fill.tertiary, in: Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Output text
            Group {
                if viewModel.hasInput {
                    Text(viewModel.outputText)
                        .textSelection(.enabled)
                        .font(.body)
                } else {
                    Text(outputExample)
                        .foregroundStyle(.quaternary)
                        .font(.body)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
            .padding(.horizontal, 16)
            
            // Action bar
            if viewModel.hasInput {
                HStack(spacing: 16) {
                    Spacer()
                    
                    actionButton(icon: "doc.on.doc", label: "Copy") {
                        viewModel.copyOutput()
                    }
                    
                    ShareLink(item: viewModel.outputText) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.caption)
                            Text("Share")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
            }
            
            Spacer().frame(height: 12)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }
    
    private var outputExample: String {
        viewModel.direction == .cyrillicToLatin
            ? "Сәлем → Sälem"
            : "Sälem → Сәлем"
    }
    
    // MARK: - Mapping Info
    
    private var mappingInfo: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle")
                .font(.caption2)
            
            Picker("Alphabet", selection: $viewModel.selectedMappingID) {
                ForEach(ConversionEngine.shared.availableMappings, id: \.id) { mapping in
                    Text(mapping.displayName + (mapping.isRecommended ? " ✓" : ""))
                        .tag(mapping.id)
                }
            }
            .pickerStyle(.menu)
            .font(.caption)
            
            Spacer()
        }
        .foregroundStyle(.tertiary)
        .padding(.horizontal, 4)
    }
    
    // MARK: - Reusable Action Button
    
    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Toast
    
    private var toastBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.white)
            Text("Copied to clipboard")
                .foregroundStyle(.white)
        }
        .font(.subheadline.weight(.medium))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.green.gradient, in: Capsule())
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
        .padding(.top, 8)
    }
}

// MARK: - Preview

#Preview {
    ConvertView()
        .modelContainer(for: ConversionRecord.self, inMemory: true)
}
