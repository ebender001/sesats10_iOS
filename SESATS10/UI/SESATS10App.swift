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

@main
struct SESATS10App: App {
    
    init() {
        let providerFactory = Sesats10AppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        FirebaseApp.configure()
        Purchases.configure(withAPIKey: "test_PTzKqKBVdiWLXzpaYBdsDlxNnuz")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                
        }
        .modelContainer(for: Question.self)
    }
}
