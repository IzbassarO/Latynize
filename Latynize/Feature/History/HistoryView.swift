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
    @Query(sort: \ConversionRecord.createdAt, order: .reverse)
    private var records: [ConversionRecord]
    
    @State private var searchText = ""
    @State private var showSettings = false
    @State private var showDeleteAlert = false
    
    private var filteredRecords: [ConversionRecord] {
        guard !searchText.isEmpty else { return records }
        let query = searchText.lowercased()
        return records.filter {
            $0.inputText.lowercased().contains(query) ||
            $0.outputText.lowercased().contains(query)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    emptyState
                } else {
                    recordList
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                
                if !records.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Clear All", role: .destructive) {
                            showDeleteAlert = true
                        }
                        .font(.caption)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .alert("Delete all history?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete All", role: .destructive) {
                    deleteAll()
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Record List
    
    private var recordList: some View {
        List {
            ForEach(filteredRecords) { record in
                NavigationLink {
                    ConversionDetailView(record: record)
                } label: {
                    ConversionCard(record: record)
                }
            }
            .onDelete(perform: deleteRecords)
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search conversions...")
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No conversions yet")
                .font(.headline)
            
            Text("Your conversion history will appear here.\nStart by converting text in the Convert tab.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func deleteRecords(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredRecords[index])
        }
        HapticService.light()
    }
    
    private func deleteAll() {
        for record in records {
            modelContext.delete(record)
        }
        HapticService.medium()
    }
}

// MARK: - Conversion Card

struct ConversionCard: View {
    
    let record: ConversionRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Source text
            Text(record.inputPreview)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            // Arrow + converted text
            HStack(spacing: 4) {
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text(record.outputPreview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            // Metadata
            HStack(spacing: 8) {
                Label(record.source.rawValue.capitalized, systemImage: record.source.icon)
                
                Text("·")
                
                Text(record.createdAt.relativeDisplay)
                
                Text("·")
                
                Text(record.alphabetVersion)
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Detail View

struct ConversionDetailView: View {
    
    let record: ConversionRecord
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Original
                section(title: "Original", text: record.inputText, icon: "text.alignleft")
                
                // Converted
                section(title: "Converted", text: record.outputText, icon: "character.textbox")
                
                // Metadata
                VStack(alignment: .leading, spacing: 8) {
                    Label("Info", systemImage: "info.circle")
                        .font(.subheadline.weight(.medium))
                    
                    metadataRow("Direction", value: record.direction.label)
                    metadataRow("Source", value: record.source.rawValue.capitalized)
                    metadataRow("Alphabet", value: record.alphabetVersion)
                    metadataRow("Date", value: record.createdAt.formatted(date: .long, time: .shortened))
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: record.outputText) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
    
    private func section(title: String, text: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            
            Text(text)
                .font(.body)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 10))
            
            Button {
                UIPasteboard.general.string = text
                HapticService.success()
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
                    .font(.caption)
            }
            .tint(.secondary)
        }
    }
    
    private func metadataRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
        .font(.subheadline)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: ConversionRecord.self, inMemory: true)
}
