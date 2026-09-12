//
//  RootView.swift
//  SESATS10
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct RootView: View {
    var body: some View {
        #if os(macOS)
        SidebarSplitView()
            .frame(minWidth: 900, idealWidth: 1100, minHeight: 700, idealHeight: 900)
        #elseif os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            SidebarSplitView()
        } else {
            ContentView()
        }
        #else
        ContentView()
        #endif
    }
}
