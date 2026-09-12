//
//  PlatformNavigation.swift
//  SESATS10
//
//  `navigationBarTitleDisplayMode`, `.toolbarBackground(for: .navigationBar)`,
//  and `.topBarTrailing` don't exist on macOS at all (not just no-ops) — any
//  file using them fails to compile against the macOS SDK. These wrappers
//  keep iOS/iPadOS behavior identical while making macOS builds no-ops.
//

import SwiftUI

enum PlatformTitleDisplayMode {
    case inline
    case large
}

extension View {
    @ViewBuilder
    func iOSNavigationBarTitleDisplayMode(_ mode: PlatformTitleDisplayMode) -> some View {
        #if os(iOS)
        switch mode {
        case .inline:
            self.navigationBarTitleDisplayMode(.inline)
        case .large:
            self.navigationBarTitleDisplayMode(.large)
        }
        #else
        self
        #endif
    }

    @ViewBuilder
    func hiddenNavigationBarBackground() -> some View {
        #if os(iOS)
        self.toolbarBackground(.hidden, for: .navigationBar)
        #else
        self
        #endif
    }
}

extension ToolbarItemPlacement {
    static var platformTrailing: ToolbarItemPlacement {
        #if os(macOS)
        .automatic
        #else
        .topBarTrailing
        #endif
    }
}

extension View {
    /// `.containerBackground(for: .navigation)` is unavailable on macOS;
    /// a plain `.background` gives the same full-bleed art behind the view.
    @ViewBuilder
    func platformNavigationBackground<Background: View>(
        @ViewBuilder _ background: @escaping () -> Background
    ) -> some View {
        #if os(iOS)
        self.containerBackground(for: .navigation, content: background)
        #else
        self.background(background())
        #endif
    }
}
