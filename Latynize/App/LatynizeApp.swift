//
//  LatynizeApp.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 19.03.2026.
//

import SwiftUI
import SwiftData

@main
struct LatynizeApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ConversionRecord.self)
    }
}
