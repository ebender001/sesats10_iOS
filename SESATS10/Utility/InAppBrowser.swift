//
//  InAppBrowser.swift
//  SESATS10
//
//  Opens our own web pages (privacy policy, terms) in a Safari sheet inside
//  the app instead of bouncing out to the Safari app, where there's no
//  reliable way back (notably on iPhone Duo). Other URLs, such as App Store
//  links, still open externally.
//

import SwiftUI
#if os(iOS)
import SafariServices

private struct SafariSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let viewController = SFSafariViewController(url: url)
        viewController.dismissButtonStyle = .close
        return viewController
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

private struct InAppBrowserModifier: ViewModifier {
    @State private var url: URL?

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { target in
                guard target.host == Constants.privacyPolicyURL.host else {
                    return .systemAction
                }
                url = target
                return .handled
            })
            .sheet(item: $url) { SafariSheet(url: $0).ignoresSafeArea() }
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
#endif

extension View {
    @ViewBuilder
    func opensOwnLinksInApp() -> some View {
        #if os(iOS)
        modifier(InAppBrowserModifier())
        #else
        self
        #endif
    }
}
