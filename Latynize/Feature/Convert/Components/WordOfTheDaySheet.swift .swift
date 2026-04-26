//
//  WordOfTheDaySheet.swift .swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 26.04.2026.
//

import Foundation
import SwiftUI

struct WordOfTheDaySheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var theme
    
    let onUseExample: (String) -> Void
    
    @State private var selectedLetter: LetterOfTheDay = LetterOfTheDay.forDate()
    
    private let lastSevenDays: [(date: Date, letter: LetterOfTheDay)] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return (date, LetterOfTheDay.forDate(date))
        }
    }()
    
    private var cyrillicChar: String {
        String(selectedLetter.cyrillic.prefix(1))
    }
    
    private var latinChar: String {
        String(selectedLetter.latin2021.prefix(1))
    }
    
    private var isToday: Bool {
        let today = LetterOfTheDay.forDate()
        return today.cyrillic == selectedLetter.cyrillic
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    heroCard
                    actionButton
                    standardsSection
                    historySection
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Letter of the Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Hero Card
    
    private var heroCard: some View {
        VStack(spacing: 14) {
            // Today badge
            if isToday {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Today")
                        .font(.system(size: 11, weight: .bold))
                        .textCase(.uppercase)
                }
                .foregroundStyle(Color.accentTeal)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.accentTeal.opacity(0.12), in: Capsule())
            }
            
            // Letter pair big
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(cyrillicChar)
                    .font(.system(size: 88, weight: .black, design: .serif))
                    .foregroundStyle(.primary)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(Color.accentTeal)
                
                Text(latinChar)
                    .font(.system(size: 88, weight: .black, design: .serif))
                    .foregroundStyle(Color.accentTeal)
            }
            .padding(.vertical, 12)
            
            // Example word
            VStack(spacing: 6) {
                Text("EXAMPLE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .kerning(1.5)
                
                Text(selectedLetter.exampleCyrillic)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.primary)
                
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.accentTeal)
                    Text(selectedLetter.exampleLatin)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.accentTeal)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.accentTeal.opacity(0.08),
                            Color.accentTeal.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentTeal.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Action Button
    
    private var actionButton: some View {
        Button {
            onUseExample(selectedLetter.exampleCyrillic)
            HapticService.success()
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 14, weight: .bold))
                Text("Try this example")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.accentTeal)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Standards Section
    
    private var standardsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Standards")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                standardRow(
                    title: "Standard 2021",
                    badge: "Recommended",
                    badgeColor: Color.accentTeal,
                    value: selectedLetter.latin2021
                )
                
                Divider().padding(.leading, 16)
                
                standardRow(
                    title: "Legacy 2018",
                    badge: nil,
                    badgeColor: .secondary,
                    value: selectedLetter.latin2018
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
        }
    }
    
    private func standardRow(title: LocalizedStringKey, badge: String?, badgeColor: Color, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                    
                    if let badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(badgeColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(badgeColor.opacity(0.12), in: Capsule())
                    }
                }
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 17, weight: .semibold, design: .serif))
                .foregroundStyle(badgeColor == Color.accentTeal ? Color.accentTeal : .primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    // MARK: - Last 7 Days
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Last 7 Days")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(lastSevenDays.enumerated()), id: \.offset) { _, item in
                        dayCard(date: item.date, letter: item.letter)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private func dayCard(date: Date, letter: LetterOfTheDay) -> some View {
        let isSelected = letter.cyrillic == selectedLetter.cyrillic
        let isCurrentToday = Calendar.current.isDateInToday(date)
        
        return Button {
            withAnimation(.smooth(duration: 0.25)) {
                selectedLetter = letter
            }
            HapticService.selection()
        } label: {
            VStack(spacing: 6) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(String(letter.cyrillic.prefix(1)))
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundStyle(isSelected ? .white : .primary)
                    
                    Text("→")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : Color.accentTeal)
                    
                    Text(String(letter.latin2021.prefix(1)))
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundStyle(isSelected ? .white : Color.accentTeal)
                }
                
                if isCurrentToday {
                    Circle()
                        .fill(isSelected ? .white : Color.accentTeal)
                        .frame(width: 4, height: 4)
                } else {
                    Spacer().frame(height: 4)
                }
            }
            .frame(width: 76, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected
                          ? Color.accentTeal
                          : Color(uiColor: .secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentTeal : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
