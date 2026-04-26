//
//  DetailView.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 22.04.2026.
//

import Foundation
import SwiftUI

struct DetailView: View {
    
    let record: ConversionRecord
    
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var theme
    
    @State private var isExportSheetPresented = false
    @State private var exportedFile: ExportedFile?
    
    @State private var exportedURL: URL?
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                textBlock(label: "Original", text: record.inputText, icon: "text.alignleft")
                textBlock(label: "Converted", text: record.outputText, icon: "text.badge.checkmark")
                infoSection
            }
            .padding(16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Done") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        isExportSheetPresented = true
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.down")
                    }
                    ShareLink(item: record.outputText) {
                        Label("Share Text", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isExportSheetPresented) {
            ExportOptionsSheet(
                contextTitle: "This Conversion",
                itemCount: 1
            ) { format in
                performExport(format: format)
            }
            .environment(theme)
            .preferredColorScheme(theme.currentTheme.colorScheme)
        }
        .sheet(item: $exportedFile) { file in
            ShareSheet(items: [file.url])
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    // MARK: - Content blocks
    
    private func textBlock(label: LocalizedStringKey, text: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.accentTeal)
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Text(text)
                .font(.system(size: 16))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
            
            Button {
                UIPasteboard.general.string = text
                HapticService.success()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "doc.on.doc").font(.system(size: 11))
                    Text("Copy").font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(Color.accentTeal)
            }
        }
    }
    
    private var infoSection: some View {
        VStack(spacing: 0) {
            infoRow("Direction", record.direction.label)
            Divider().padding(.leading, 16)
            infoRow("Source", record.source.rawValue.capitalized)
            Divider().padding(.leading, 16)
            infoRow("Standard", record.alphabetVersion == "2021" ? "Standard 2021" : "Legacy 2018")
            Divider().padding(.leading, 16)
            infoRow("Date", record.createdAt.formatted(date: .long, time: .shortened))
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
    
    private func infoRow(_ label: LocalizedStringKey, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
            Spacer()
            Text(value)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Export
    
    private func performExport(format: ExportOptionsSheet.Format) {
        let url: URL?
        switch format {
        case .pdf:
            url = PDFExportService.shared.exportSingle(record)
        case .text:
            url = TextExportService.shared.exportSingle(record)
        }
        
        if let url = url {
            // Delay to let export sheet dismiss first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exportedFile = ExportedFile(url: url)
                HapticService.success()
            }
        }
    }
}
