//
//  PaywallView.swift
//  SESATS10
//
//  Created by Edward Bender on 1/27/26.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var entitlements: EntitlementManager

    let productIDs: [String]

    @State private var showManageSubs = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var isPendingPurchase = false
    @State private var isRestoring = false
    @State private var showOfferCodeRedemption = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Unlock AI")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Get updated explanations and supplemental information generated on demand.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Label("AI critiques and updates", systemImage: "checkmark.circle")
                    Label("Works across the entire question set", systemImage: "checkmark.circle")
                    Label("Restore anytime on your Apple ID", systemImage: "checkmark.circle")
                }
                .font(.subheadline)
                .padding(.horizontal)

                Divider()

                // Apple-provided purchase UI
                StoreView(ids: productIDs)
                    .storeButton(.hidden, for: .cancellation)
                    .padding(.horizontal)
                    .onInAppPurchaseCompletion { _, purchaseResult in
                        isPendingPurchase = false

                        switch purchaseResult {
                        case .success(let purchase):
                            switch purchase {
                            case .success(let verification):
                                // Only treat a VERIFIED transaction as a real purchase.
                                guard case .verified(_) = verification else {
                                    alertTitle = "Purchase Error"
                                    alertMessage = "The transaction could not be verified. Please try again."
                                    showAlert = true
                                    return
                                }

                                Task {
                                    await entitlements.refresh()
                                    if entitlements.hasAIAccess {
                                        dismiss()
                                    }
                                }

                            case .userCancelled:
                                break

                            case .pending:
                                // Ask to Buy / billing approval / SCA.
                                isPendingPurchase = true
                                alertTitle = "Purchase Pending"
                                alertMessage = "Your purchase is pending approval. Once it completes, access will unlock automatically."
                                showAlert = true

                            @unknown default:
                                break
                            }

                        case .failure(let error):
                            alertTitle = "Purchase Error"
                            alertMessage = error.localizedDescription
                            showAlert = true
                        }
                    }

                Button {
                    showOfferCodeRedemption = true
                } label: {
                    HStack {
                        Image(systemName: "ticket")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("Redeem Offer Code")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                    }
                    .foregroundStyle(Theme.accent)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(Theme.accentMuted.opacity(0.14))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Theme.accent.opacity(0.22), lineWidth: 1)
                    )
                }
                .padding(.horizontal)

                Button {
                    Task {
                        isRestoring = true
                        defer { isRestoring = false }

                        do {
                            try await AppStore.sync()
                            await entitlements.refresh()

                            if entitlements.hasAIAccess {
                                alertTitle = "Restored"
                                alertMessage = "Your purchases have been restored."
                                showAlert = true
                                dismiss()
                            } else {
                                alertTitle = "Nothing to Restore"
                                alertMessage = "No active subscription or lifetime purchase was found for this Apple ID."
                                showAlert = true
                            }
                        } catch {
                            alertTitle = "Restore Failed"
                            alertMessage = error.localizedDescription
                            showAlert = true
                        }
                    }
                } label: {
                    HStack {
                        if isRestoring {
                            ProgressView()
                                .tint(Theme.surface)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.subheadline.weight(.semibold))
                        }
                        Spacer()
                        Text("Restore Purchases")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                    }
                    .foregroundStyle(Theme.surface)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(Theme.accent)
                    .clipShape(Capsule())
                    .shadow(color: Theme.accent.opacity(0.18), radius: 8, y: 3)
                }
                .padding(.horizontal)
                .disabled(isRestoring)
                .opacity(isRestoring ? 0.8 : 1)

                if isPendingPurchase {
                    HStack {
                        ProgressView()
                        Text("Waiting for purchase approval…")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 0)

                footer
                    .padding(.bottom, 8)
            }
            .alert(alertTitle,
                   isPresented: $showAlert,
                   actions: {
                       Button("OK", role: .cancel) { }
                   },
                   message: {
                Text(alertMessage)
            })
            .navigationTitle("SESATS 10 AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }

                ToolbarItem(placement: .primaryAction) {
                    if entitlements.hasAIAccess {
                        Button("Manage") { showManageSubs = true }
                    }
                }
            }
        }
        .manageSubscriptionsSheet(isPresented: $showManageSubs)
        .offerCodeRedemption(isPresented: $showOfferCodeRedemption) { result in
            switch result {
            case .success:
                Task {
                    await entitlements.refresh()
                    if entitlements.hasAIAccess {
                        dismiss()
                    }
                }
            case .failure(let error):
                alertTitle = "Offer Code Error"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    
    var footer: some View {
        HStack {
            Spacer()
            Link("Privacy Policy", destination: Constants.privacyPolicyURL)
                .buttonStyle(.plain)
                .padding(.horizontal)

            Link("Terms of Use", destination: Constants.termsOfUseURL)
                .buttonStyle(.plain)
                .padding(.horizontal)
            Spacer()
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
}
