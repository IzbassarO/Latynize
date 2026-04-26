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
            description: "Follows your system theme — or pick your own."
        ),
        Feature(
            icon: "globe",
            iconColor: .blue,
            title: "Russian and Kazakh",
            description: "Use the app in your language."
        ),
        Feature(
            icon: "star.fill",
            iconColor: .orange,
            title: "Favorites",
            description: "Save your most-used conversions."
        ),
        Feature(
            icon: "doc.richtext",
            iconColor: Color.accentTeal,
            title: "Export to PDF",
            description: "Share conversions as professional documents."
        ),
        Feature(
            icon: "sparkles",
            iconColor: .yellow,
            title: "Letter of the Day",
            description: "Learn one Kazakh letter every day."
        ),
        Feature(
            icon: "rectangle.3.group.fill",
            iconColor: .pink,
            title: "Home Screen Widget",
            description: "See today's letter on your home screen."
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 48)
                        .padding(.bottom, 36)
                    
                    featuresSection
                        .padding(.horizontal, 28)
                        .padding(.bottom, 24)
                }
            }
            
            footerSection
        }
        .background(Color(uiColor: .systemBackground))
        .interactiveDismissDisabled()
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 6) {
            Text("What's New")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Latynize")
                    .font(.system(size: 36, weight: .black))
                    .foregroundStyle(.primary)
            }
        }
    }
    
    // MARK: - Features list
    
    private var featuresSection: some View {
        VStack(spacing: 26) {
            ForEach(features) { feature in
                featureRow(feature)
            }
        }
    }
    
    private func featureRow(_ feature: Feature) -> some View {
        HStack(alignment: .center, spacing: 18) {
            // Icon with subtle background
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(feature.iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: feature.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(feature.iconColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(feature.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text(feature.description)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
    }
    
    // MARK: - Footer
    
    private var footerSection: some View {
        VStack(spacing: 0) {
            // Subtle top divider
            Rectangle()
                .fill(Color.secondary.opacity(0.1))
                .frame(height: 0.5)
            
            VStack(spacing: 0) {
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
            .padding(.horizontal, 28)
            .padding(.top, 16)
            .padding(.bottom, 20)
            .background(Color(uiColor: .systemBackground))
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
