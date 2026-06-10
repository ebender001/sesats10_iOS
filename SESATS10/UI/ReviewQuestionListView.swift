//
//  ReviewQuestionListView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/21/25.
//

import SwiftUI

struct ReviewQuestionListView: View {
    let questions: [Question]
    let correctlyAnswered: Bool
    
    var correctQuestions: [Question] {
        questions.filter { $0.answeredCorrectly }
    }
    
    var incorrectQuestions: [Question] {
        questions.filter { $0.answeredIncorrectly }
    }
    
    var selectedQuestions: [Question] {
        correctlyAnswered ? correctQuestions : incorrectQuestions
    }
    
    var body: some View {
        Group {
            if selectedQuestions.isEmpty {
                ContentUnavailableView(
                    "Review Questions",
                    systemImage: "list.bullet",
                    description: Text("No \(correctlyAnswered ? "correctly" : "incorrectly") answered questions to display.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(selectedQuestions) { question in
                            NavigationLink {
                                ReviewQuestionDetailView(question: question)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(question.questionText)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(4)

//                                    Text("Question \(question.finalQuestionNumber)")
//                                        .font(.footnote)
//                                        .foregroundStyle(Theme.textSecondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .glassCardStyle()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .navigationTitle(
            correctlyAnswered ?
            "Answered Correctly" :
            "Answered Incorrectly"
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .containerBackground(for: .navigation) {
            Theme.screenBackground
        }
        .tint(Theme.accent)
    }
}

//#Preview {
//    ReviewQuestionListView()
//}
