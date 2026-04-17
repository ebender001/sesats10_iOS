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
    private let cachedAccessKey = "hasAIAccess"

    @Published private(set) var hasAIAccess: Bool
    
    private let lifetimeID = "com.cvoffice.sesats10.lifetime"
    private let subscriptionIds: Set<String> = [
        "com.cvoffice.sesats10.month",
        "com.cvoffice.sesats10.annual"
    ]

    private var hasStarted = false
    private var updatesTask: Task<Void, Never>?

    init() {
        hasAIAccess = UserDefaults.standard.bool(forKey: cachedAccessKey)
    }
    
    func start() {
        guard !hasStarted else { return }
        hasStarted = true

        Task {
            await refresh()
        }

        updatesTask = Task {
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
        UserDefaults.standard.set(unlocked, forKey: cachedAccessKey)
    }
    
    private func listenForUpdates() async {
        for await result in Transaction.updates {
            guard case .verified(_) = result else { continue }
            await refresh()
        }
    }

    deinit {
        updatesTask?.cancel()
    }
}
