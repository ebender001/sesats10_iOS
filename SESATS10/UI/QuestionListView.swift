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
        ZStack {
            Theme.bg
                .ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(topicQuestions.indices, id: \.self) { index in
                        let question = topicQuestions[index]

                        NavigationLink {
                            QuestionDetailView(question: question)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(index + 1).")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)

                                Text(question.questionText)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cardStyle()
                            .opacity(question.selectedAnswer.isEmpty ? 1.0 : 0.6)
                        }
                        .buttonStyle(.plain)
                        .disabled(!question.selectedAnswer.isEmpty)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle(topic)
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.accent)
    }
}

#Preview {
    QuestionListView(topic: "Mediastinum")
}
