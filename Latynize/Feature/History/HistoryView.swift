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
        let q = searchText.lowercased()
        return records.filter {
            $0.inputText.lowercased().contains(q) || $0.outputText.lowercased().contains(q)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                if !records.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Clear", role: .destructive) { showDeleteAlert = true }
                            .font(.system(size: 15))
                    }
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .alert("Clear all history?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete All", role: .destructive) { deleteAll() }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    // MARK: - List
    
    private var list: some View {
        List {
            ForEach(filteredRecords) { record in
                NavigationLink {
                    DetailView(record: record)
                } label: {
                    RecordRow(record: record)
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            }
            .onDelete(perform: delete)
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search conversions...")
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.accentTeal.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: "clock")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(Color.accentTeal.opacity(0.6))
            }
            
            VStack(spacing: 6) {
                Text("No conversions yet")
                    .font(.system(size: 18, weight: .semibold))
                Text("Convert some text and it will\nautomatically appear here.")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Actions
    
    private func delete(at offsets: IndexSet) {
        for i in offsets { modelContext.delete(filteredRecords[i]) }
        HapticService.light()
    }
    
    private func deleteAll() {
        for r in records { modelContext.delete(r) }
        HapticService.medium()
    }
}

// MARK: - Record Row

struct RecordRow: View {
    let record: ConversionRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(record.inputPreview)
                .font(.system(size: 15, weight: .medium))
                .lineLimit(1)
            
            HStack(spacing: 5) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.accentTeal)
                Text(record.outputPreview)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            HStack(spacing: 6) {
                Image(systemName: record.source.icon)
                Text(record.source.rawValue.capitalized)
                Text("·")
                Text(record.createdAt.relativeDisplay)
                Text("·")
                Text(record.alphabetVersion)
            }
            .font(.system(size: 11))
            .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Detail View

struct DetailView: View {
    let record: ConversionRecord
    
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
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: record.outputText) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
    
    private func textBlock(label: String, text: String, icon: String) -> some View {
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
    
    private func infoRow(_ label: String, _ value: String) -> some View {
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
}

#Preview {
    HistoryView()
        .modelContainer(for: ConversionRecord.self, inMemory: true)
}
