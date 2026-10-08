//
//  RootView.swift
//  SESATS10
//

import SwiftUI

struct RootView: View {
    // Owned here, not in the layouts, so the user keeps their place when the
    // window resizes (e.g. folding iPhone Duo) and the layout swaps.
    @State private var route: [AppRoute] = []

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    var body: some View {
        #if os(macOS)
        SidebarSplitView(route: $route)
            .frame(minWidth: 900, idealWidth: 1100, minHeight: 700, idealHeight: 900)
        #elseif os(iOS)
        // Choose layout from the available width (size class), not the device
        // idiom, so iPad Split View, iPhone Duo and resizable windows adapt live.
        if horizontalSizeClass == .regular {
            SidebarSplitView(route: $route)
                .opensOwnLinksInApp()
        } else {
            ContentView(route: $route)
        }
        #else
        ContentView(route: $route)
        #endif
    }
}
