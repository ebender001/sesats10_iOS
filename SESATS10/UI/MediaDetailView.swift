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
    
    var image: Image? {
        guard let path = Bundle.main.path(forResource: resolvedMedia, ofType: nil) else { return nil }
        guard let image = UIImage(contentsOfFile: path) else { return nil }
        return Image(uiImage: image)
    }
    
    
    var body: some View {
        Group {
            if mediaType == .image, let image = image {
                NavigationStack {
                    image
                        .resizable()
                        .scaledToFit()
                        .padding()
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

//#Preview {
//    MediaDetailView()
//}
