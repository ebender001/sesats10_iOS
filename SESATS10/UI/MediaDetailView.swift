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
    
    var image: Image? {
        guard let path = Bundle.main.path(forResource: media, ofType: nil) else { return nil }
        guard let image = UIImage(contentsOfFile: path) else { return nil }
        return Image(uiImage: image)
    }
    
    
    var body: some View {
        if mediaType == .image, let image = image {
            NavigationStack {
                ZoomableScrollView {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .toolbar {
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
                if let url = Bundle.main.url(forResource: media, withExtension: nil) {
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
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                }
            }
        }
    }
    
}

//#Preview {
//    MediaDetailView()
//}
