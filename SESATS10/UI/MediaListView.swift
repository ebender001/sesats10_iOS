//
//  MediaListView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/19/25.
//

import SwiftUI

struct MediaListView: View {
    
    let question: Question
    @State private var selectedMedia: String = ""
    @State private var mediaType: MediaType = .image
    @State private var showMedia = false
    
    var body: some View {
        List {
            ForEach(Array(question.questionImageAssets.enumerated()), id: \.offset) { index, asset in
                Text("Image \(index + 1)")
                    .onTapGesture {
                        selectedMedia = asset
                        mediaType = .image
                        showMedia = true
                    }
                    .sheet(isPresented: $showMedia) {
                        MediaDetailView(media: $selectedMedia, mediaType: .image)
                    }
            }
            ForEach(Array(question.questionMovieAssets.enumerated()), id: \.offset) { index, asset in
                Text("Video \(index + 1)")
                    .onTapGesture {
                        selectedMedia = asset
                        mediaType = .video
                        showMedia = true
                    }
                    .sheet(isPresented: $showMedia) {
                        MediaDetailView(media: $selectedMedia, mediaType: .video)
                    }
            }
        }
//        .sheet(isPresented: $showMedia) {
//            if let media = selectedMedia, let type = mediaType {
//                MediaDetailView(media: media, mediaType: type)
//            }
//        }
        .navigationTitle("Media")
        
        
    }
}

enum MediaType {
    case image
    case video
}

//#Preview {
//    MediaListView()
//}
