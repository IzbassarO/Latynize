//
//  ExportOptionsSheet.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 22.04.2026.
//

import Foundation
import SwiftUI

struct ExportOptionsSheet: View {
    
    enum Scope: String, CaseIterable, Identifiable {
        case all, favorites, selected
        var id: String { rawValue }
        
        var label: LocalizedStringKey {
            switch self {
            case .all:       return "All conversions"
            case .favorites: return "Favorites only"
            case .selected:  return "Selected items"
            }
        }
        
        var icon: String {
            switch self {
            case .all:       return "list.bullet"
            case .favorites: return "star.fill"
            case .selected:  return "checkmark.circle"
            }
        }
    }
    
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
    
    // MARK: - Config
    
    let availableScopes: [Scope]
    let totalCount: Int
    let favoritesCount: Int
    let selectedCount: Int
    
    @State private var selectedScope: Scope
    @State private var selectedFormat: Format = .pdf
    
    let onExport: (Scope, Format) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    init(
        availableScopes: [Scope],
        totalCount: Int,
        favoritesCount: Int = 0,
        selectedCount: Int = 0,
        defaultScope: Scope = .all,
        onExport: @escaping (Scope, Format) -> Void
    ) {
        self.availableScopes = availableScopes
        self.totalCount = totalCount
        self.favoritesCount = favoritesCount
        self.selectedCount = selectedCount
        self._selectedScope = State(initialValue: defaultScope)
        self.onExport = onExport
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                if availableScopes.count > 1 {
                    scopeSection
                }
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
                        onExport(selectedScope, selectedFormat)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(countForScope(selectedScope) == 0)
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Scope Section
    
    private var scopeSection: some View {
        Section {
            ForEach(availableScopes) { scope in
                Button {
                    withAnimation(.smooth(duration: 0.2)) {
                        selectedScope = scope
                    }
                    HapticService.selection()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: scope.icon)
                            .font(.system(size: 15))
                            .foregroundStyle(selectedScope == scope ? Color.accentTeal : .secondary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(scope.label)
                                .font(.system(size: 15))
                                .foregroundStyle(.primary)
                            Text(countText(for: scope))
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedScope == scope {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.accentTeal)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(countForScope(scope) == 0)
            }
        } header: {
            Text("What to export")
        }
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
    
    // MARK: - Helpers
    
    private func countForScope(_ scope: Scope) -> Int {
        switch scope {
        case .all:       return totalCount
        case .favorites: return favoritesCount
        case .selected:  return selectedCount
        }
    }
    
    private func countText(for scope: Scope) -> String {
        let count = countForScope(scope)
        return "\(count) " + (count == 1 ? "item" : "items")
    }
}
