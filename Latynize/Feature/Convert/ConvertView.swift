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
    @Environment(ThemeManager.self) private var theme
    @State private var viewModel = ConvertViewModel()
    @State private var showSettings = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Smart clipboard suggestion
                        if viewModel.showClipboardSuggestion {
                            clipboardBanner
                        }
                        
                        directionSwitcher
                        inputCard
                        outputCard
                        
                        // Example phrases (shown when no input)
                        if !viewModel.hasInput {
                            examplesSection
                        }
                        
                        standardSelector
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 120)
                    .contentShape(Rectangle())
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Latynize")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button { viewModel.showAlphabetReference = true } label: {
                            Image(systemName: "character.book.closed")
                                .symbolRenderingMode(.hierarchical)
                        }
                        Button { showSettings = true } label: {
                            Image(systemName: "gearshape")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                }
            }
            .onTapGesture { isInputFocused = false }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environment(theme)
                    .preferredColorScheme(theme.currentTheme.colorScheme)
            }
            .sheet(isPresented: $viewModel.showAlphabetReference) { AlphabetReferenceView() }
            .overlay(alignment: .top) {
                if viewModel.showCopiedToast {
                    toastView.transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(duration: 0.35), value: viewModel.showCopiedToast)
            .animation(.easeInOut(duration: 0.25), value: viewModel.showClipboardSuggestion)
            .onReceive(NotificationCenter.default.publisher(for: .openLetterFromWidget)) { notification in
                if let letter = notification.userInfo?["letter"] as? String {
                    viewModel.inputText = letter
                    viewModel.direction = .cyrillicToLatin
                    // Trigger conversion
                    viewModel.onInputChanged()
                }
            }
        }
    }
    
    // MARK: - Clipboard Banner
    
    private var clipboardBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.on.clipboard.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.accentTeal)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Text detected in clipboard")
                    .font(.system(size: 13, weight: .semibold))
                Text(viewModel.clipboardText.prefix(40) + (viewModel.clipboardText.count > 40 ? "..." : ""))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button {
                viewModel.applyClipboardSuggestion()
            } label: {
                Text("Convert")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.accentTeal, in: Capsule())
            }
            
            Button {
                viewModel.dismissClipboardSuggestion()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.accentTeal.opacity(0.08))
                .stroke(Color.accentTeal.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Direction Switcher
    
    private var directionSwitcher: some View {
        HStack(spacing: 0) {
            VStack(spacing: 3) {
                Text(viewModel.direction == .cyrillicToLatin ? "Кириллица" : "Латын")
                    .font(.system(size: 16, weight: .semibold))
                Text(viewModel.direction == .cyrillicToLatin ? "Cyrillic" : "Latin")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            Button {
                withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                    viewModel.toggleDirection()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.accentTeal)
                        .frame(width: 44, height: 44)
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(viewModel.direction == .cyrillicToLatin ? 0 : 180))
                }
            }
            
            VStack(spacing: 3) {
                Text(viewModel.direction == .cyrillicToLatin ? "Латын" : "Кириллица")
                    .font(.system(size: 16, weight: .semibold))
                Text(viewModel.direction == .cyrillicToLatin ? "Latin" : "Cyrillic")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
    
    // MARK: - Input Card
    
    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "pencil.line")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.accentTeal)
                Text("Original")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                if viewModel.hasInput {
                    Text("\(viewModel.wordCount) words · \(viewModel.characterCount) chars")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            
            ZStack(alignment: .topLeading) {
                if !viewModel.hasInput {
                    Text(viewModel.direction == .cyrillicToLatin
                         ? "Мәтінді жазыңыз..."
                         : "Mätindi jaziñiz...")
                        .font(.system(size: 16))
                        .foregroundStyle(.quaternary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: $viewModel.inputText)
                    .focused($isInputFocused)
                    .font(.system(size: 16))
                    .frame(minHeight: 80, maxHeight: 180)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 8)
                    .onChange(of: viewModel.inputText) {
                        viewModel.onInputChanged()
                        viewModel.scheduleAutoSave(context: modelContext)
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button {
                                hideKeyboard()
                            } label: {
                                Image(systemName: "keyboard.chevron.compact.down")
                                    .foregroundStyle(Color.accentTeal)
                            }
                        }
                    }
            }
            
            HStack(spacing: 20) {
                Spacer()
                
                if viewModel.hasInput {
                    Button {
                        viewModel.clearInput()
                        isInputFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.tertiary)
                    }
                }
                
                Button { viewModel.pasteFromClipboard() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.clipboard").font(.system(size: 12))
                        Text("Paste").font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(Color.accentTeal)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
    
    // MARK: - Output Card
    
    private var outputCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "text.badge.checkmark")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.accentTeal)
                Text("Converted")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                if viewModel.hasInput {
                    Text(viewModel.selectedMappingID == "2021" ? "Standard · 2021" : "Legacy · 2018")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.accentTeal.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.accentTeal.opacity(0.1), in: Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            
            Group {
                if viewModel.hasInput {
                    Text(viewModel.outputText)
                        .font(.system(size: 16))
                        .textSelection(.enabled)
                } else {
                    Text("Converted text will appear here")
                        .font(.system(size: 15))
                        .foregroundStyle(.quaternary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
            .padding(.horizontal, 16)
            
            if viewModel.hasInput {
                HStack(spacing: 10) {
                    Spacer()
                    
                    Button {
                        viewModel.toggleCurrentFavorite(context: modelContext)
                    } label: {
                        Image(systemName: viewModel.isCurrentFavorited ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundStyle(viewModel.isCurrentFavorited ? .red : .secondary)
                            .frame(width: 36, height: 36)
                            .background(Color(uiColor: .tertiarySystemFill), in: Circle())
                    }
                    
                    Button { viewModel.copyOutput() } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "doc.on.doc").font(.system(size: 12))
                            Text("Copy").font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Color.accentTeal, in: Capsule())
                    }
                    
                    ShareLink(item: viewModel.outputText) {
                        HStack(spacing: 5) {
                            Image(systemName: "square.and.arrow.up").font(.system(size: 12))
                            Text("Share").font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Color(uiColor: .tertiarySystemFill), in: Capsule())
                    }
                }
                .padding(.horizontal, 16)
            }
            
            Spacer().frame(height: 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
    
    // MARK: - Examples Section
    
    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb")
                    .font(.system(size: 12))
                    .foregroundStyle(.orange)
                Text("Try an example")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.examplePhrases, id: \.cyrillic) { phrase in
                        Button {
                            viewModel.applyExample(phrase.cyrillic)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(phrase.cyrillic)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(phrase.latin)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.accentTeal)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Standard Selector
    
    private var standardSelector: some View {
        Picker("Standard", selection: $viewModel.selectedMappingID) {
            ForEach(ConversionEngine.shared.availableMappings, id: \.id) { mapping in
                Text(mapping.id == "2021" ? "Standard 2021 (ä, ö, ü, ş) ✓" : "Legacy 2018 (á, ó, ú)")
                    .tag(mapping.id)
            }
        }
        .pickerStyle(.menu)
        .font(.system(size: 13))
        .tint(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
    
    // MARK: - Toast
    
    private var toastView: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
            Text("Copied to clipboard")
        }
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.accentTeal)
                .shadow(color: Color.accentTeal.opacity(0.3), radius: 16, y: 8)
        )
        .padding(.top, 8)
    }
}

