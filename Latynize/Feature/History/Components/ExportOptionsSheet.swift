//
//  ExportOptionsSheet.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 22.04.2026.
//

import Foundation
import SwiftUI

struct ExportOptionsSheet: View {
    
    // MARK: - Format
    
    enum Format: String, CaseIterable, Identifiable {
        case pdf, text
        var id: String { rawValue }
        
        var label: LocalizedStringKey {
            switch self {
            case .pdf:  return "PDF Document"
            case .text: return "Plain Text"
            }
        }
        
        var description: LocalizedStringKey {
            switch self {
            case .pdf:  return "Formatted, printable"
            case .text: return "Simple .txt file"
            }
        }
        
        var icon: String {
            switch self {
            case .pdf:  return "doc.richtext"
            case .text: return "doc.plaintext"
            }
        }
    }
    
    // MARK: - Scope (used only by ViewModels — not for UI picking)
    
    enum Scope: String {
        case all, favorites, selected, single
    }
    
    // MARK: - Config
    
    let contextTitle: LocalizedStringKey
    let itemCount: Int
    let onExport: (Format) -> Void
    
    @State private var selectedFormat: Format = .pdf
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                contextSection
                formatSection
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Export") {
                        onExport(selectedFormat)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(itemCount == 0)
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Context Section
    
    private var contextSection: some View {
        Section {
            HStack(spacing: 12) {
                Image(systemName: "tray.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.accentTeal)
                    .frame(width: 40, height: 40)
                    .background(Color.accentTeal.opacity(0.12), in: Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(contextTitle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                    Text(itemCountText)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
    
    private var itemCountText: LocalizedStringKey {
        if itemCount == 1 {
            return "1 conversion"
        }
        return "\(itemCount) conversions"
    }
    
    // MARK: - Format Section
    
    private var formatSection: some View {
        Section {
            ForEach(Format.allCases) { format in
                Button {
                    withAnimation(.smooth(duration: 0.2)) {
                        selectedFormat = format
                    }
                    HapticService.selection()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: format.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(selectedFormat == format ? Color.accentTeal : .secondary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(format.label)
                                .font(.system(size: 15))
                                .foregroundStyle(.primary)
                            Text(format.description)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedFormat == format {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.accentTeal)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Format")
        }
    }
}
