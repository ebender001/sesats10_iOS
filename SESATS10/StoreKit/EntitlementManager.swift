//
//  EntitlementManager.swift
//  SESATS10
//
//  Created by Edward Bender on 1/27/26.
//

import Foundation
import StoreKit
import SwiftUI
import Combine

@MainActor
final class EntitlementManager: ObservableObject {
    @AppStorage("hasAIAccess") private var cachedHasAIAccess = false
    
    @Published private(set) var hasAIAccess = false
    
    private let lifetimeID = "com.cvoffice.sesats10.lifetime"
    private let subscriptionIds: Set<String> = [
        "com.cvoffice.sesats10.month",
        "com.cvoffice.sesats10.annual"
    ]
    
    func start() {
        hasAIAccess = cachedHasAIAccess
        
        Task {
            await refresh()
        }
        
        Task {
            await listenForUpdates()
        }
    }
    
    func refresh() async {
        var unlocked = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if transaction.productID == lifetimeID || subscriptionIds.contains(transaction.productID) {
                unlocked = true
                break
            }
        }

        // Update once, after scanning entitlements (covers break + empty entitlements)
        hasAIAccess = unlocked
        cachedHasAIAccess = unlocked
    }
    
    private func listenForUpdates() async {
        for await result in Transaction.updates {
            guard case .verified(_) = result else { continue }
            await refresh()
        }
    }
}
