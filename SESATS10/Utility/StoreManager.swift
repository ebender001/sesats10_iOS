//
//  StoreManager.swift
//  SESATS10
//
//  Created by Edward Bender on 12/30/25.
//

import Foundation
import RevenueCat

@MainActor
class StoreManager {
    static let shared = StoreManager()
    init() {
        
    }
    
    func subscriptionStatus() async throws -> Bool {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            return customerInfo.entitlements[Constants.ENTITLEMENT_ID]?.isActive == true
        }
    }
    
}
