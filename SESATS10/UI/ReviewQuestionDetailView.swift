//
//  ReviewQuestionDetailView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/21/25.
//

import SwiftUI

struct ReviewQuestionDetailView: View {
    let question: Question
    @State private var showMediaList = false
    @State private var showCritique = false
    
    var distractors: [String] {
        [
            question.distractorA,
            question.distractorB,
            question.distractorC,
            question.distractorD,
            question.distractorE
        ].filter { !$0.isEmpty }
    }
    
    var letters: [String] {
        //array of a, b, c, etc
        Array(0..<distractors.count).map {
            String(UnicodeScalar(65 + $0)!)
        }
    }
    
    var body: some View {
        questionDetail
            .navigationDestination(isPresented: $showMediaList) {
                MediaListView(question: question)
            }
            .navigationDestination(isPresented: $showCritique) {
                CritiqueView(question: question)
            }
    }
    
    var questionDetail: some View {
        VStack(spacing: 0) {
            ScrollView {
                Text(question.questionText)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 250)
            
            List {
                Section {
                    Text("Your answer: \(question.selectedAnswer.uppercased())").bold()
                }
                Section(header: Text("Correct answer is highlighted")) {
                    ForEach(Array(distractors.enumerated()), id: \.offset) { index, distractor in
                        
                        Text("\(letters[index].uppercased()).  \(distractor)")
                            .listRowBackground(
                                question.correctAnswer.lowercased() == letters[index].lowercased() ?
                                Color.yellow.opacity(0.3) : Color.clear
                            )
                    }
                }
            }
        }
        .padding()
        .navigationTitle(question.section)
        .toolbar {
            if !question.questionMovieAssets.isEmpty || !question.questionImageAssets.isEmpty {
                Button("Media") {
                    showMediaList.toggle()
                }
            }
            
            if !question.critique.isEmpty {
                Button("Critique") {
                    showCritique.toggle()
                }
            }
        }
    }
}

//#Preview {
//    ReviewQuestionDetailView()
//}
