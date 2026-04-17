//
//  MediaDetailView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/19/25.
//

import SwiftUI
import AVKit

struct MediaDetailView: View {
    @Binding var media: String
    var mediaType: MediaType
    
    @Environment(\.dismiss) var dismiss
    @State private var player: AVPlayer?
    @State private var resolvedMedia: String = ""
    
    var uiImage: UIImage? {
        guard let path = Bundle.main.path(forResource: resolvedMedia, ofType: nil) else { return nil }
        return UIImage(contentsOfFile: path)
    }
    
    
    var body: some View {
        Group {
            if mediaType == .image, let uiImage = uiImage {
                NavigationStack {
                    ZoomableImageView(uiImage: uiImage)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                }
            } else if mediaType == .video {
                NavigationStack {
                    if let url = Bundle.main.url(forResource: resolvedMedia, withExtension: nil) {
                        VideoPlayer(player: player)
                            .onAppear {
                                player = AVPlayer(url: url)
                                player?.play()
                            }
                            .onDisappear {
                                player?.pause()
                                player = nil
                            }
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button {
                                        dismiss()
                                    } label: {
                                        Image(systemName: "xmark")
                                    }
                                }
                            }
                    } else {
                        ProgressView()
                            .padding()
                    }
                }
            } else {
                ProgressView()
                    .padding()
            }
        }
        .onAppear {
            // Capture the media name once so transient binding changes don't dismiss the view.
            if resolvedMedia.isEmpty {
                resolvedMedia = media
            }
        }
        .onChange(of: media) { _, newValue in
            // If the selection changes while presented, update the resolved value.
            if !newValue.isEmpty {
                resolvedMedia = newValue
            }
        }
    }
    
}

private struct ZoomableImageView: View {
    let uiImage: UIImage

    @State private var scale = 1.0
    @State private var lastScale = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let fittedSize = fittedImageSize(in: geometry.size)

            Image(uiImage: uiImage)
                .resizable()
                .frame(width: fittedSize.width, height: fittedSize.height)
                .scaleEffect(scale)
                .offset(offset)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    SimultaneousGesture(
                        magnificationGesture(in: geometry.size, fittedSize: fittedSize),
                        dragGesture(in: geometry.size, fittedSize: fittedSize)
                    )
                )
                .animation(.easeInOut(duration: 0.2), value: scale)
                .animation(.easeInOut(duration: 0.2), value: offset)
                .background(Color.black.opacity(0.001))
        }
        .padding()
    }

    private func magnificationGesture(in containerSize: CGSize, fittedSize: CGSize) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let updatedScale = min(max(lastScale * value.magnification, 1.0), 4.0)
                scale = updatedScale
                offset = clampedOffset(
                    proposed: offset,
                    scale: updatedScale,
                    containerSize: containerSize,
                    fittedSize: fittedSize
                )
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1.0 {
                    scale = 1.0
                    lastScale = 1.0
                    offset = .zero
                    lastOffset = .zero
                } else {
                    offset = clampedOffset(
                        proposed: offset,
                        scale: scale,
                        containerSize: containerSize,
                        fittedSize: fittedSize
                    )
                    lastOffset = offset
                }
            }
    }

    private func dragGesture(in containerSize: CGSize, fittedSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1.0 else { return }

                offset = clampedOffset(
                    proposed: CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    ),
                    scale: scale,
                    containerSize: containerSize,
                    fittedSize: fittedSize
                )
            }
            .onEnded { _ in
                guard scale > 1.0 else {
                    offset = .zero
                    lastOffset = .zero
                    return
                }

                lastOffset = offset
            }
    }

    private func fittedImageSize(in containerSize: CGSize) -> CGSize {
        let imageSize = uiImage.size
        guard imageSize.width > 0, imageSize.height > 0 else { return containerSize }

        let widthRatio = containerSize.width / imageSize.width
        let heightRatio = containerSize.height / imageSize.height
        let ratio = min(widthRatio, heightRatio)

        return CGSize(
            width: imageSize.width * ratio,
            height: imageSize.height * ratio
        )
    }

    private func clampedOffset(
        proposed: CGSize,
        scale: Double,
        containerSize: CGSize,
        fittedSize: CGSize
    ) -> CGSize {
        let scaledWidth = fittedSize.width * scale
        let scaledHeight = fittedSize.height * scale

        let maxX = max((scaledWidth - containerSize.width) / 2, 0)
        let maxY = max((scaledHeight - containerSize.height) / 2, 0)

        return CGSize(
            width: min(max(proposed.width, -maxX), maxX),
            height: min(max(proposed.height, -maxY), maxY)
        )
    }
}

//#Preview {
//    MediaDetailView()
//}
