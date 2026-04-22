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
    
    // MARK: - State
    
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
    
    var selectedFilter: Filter = .all
    var searchText: String = ""
    
    var isSelecting: Bool = false
    var selectedIDs: Set<UUID> = []
    var exportedFileURL: URL?
    var isExportSheetPresented: Bool = false
    
    // MARK: - Actions
    
    func toggleFavorite(_ record: ConversionRecord, context: ModelContext) {
        record.isFavorite.toggle()
        
        do {
            try context.save()
            HapticService.selection()
        } catch {
            // Revert on failure
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
    
    // MARK: - Filtering Logic (pure functions, fast)
    
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
        
        // Sort: favorites first, then by date
        result.sort { lhs, rhs in
            if lhs.isFavorite != rhs.isFavorite {
                return lhs.isFavorite && !rhs.isFavorite
            }
            return lhs.createdAt > rhs.createdAt
        }
        
        return result
    }
    
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
    
    func performExport(
        scope: ExportOptionsSheet.Scope,
        format: ExportOptionsSheet.Format,
        allRecords: [ConversionRecord]
    ) {
        let records: [ConversionRecord]
        let title: String
        
        switch scope {
        case .all:
            records = allRecords
            title = "All Conversions"
        case .favorites:
            records = allRecords.filter { $0.isFavorite }
            title = "Favorites"
        case .selected:
            records = allRecords.filter { selectedIDs.contains($0.id) }
            title = "Selected"
        }
        
        guard !records.isEmpty else { return }
        
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
