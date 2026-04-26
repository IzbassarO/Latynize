//
//  HistoryView.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation
import SwiftUI
import SwiftData

struct HistoryView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    
    @Query(sort: \ConversionRecord.createdAt, order: .reverse)
    private var allRecords: [ConversionRecord]
    
    @State private var viewModel = HistoryViewModel()
    @State private var selectedRecord: ConversionRecord?
    
    @State private var exportedFile: ExportedFile?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                if filteredRecords.isEmpty {
                    emptyState
                } else {
                    recordsList
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: Text("Search conversions..."))
            .toolbar {
                if viewModel.isSelecting {
                    selectionToolbar
                } else {
                    standardToolbar
                }
            }
            .sheet(item: $selectedRecord) { record in
                NavigationStack {
                    DetailView(record: record)
                }
                .environment(theme)
                .preferredColorScheme(theme.currentTheme.colorScheme)
            }
            .sheet(isPresented: $viewModel.isExportSheetPresented) {
                ExportOptionsSheet(
                    contextTitle: viewModel.contextTitle(for: allRecords),
                    itemCount: viewModel.resolvedRecords(from: allRecords).count
                ) { format in
                    viewModel.performExport(format: format, allRecords: allRecords)
                    // Wait for export sheet dismissal, then show share
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let url = viewModel.exportedFileURL {
                            exportedFile = ExportedFile(url: url)
                        }
                    }
                }
                .environment(theme)
                .preferredColorScheme(theme.currentTheme.colorScheme)
            }
            .sheet(item: $exportedFile) { file in
                ShareSheet(items: [file.url])
            }
        }
    }
    
    // MARK: - Helpers
    
    private var favoritesCount: Int {
        allRecords.filter { $0.isFavorite }.count
    }
    
    // MARK: - Toolbars
    
    @ToolbarContentBuilder
    private var standardToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            filterPicker
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    viewModel.prepareExport(scope: .all)
                } label: {
                    Label("Export All", systemImage: "tray.and.arrow.up")
                }
                .disabled(allRecords.isEmpty)
                
                Button {
                    viewModel.prepareExport(scope: .favorites)
                } label: {
                    Label("Export Favorites", systemImage: "star")
                }
                .disabled(favoritesCount == 0)
                
                Divider()
                
                Button {
                    viewModel.toggleSelectionMode()
                } label: {
                    Label("Select to Export", systemImage: "checkmark.circle")
                }
                .disabled(allRecords.isEmpty)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(Color.accentTeal)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var selectionToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") {
                viewModel.toggleSelectionMode()
            }
        }
        ToolbarItem(placement: .principal) {
            Text("\(viewModel.selectedIDs.count) selected")
                .font(.system(size: 15, weight: .medium))
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    viewModel.selectAll(filteredRecords)
                } label: {
                    Label("Select All", systemImage: "checkmark.circle.fill")
                }
                Button {
                    viewModel.deselectAll()
                } label: {
                    Label("Deselect All", systemImage: "circle")
                }
                Divider()
                Button {
                    viewModel.prepareExport(scope: .selected)
                } label: {
                    Label("Export Selected", systemImage: "tray.and.arrow.up")
                }
                .disabled(viewModel.selectedIDs.isEmpty)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(Color.accentTeal)
            }
        }
    }
    
    // MARK: - Computed
    
    private var filteredRecords: [ConversionRecord] {
        viewModel.filteredRecords(from: allRecords)
    }
    
    // MARK: - Filter Picker
    
    private var filterPicker: some View {
        Menu {
            ForEach(HistoryViewModel.Filter.allCases, id: \.self) { filter in
                Button {
                    viewModel.selectedFilter = filter
                } label: {
                    HStack {
                        Text(filter.label)
                        if viewModel.selectedFilter == filter {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: viewModel.selectedFilter.icon)
                    .font(.system(size: 14))
                Text(viewModel.selectedFilter.label)
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(Color.accentTeal)
        }
    }
    
    // MARK: - Records List
    
    private var recordsList: some View {
        List {
            ForEach(filteredRecords) { record in
                recordRow(record)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            viewModel.toggleFavorite(record, context: modelContext)
                        } label: {
                            Label(
                                record.isFavorite ? "Unfavorite" : "Favorite",
                                systemImage: record.isFavorite ? "star.slash" : "star.fill"
                            )
                        }
                        .tint(.orange)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            viewModel.deleteRecord(record, context: modelContext)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .animation(.smooth(duration: 0.25), value: viewModel.selectedFilter)
        .animation(.smooth(duration: 0.25), value: viewModel.searchText)
        .animation(.smooth(duration: 0.25), value: viewModel.isSelecting)
    }
    
    // MARK: - Record Row
    
    private func recordRow(_ record: ConversionRecord) -> some View {
        Button {
            if viewModel.isSelecting {
                viewModel.toggleSelection(record)
            } else {
                selectedRecord = record
            }
        } label: {
            HStack(spacing: 12) {
                if viewModel.isSelecting {
                    Image(systemName: viewModel.selectedIDs.contains(record.id) ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundStyle(viewModel.selectedIDs.contains(record.id) ? Color.accentTeal : Color(uiColor: .tertiaryLabel))
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Button {
                        viewModel.toggleFavorite(record, context: modelContext)
                    } label: {
                        Image(systemName: record.isFavorite ? "star.fill" : "star")
                            .font(.system(size: 16))
                            .foregroundStyle(record.isFavorite ? Color.orange : Color(uiColor: .tertiaryLabel))
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.inputPreview)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Text(record.outputPreview)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.accentTeal)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: record.source.icon)
                            .font(.system(size: 9))
                        Text(record.createdAt.relativeDisplay)
                        Text("·")
                        Text(record.alphabetVersion)
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                if !viewModel.isSelecting {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.selectedFilter == .favorites ? "star" : "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(.quaternary)
            
            Text(viewModel.selectedFilter == .favorites ? "No favorites yet" : "No conversions yet")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text(viewModel.selectedFilter == .favorites
                 ? "Tap the star on any conversion to save it here."
                 : "Convert some text and it will\nautomatically appear here.")
                .font(.system(size: 14))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Share Sheet wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    HistoryView()
        .modelContainer(for: ConversionRecord.self, inMemory: true)
        .environment(ThemeManager.shared)
}
