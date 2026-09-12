//
//  PlatformImage.swift
//  SESATS10
//
//  UIImage doesn't exist on macOS; NSImage doesn't exist on iOS. Both share
//  the same `init?(contentsOfFile:)` signature, so a typealias covers
//  loading — only constructing a SwiftUI Image from one differs per platform.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

extension Image {
    init(platformImage: PlatformImage) {
        #if canImport(UIKit)
        self.init(uiImage: platformImage)
        #elseif canImport(AppKit)
        self.init(nsImage: platformImage)
        #endif
    }
}
