//
//  MediaListView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/19/25.
//

import SwiftUI

struct MediaListView: View {
    
    let question: Question
    @State private var selection: MediaSelection? = nil
    
    var body: some View {
        List {
            ForEach(Array(question.questionImageAssets.enumerated()), id: \.offset) { index, asset in
                Text("Image \(index + 1)")
                    .onTapGesture {
                        selection = MediaSelection(name: asset, type: .image)
                    }
            }
            ForEach(Array(question.questionMovieAssets.enumerated()), id: \.offset) { index, asset in
                Text("Video \(index + 1)")
                    .onTapGesture {
                        selection = MediaSelection(name: asset, type: .video)
                    }
            }
        }
        .sheet(item: $selection) { sel in
            // Use a constant binding so the detail view doesn't depend on transient state changes.
            MediaDetailView(media: .constant(sel.name), mediaType: sel.type)
        }
        .navigationTitle("Media")
        
        
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
