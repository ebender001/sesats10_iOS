//
//  TopicListView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/18/25.
//

import SwiftUI
import SwiftData

struct QuestionListView: View {
    @Query var questions: [Question]
    var topic: String
    
    var topicQuestions: [Question] {
        questions
            .filter{ $0.section == topic}
            .sorted { $0.finalQuestionNumber < $1.finalQuestionNumber }
    }
    
    var body: some View {
        List {
            ForEach(topicQuestions.indices, id: \.self) { index in
                NavigationLink {
                    QuestionDetailView(question: topicQuestions[index])
                } label: {
                    Text("\(index + 1). \(topicQuestions[index].questionText)")
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                }
                .disabled(!topicQuestions[index].selectedAnswer.isEmpty)
            }
        }
        .navigationTitle(topic)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    QuestionListView(topic: "Mediastinum")
}
