//
//  CardioThoraxiaPromoCard.swift
//  SESATS10
//
//  Created by Edward Bender on 4/24/26.
//

import SafariServices
import SwiftUI

struct CardioThoraxiaPromoCard: View {
    private let appStoreURL = URL(string: "https://apps.apple.com/us/app/cardiothoraxia/id6758521707")!

    @State private var showAppStorePage = false
    @State private var showSimulatorWarning = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                Image("CardioThoraxiaIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Explore This in the Literature")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text("Open related cardiothoracic PubMed searches in CardioThoraxia.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button {
                #if targetEnvironment(simulator)
                showSimulatorWarning = true
                #else
                showAppStorePage = true
                #endif
            } label: {
                HStack {
                    Text("Open in CardioThoraxia")
                        .fontWeight(.semibold)

                    Spacer()

                    Image(systemName: "arrow.up.right.square")
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.purple.opacity(0.14))
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open in CardioThoraxia")
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.purple.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .sheet(isPresented: $showAppStorePage) {
            AppStoreSafariView(url: appStoreURL)
        }
        .alert("App Store Unavailable in Simulator", isPresented: $showSimulatorWarning) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The iOS Simulator cannot open App Store listing URLs reliably. Test this button on a physical iPhone or iPad.")
        }
    }
}

private struct AppStoreSafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let viewController = SFSafariViewController(url: url)
        viewController.dismissButtonStyle = .close
        return viewController
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
