//
//  WhatsNewSheet.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 26.04.2026.
//

import Foundation
import SwiftUI

struct WhatsNewSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var theme
    
    private let features: [Feature] = [
        Feature(
            icon: "moon.stars.fill",
            iconColor: .indigo,
            title: "Dark Mode",
            description: "Latynize now follows your system theme — or pick your favorite."
        ),
        Feature(
            icon: "globe",
            iconColor: .blue,
            title: "Russian and Kazakh",
            description: "Use the app in your language. Switch anytime in Settings."
        ),
        Feature(
            icon: "star.fill",
            iconColor: .orange,
            title: "Favorites",
            description: "Save your most-used conversions for quick access."
        ),
        Feature(
            icon: "doc.richtext",
            iconColor: Color.accentTeal,
            title: "Export to PDF",
            description: "Share your conversions as professional documents."
        ),
        Feature(
            icon: "sparkles",
            iconColor: .yellow,
            title: "Letter of the Day",
            description: "Learn one Kazakh Latin letter every day with examples."
        ),
        Feature(
            icon: "rectangle.3.group.fill",
            iconColor: .pink,
            title: "Home Screen Widget",
            description: "See today's letter right on your home screen."
        ),
        Feature(
            icon: "square.and.arrow.up.fill",
            iconColor: .green,
            title: "Share Extension",
            description: "Convert text from any app — Safari, Mail, Messages, and more."
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("What's New in")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Latynize 2.0")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(Color.accentTeal)
            }
            .padding(.top, 32)
            .padding(.bottom, 24)
            
            // Features list
            ScrollView {
                VStack(spacing: 22) {
                    ForEach(features) { feature in
                        featureRow(feature)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            
            // Continue button
            VStack(spacing: 12) {
                Button {
                    WhatsNewService.shared.markAsSeen()
                    HapticService.success()
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.accentTeal)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .background(
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                    .shadow(color: .black.opacity(0.05), radius: 8, y: -4)
            )
        }
        .background(Color(uiColor: .systemBackground))
        .interactiveDismissDisabled()
    }
    
    // MARK: - Feature Row
    
    private func featureRow(_ feature: Feature) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: feature.icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(feature.iconColor)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text(feature.description)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
    }
}

private struct Feature: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: LocalizedStringKey
    let description: LocalizedStringKey
}
