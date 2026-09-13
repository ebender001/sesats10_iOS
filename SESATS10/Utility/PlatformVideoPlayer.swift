//
//  PlatformVideoPlayer.swift
//  SESATS10
//
//  SwiftUI's `VideoPlayer` on macOS routes through the private `_AVKit_SwiftUI`
//  framework, which has a Swift runtime metadata bug on macOS 26.6.2: the very
//  first time a `VideoPlayer` is constructed in an optimized/Release build, the
//  runtime aborts trying to resolve that framework's internal representable
//  class metadata (`getSuperclassMetadata` -> `swift::fatalError`). It does not
//  reproduce under `-Onone` (Debug), only in Release/archived builds.
//
//  Bypassing SwiftUI's `VideoPlayer` on macOS in favor of a plain
//  `NSViewRepresentable` around AppKit's `AVPlayerView` avoids that codepath
//  entirely. iOS is unaffected, so it keeps using SwiftUI's `VideoPlayer`.
//

import SwiftUI
import AVKit

#if os(macOS)
struct PlatformVideoPlayer: NSViewRepresentable {
    let player: AVPlayer?

    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.controlsStyle = .default
        view.player = player
        return view
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        if nsView.player !== player {
            nsView.player = player
        }
    }
}
#else
struct PlatformVideoPlayer: View {
    let player: AVPlayer?

    var body: some View {
        VideoPlayer(player: player)
    }
}
#endif