// MARK: - Alphabet Reference Sheet

struct AlphabetReferenceView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private let mappings: [(cyrillic: String, latin2021: String, latin2018: String)] = [
        ("А а", "A a", "A a"),
        ("Ә ә", "Ä ä", "Á á"),
        ("Б б", "B b", "B b"),
        ("В в", "V v", "V v"),
        ("Г г", "G g", "G g"),
        ("Ғ ғ", "Ğ ğ", "Ǵ ǵ"),
        ("Д д", "D d", "D d"),
        ("Е е", "E e", "E e"),
        ("Ж ж", "J j", "J j"),
        ("З з", "Z z", "Z z"),
        ("И и", "İ i", "I i"),
        ("К к", "K k", "K k"),
        ("Қ қ", "Q q", "Q q"),
        ("Л л", "L l", "L l"),
        ("М м", "M m", "M m"),
        ("Н н", "N n", "N n"),
        ("Ң ң", "Ñ ñ", "Ń ń"),
        ("О о", "O o", "O o"),
        ("Ө ө", "Ö ö", "Ó ó"),
        ("П п", "P p", "P p"),
        ("Р р", "R r", "R r"),
        ("С с", "S s", "S s"),
        ("Т т", "T t", "T t"),
        ("У у", "U u", "U u"),
        ("Ұ ұ", "Ū ū", "Ú ú"),
        ("Ү ү", "Ü ü", "Ý ý"),
        ("Ф ф", "F f", "F f"),
        ("Х х", "H h", "H h"),
        ("Ш ш", "Ş ş", "Sh sh"),
        ("Ы ы", "I ı", "Y y"),
        ("І і", "İ i", "Í í"),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header row
                    HStack {
                        Text("Кириллица")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("2021")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(Color.accentTeal)
                        Text("2018")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundStyle(.secondary)
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(uiColor: .tertiarySystemFill))
                    
                    // Rows
                    ForEach(Array(mappings.enumerated()), id: \.offset) { index, row in
                        HStack {
                            Text(row.cyrillic)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(row.latin2021)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(Color.accentTeal)
                            Text(row.latin2018)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundStyle(.secondary)
                        }
                        .font(.system(size: 15, design: .monospaced))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            index % 2 == 0
                                ? Color.clear
                                : Color(uiColor: .tertiarySystemFill).opacity(0.5)
                        )
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Alphabet Reference")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ConvertView()
        .modelContainer(for: ConversionRecord.self, inMemory: true)
}
