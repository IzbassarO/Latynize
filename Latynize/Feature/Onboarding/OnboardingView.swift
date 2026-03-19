//
//  OnboardingView.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompleted = false
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "character.textbox",
            iconColor: .blue,
            title: "Latynize",
            subtitle: "Kazakh Script Converter",
            description: "Қазақ жазуын кириллицадан латынға және керісінше түрлендіріңіз.\n\nConvert Kazakh text between Cyrillic and Latin scripts instantly."
        ),
        OnboardingPage(
            icon: "camera.viewfinder",
            iconColor: .orange,
            title: "Scan & Convert",
            subtitle: "Camera OCR",
            description: "Point your camera at any Kazakh text — signs, books, documents — and get instant Latin conversion.\n\nPowered by on-device AI. No internet needed."
        ),
        OnboardingPage(
            icon: "clock.arrow.circlepath",
            iconColor: .green,
            title: "Your History",
            subtitle: "Never lose a conversion",
            description: "Every conversion is saved automatically. Search, copy, and share anytime.\n\nAll data stays on your device. Private by design."
        ),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)
            
            // Bottom section
            VStack(spacing: 20) {
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.primary : Color.primary.opacity(0.2))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.25), value: currentPage)
                    }
                }
                
                // Action button
                Button {
                    if currentPage < pages.count - 1 {
                        currentPage += 1
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.primary)
                        .foregroundStyle(Color(uiColor: .systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                // Skip (only on non-last pages)
                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                } else {
                    // Invisible spacer to keep layout stable
                    Text(" ")
                        .font(.subheadline)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Page View
    
    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(page.iconColor)
                .frame(height: 80)
            
            // Title
            VStack(spacing: 6) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .default))
                
                Text(page.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Description
            Text(page.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Actions
    
    private func completeOnboarding() {
        HapticService.medium()
        withAnimation(.easeInOut(duration: 0.3)) {
            hasCompleted = true
        }
    }
}

// MARK: - Page Model

private struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let description: String
}

#Preview {
    OnboardingView()
}
