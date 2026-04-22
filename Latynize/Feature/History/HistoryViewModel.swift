//
//  HistoryViewModel.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 21.04.2026.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
final class HistoryViewModel {
    
    // MARK: - Filter
    
    enum Filter: String, CaseIterable {
        case all, favorites
        
        var label: LocalizedStringKey {
            switch self {
            case .all:       return "All"
            case .favorites: return "Favorites"
            }
        }
        
        var icon: String {
            switch self {
            case .all:       return "list.bullet"
            case .favorites: return "star.fill"
            }
        }
    }
    
    // MARK: - State
    
    var selectedFilter: Filter = .all
    var searchText: String = ""
    
    var isSelecting: Bool = false
    var selectedIDs: Set<UUID> = []
    
    var isExportSheetPresented: Bool = false
    var exportedFileURL: URL?
    
    // Context for the currently active export flow
    var exportScope: ExportOptionsSheet.Scope = .all
    
    // MARK: - Favorites / Delete
    
    func toggleFavorite(_ record: ConversionRecord, context: ModelContext) {
        record.isFavorite.toggle()
        do {
            try context.save()
            HapticService.selection()
        } catch {
            record.isFavorite.toggle()
            print("Failed to toggle favorite: \(error)")
        }
    }
    
    func deleteRecord(_ record: ConversionRecord, context: ModelContext) {
        context.delete(record)
        do {
            try context.save()
            HapticService.medium()
        } catch {
            print("Failed to delete: \(error)")
        }
    }
    
    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        HapticService.success()
    }
    
    // MARK: - Filtering
    
    func filteredRecords(from records: [ConversionRecord]) -> [ConversionRecord] {
        var result = records
        
        if selectedFilter == .favorites {
            result = result.filter { $0.isFavorite }
        }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.inputText.lowercased().contains(query) ||
                $0.outputText.lowercased().contains(query)
            }
        }
        
        // Favorites first, then newest
        result.sort { lhs, rhs in
            if lhs.isFavorite != rhs.isFavorite {
                return lhs.isFavorite && !rhs.isFavorite
            }
            return lhs.createdAt > rhs.createdAt
        }
        
        return result
    }
    
    // MARK: - Selection Mode
    
    func toggleSelectionMode() {
        withAnimation(.smooth(duration: 0.25)) {
            isSelecting.toggle()
            if !isSelecting {
                selectedIDs.removeAll()
            }
        }
    }
    
    func toggleSelection(_ record: ConversionRecord) {
        if selectedIDs.contains(record.id) {
            selectedIDs.remove(record.id)
        } else {
            selectedIDs.insert(record.id)
        }
        HapticService.selection()
    }
    
    func selectAll(_ records: [ConversionRecord]) {
        selectedIDs = Set(records.map { $0.id })
        HapticService.selection()
    }
    
    func deselectAll() {
        selectedIDs.removeAll()
        HapticService.selection()
    }
    
    // MARK: - Export Prep
    
    /// Opens export sheet for a specific scope (triggered from toolbar menu)
    func prepareExport(scope: ExportOptionsSheet.Scope) {
        self.exportScope = scope
        self.isExportSheetPresented = true
    }
    
    /// Returns records matching the current exportScope
    func resolvedRecords(from allRecords: [ConversionRecord]) -> [ConversionRecord] {
        switch exportScope {
        case .all:
            return allRecords
        case .favorites:
            return allRecords.filter { $0.isFavorite }
        case .selected:
            return allRecords.filter { selectedIDs.contains($0.id) }
        case .single:
            return []  // not used in HistoryView
        }
    }
    
    /// Human-readable context title for the current scope
    func contextTitle(for records: [ConversionRecord]) -> LocalizedStringKey {
        switch exportScope {
        case .all:       return "All Conversions"
        case .favorites: return "Favorites"
        case .selected:  return "Selected Conversions"
        case .single:    return "This Conversion"
        }
    }
    
    // MARK: - Execute Export
    
    func performExport(format: ExportOptionsSheet.Format, allRecords: [ConversionRecord]) {
        let records = resolvedRecords(from: allRecords)
        
        guard !records.isEmpty else { return }
        
        let title: String
        switch exportScope {
        case .all:       title = "All Conversions"
        case .favorites: title = "Favorites"
        case .selected:  title = "Selected Conversions"
        case .single:    title = "Conversion"
        }
        
        let url: URL?
        switch format {
        case .pdf:
            url = PDFExportService.shared.exportBulk(records, title: title)
        case .text:
            url = TextExportService.shared.exportBulk(records, title: title)
        }
        
        if let url = url {
            exportedFileURL = url
            HapticService.success()
        }
        
        // Exit selection mode after export
        if isSelecting {
            toggleSelectionMode()
        }
    }
}
