//
//  SESATS10App.swift
//  SESATS10
//
//  Created by Edward Bender on 12/17/25.
//

import SwiftUI
import SwiftData
import TipKit
import ParseSwift

@main
struct SESATS10App: App {
    @StateObject private var entitlements = EntitlementManager()
    
    init() {
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])

        Self.configureParse()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(entitlements)
                .task { entitlements.start() }
        }
        .modelContainer(for: [Question.self, AIUpdate.self])
        #if os(macOS)
        .defaultSize(width: 1100, height: 900)
        .commands {
            // No document model — this is a single-window reference app.
            CommandGroup(replacing: .newItem) {}
        }
        #endif
    }
}

private extension SESATS10App {
    static func configureParse() {
        guard
            let secretsURL = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let secrets = NSDictionary(contentsOf: secretsURL) as? [String: String],
            let applicationId = secrets["PARSE_APP_ID"],
            let clientKey = secrets["PARSE_CLIENT_KEY"],
            let serverURLString = secrets["PARSE_SERVER_URL"],
            let serverURL = URL(string: serverURLString)
        else {
            print("Parse configuration unavailable. Skipping Parse initialization.")
            return
        }

        ParseSwift.initialize(
            applicationId: applicationId,
            clientKey: clientKey,
            serverURL: serverURL
        )
    }
}
