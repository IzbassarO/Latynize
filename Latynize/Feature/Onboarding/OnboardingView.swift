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
            title: "Latynize",
            subtitle: "Kazakh Script Converter",
            body: "Convert Kazakh text between Cyrillic and Latin scripts — instantly, on your device."
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "Built for Learning",
            subtitle: "Daily letters, examples, widgets",
            body: "See a new Kazakh letter every day, save favorites, and learn the new alphabet step by step."
        ),
        OnboardingPage(
            icon: "camera.viewfinder",
            title: "Scan & Convert",
            subtitle: "Powered by on-device AI",
            body: "Point your camera at signs, books, or documents. Tap any text to get the Latin version."
        ),
        OnboardingPage(
            icon: "lock.shield",
            title: "100% Private",
            subtitle: "No servers. No tracking.",
            body: "Everything stays on your device. No internet needed. No data collection. Ever."
        ),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Skip button (top-right) — visible on all but last
            HStack {
                Spacer()
                if currentPage < pages.count - 1 {
                    Button("Skip") { completeOnboarding() }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 24)
                }
            }
            .frame(height: 44)
            .padding(.top, 8)
            
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageContent(page, index: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.35), value: currentPage)
            
            bottomSection
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    // MARK: - Page Content
    
    private func pageContent(_ page: OnboardingPage, index: Int) -> some View {
        VStack(spacing: 28) {
            Spacer()
            
            // Icon with subtle animation when page becomes active
            ZStack {
                Circle()
                    .fill(Color.accentTeal.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(Color.accentTeal)
                    .symbolRenderingMode(.hierarchical)
            }
            .scaleEffect(currentPage == index ? 1.0 : 0.85)
            .opacity(currentPage == index ? 1.0 : 0.6)
            .animation(.spring(duration: 0.5, bounce: 0.25), value: currentPage)
            
            // Text
            VStack(spacing: 10) {
                Text(page.title)
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.accentTeal)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            
            Text(page.body)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Bottom Section
    
    private var bottomSection: some View {
        VStack(spacing: 18) {
            // Indicators
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Capsule()
                        .fill(i == currentPage ? Color.accentTeal : Color.accentTeal.opacity(0.2))
                        .frame(width: i == currentPage ? 28 : 8, height: 8)
                        .animation(.spring(duration: 0.3), value: currentPage)
                }
            }
            
            // Continue / Get Started button
            Button {
                if currentPage < pages.count - 1 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage += 1
                    }
                    HapticService.light()
                } else {
                    completeOnboarding()
                }
            } label: {
                Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .foregroundStyle(.white)
                    .background(Color.accentTeal, in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 36)
    }
    
    private func completeOnboarding() {
        HapticService.medium()
        withAnimation(.easeInOut(duration: 0.3)) {
            WhatsNewService.shared.markFirstLaunchComplete()
            hasCompleted = true
        }
    }
}

private struct OnboardingPage {
    let icon: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let body: LocalizedStringKey
}

#Preview {
    OnboardingView()
}
