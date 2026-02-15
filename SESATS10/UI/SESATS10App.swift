//
//  SESATS10App.swift
//  SESATS10
//
//  Created by Edward Bender on 12/17/25.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct SESATS10App: App {
    @StateObject private var entitlements = EntitlementManager()
    
    init() {
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(entitlements)
                .task { entitlements.start() }
        }
        .modelContainer(for: [Question.self, AIUpdate.self])
    }
}
