//
//  MediaListView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/19/25.
//

import SwiftUI

struct MediaListView: View {
    
    private let imageAssets: [String]
    private let movieAssets: [String]
    @State private var selection: MediaSelection? = nil

    init(question: Question) {
        self.imageAssets = question.questionImageAssets
        self.movieAssets = question.questionMovieAssets
    }

    init(detail: BundledQuestionDetail) {
        self.imageAssets = detail.questionImageAssets
        self.movieAssets = detail.questionMovieAssets
    }
    
    var body: some View {
        List {
            ForEach(Array(imageAssets.enumerated()), id: \.offset) { index, asset in
                Button {
                    selection = MediaSelection(name: asset, type: .image)
                } label: {
                    HStack {
                        Text("Image \(index + 1)")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
            }
            ForEach(Array(movieAssets.enumerated()), id: \.offset) { index, asset in
                Button {
                    selection = MediaSelection(name: asset, type: .video)
                } label: {
                    HStack {
                        Text("Video \(index + 1)")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
            }
        }
        .sheet(item: $selection) { sel in
            // Use a constant binding so the detail view doesn't depend on transient state changes.
            MediaDetailView(media: .constant(sel.name), mediaType: sel.type)
        }
        .navigationTitle("Media")
        .listRowSeparator(.hidden)
        .scrollContentBackground(.hidden)
        .background(Theme.bg.ignoresSafeArea())
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

//#Preview {
//    MediaListView()
//}
