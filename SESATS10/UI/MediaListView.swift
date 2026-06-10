//
//  MediaListView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/19/25.
//

import SwiftUI
import AVKit

struct MediaListView: View {
    private let imageAssets: [String]
    private let movieAssets: [String]

    init(question: Question) {
        self.imageAssets = question.questionImageAssets
        self.movieAssets = question.questionMovieAssets
    }

    init(detail: BundledQuestionDetail) {
        self.imageAssets = detail.questionImageAssets
        self.movieAssets = detail.questionMovieAssets
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                ForEach(Array(imageAssets.enumerated()), id: \.offset) { index, asset in
                    MediaImageCard(assetName: asset, title: "Image \(index + 1)")
                }

                ForEach(Array(movieAssets.enumerated()), id: \.offset) { index, asset in
                    MediaVideoCard(assetName: asset, title: "Video \(index + 1)")
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .navigationTitle("Media")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .containerBackground(for: .navigation) {
            Theme.screenBackground
        }
    }
}

struct MediaSelection: Identifiable {
    let id = UUID()
    let name: String
    let type: MediaType
}

enum MediaType {
    case image
    case video
}

private struct MediaImageCard: View {
    let assetName: String
    let title: String

    private var uiImage: UIImage? {
        guard let path = Bundle.main.path(forResource: assetName, ofType: nil) else { return nil }
        return UIImage(contentsOfFile: path)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)

            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                ContentUnavailableView(
                    "Image Unavailable",
                    systemImage: "photo",
                    description: Text(assetName)
                )
                .frame(maxWidth: .infinity, minHeight: 160)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCardStyle()
    }
}

private struct MediaVideoCard: View {
    let assetName: String
    let title: String

    @State private var player: AVPlayer?

    private var url: URL? {
        Bundle.main.url(forResource: assetName, withExtension: nil)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)

            if url != nil {
                VideoPlayer(player: player)
                    .frame(minHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .onAppear {
                        if let url, player == nil {
                            player = AVPlayer(url: url)
                        }
                    }
                    .onDisappear {
                        player?.pause()
                        player = nil
                    }
            } else {
                ContentUnavailableView(
                    "Video Unavailable",
                    systemImage: "video",
                    description: Text(assetName)
                )
                .frame(maxWidth: .infinity, minHeight: 160)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCardStyle()
    }
}
