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
        .tint(Color.accentTeal)
        .environment(ThemeManager.shared)
    }
}

enum AppTab: String, CaseIterable {
    case convert, camera, history
    
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

#Preview {
    ContentView()
        .modelContainer(for: ConversionRecord.self, inMemory: true)
}
