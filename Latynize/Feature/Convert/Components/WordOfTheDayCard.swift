//
//  WordOfTheDayCard.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 26.04.2026.
//

import SwiftUI

struct WordOfTheDayCard: View {
    let letter: LetterOfTheDay
    let onTap: () -> Void
    
    private var cyrillicChar: String {
        String(letter.cyrillic.prefix(1))
    }
    
    private var latinChar: String {
        String(letter.latin2021.prefix(1))
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Letter pair badge
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(cyrillicChar)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(.primary)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.accentTeal)
                    
                    Text(latinChar)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(Color.accentTeal)
                }
                .frame(width: 64, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentTeal.opacity(0.1))
                )
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.accentTeal)
                        Text("Letter of the Day")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                    }
                    
                    HStack(spacing: 6) {
                        Text(letter.exampleCyrillic)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.tertiary)
                        
                        Text(letter.exampleLatin)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.accentTeal)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
