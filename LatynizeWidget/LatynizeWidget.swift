//
//  LatynizeWidget.swift
//  LatynizeWidget
//
//  Created by Izbassar Orynbassar on 23.04.2026.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct LetterEntry: TimelineEntry {
    let date: Date
    let letter: LetterOfTheDay
}

// MARK: - Provider

struct LetterProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> LetterEntry {
        LetterEntry(date: .now, letter: LetterOfTheDay.allLetters[0])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LetterEntry) -> Void) {
        completion(LetterEntry(date: .now, letter: LetterOfTheDay.forDate()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LetterEntry>) -> Void) {
        var entries: [LetterEntry] = []
        let calendar = Calendar.current
        let now = Date.now
        
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: now)) {
                entries.append(LetterEntry(date: date, letter: LetterOfTheDay.forDate(date)))
            }
        }
        
        let nextUpdate = calendar.date(byAdding: .day, value: 7, to: now)!
        completion(Timeline(entries: entries, policy: .after(nextUpdate)))
    }
}

// MARK: - Main View

struct LatynizeWidgetEntryView: View {
    var entry: LetterProvider.Entry
    
    private var cyrillicChar: String {
        // Take only the uppercase character, e.g. "Ә ә" → "Ә"
        String(entry.letter.cyrillic.prefix(1))
    }
    
    private var latinChar: String {
        String(entry.letter.latin2021.prefix(1))
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.accentTeal.opacity(0.18),
                    Color.accentTeal.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 0) {
                // LEFT — Hero letter pair
                heroSection
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Divider
                Rectangle()
                    .fill(Color.accentTeal.opacity(0.2))
                    .frame(width: 1)
                    .padding(.vertical, 16)
                
                // RIGHT — Example
                exampleSection
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .containerBackground(for: .widget) {
            Color(uiColor: .systemBackground)
        }
        .widgetURL(URL(string: "latynize://letter/\(cyrillicChar)"))
    }
    
    // MARK: - Hero Section (left)
    
    private var heroSection: some View {
        VStack(alignment: .center, spacing: 4) {
            Text("LETTER OF THE DAY")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.accentTeal)
                .kerning(1.2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Spacer()
            
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(cyrillicChar)
                    .font(.system(size: 56, weight: .black, design: .serif))
                    .foregroundStyle(.primary)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(Color.accentTeal)
                    .padding(.bottom, 8)
                
                Text(latinChar)
                    .font(.system(size: 56, weight: .black, design: .serif))
                    .foregroundStyle(Color.accentTeal)
            }
            
            Spacer()
            
            // Standard label
            Text("Standard 2021")
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Color.secondary.opacity(0.12))
                )
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
    }
    
    // MARK: - Example Section (right)
    
    private var exampleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("EXAMPLE")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
                .kerning(1.2)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.letter.exampleCyrillic)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                HStack(spacing: 5) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.accentTeal)
                    
                    Text(entry.letter.exampleLatin)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.accentTeal)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            
            Spacer()
            
            // Brand
            HStack(spacing: 5) {
                Image(systemName: "character.book.closed.fill")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color.accentTeal)
                Text("Latynize")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Widget Configuration

struct LatynizeWidget: Widget {
    let kind: String = "LatynizeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LetterProvider()) { entry in
            LatynizeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Letter of the Day")
        .description("Learn one Kazakh Latin letter every day with examples.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    LatynizeWidget()
} timeline: {
    LetterEntry(date: .now, letter: LetterOfTheDay.allLetters[0])
    LetterEntry(date: .now, letter: LetterOfTheDay.allLetters[5])
    LetterEntry(date: .now, letter: LetterOfTheDay.allLetters[10])
}
