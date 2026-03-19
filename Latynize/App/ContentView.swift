//
//  ContentView.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab: AppTab = .convert
    
    var body: some View {
        if hasCompletedOnboarding {
            mainTabView
        } else {
            OnboardingView()
        }
    }
    
    // MARK: - Main Tab View
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            ConvertView()
                .tabItem {
                    Label(AppTab.convert.title, systemImage: AppTab.convert.icon)
                }
                .tag(AppTab.convert)
            
            CameraView()
                .tabItem {
                    Label(AppTab.camera.title, systemImage: AppTab.camera.icon)
                }
                .tag(AppTab.camera)
            
            HistoryView()
                .tabItem {
                    Label(AppTab.history.title, systemImage: AppTab.history.icon)
                }
                .tag(AppTab.history)
        }
        .tint(.primary)
    }
}

// MARK: - Tab Definition

enum AppTab: String, CaseIterable {
    case convert
    case camera
    case history
    
    var title: String {
        switch self {
        case .convert: return "Convert"
        case .camera:  return "Camera"
        case .history: return "History"
        }
    }
    
    var icon: String {
        switch self {
        case .convert: return "character.textbox"
        case .camera:  return "camera.viewfinder"
        case .history: return "clock.arrow.circlepath"
        }
    }
}

#Preview("Main App") {
    ContentView()
        .modelContainer(for: ConversionRecord.self, inMemory: true)
}

#Preview("Onboarding") {
    OnboardingView()
}
