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
        if selectedQuestions.isEmpty {
            ContentUnavailableView(
                "Review Questions",
                systemImage: "list.bullet",
                description: Text("No \(correctlyAnswered ? "correctly" : "incorrectly") answered questions to display.")
            )
            .navigationTitle(
                correctlyAnswered ?
                "Answered Correctly" :
                "Answered Incorrectly"
            )
            .navigationBarTitleDisplayMode(.inline)
        } else {
            List {
                ForEach(selectedQuestions) { question in
                    NavigationLink {
                        ReviewQuestionDetailView(question: question)
                    } label: {
                        Text(question.questionText)
                            .multilineTextAlignment(.leading)
                            .lineLimit(4)
                    }
                }
            }
            .navigationTitle(
                correctlyAnswered ?
                "Answered Correctly" :
                "Answered Incorrectly"
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

//#Preview {
//    ReviewQuestionListView()
//}
