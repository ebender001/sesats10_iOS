//
//  SESATS10App.swift
//  SESATS10
//
//  Created by Edward Bender on 12/17/25.
//

import SwiftUI
import SwiftData
import Firebase
import FirebaseAppCheck
import RevenueCat
import TipKit

@main
struct SESATS10App: App {
    @StateObject private var paywallViewModel = PaywallViewModel()
    
    init() {
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
        let providerFactory = Sesats10AppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        FirebaseApp.configure()
        
        #if DEBUG
        Purchases.configure(withAPIKey: Constants.API_KEY_DEVELOPMENT)
        #else
        Purchases.configure(withAPIKey: Constants.API_KEY_PRODUCTION)
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(paywallViewModel)
                .task {
                    await paywallViewModel.refresh()
                }
        }
        .modelContainer(for: [Question.self, AIUpdate.self])
    }
}
