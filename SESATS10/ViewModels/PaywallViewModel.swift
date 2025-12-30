//
//  PaywallViewModel.swift
//  SESATS10
//
//  Created by Edward Bender on 12/30/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI
import Combine

class PaywallViewModel: ObservableObject {
    @Published var offering: Offering?
    @Published var isLoading = false
    @Published var error: Error?
    
    @MainActor
    func refresh() async {
        isLoading = true
        error = nil
        
        do {
            let offerings = try await Purchases.shared.offerings()
            self.offering = offerings.current
        } catch {
            self.error = error
            self.offering = nil
        }
        
        isLoading = false
    }
}
