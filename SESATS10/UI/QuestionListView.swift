//
//  TopicListView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/18/25.
//

import SwiftUI
import SwiftData

struct QuestionListView: View {
    @Query private var answeredQuestions: [Question]
    private let topicQuestions: [BundledQuestionSummary]
    var topic: String

    init(topic: String) {
        self.topic = topic
        self.topicQuestions = BundledQuestionCatalog.questions(in: topic)
        _answeredQuestions = Query(
            filter: #Predicate<Question> { question in
                question.section == topic && question.selectedAnswer != ""
            },
            sort: [SortDescriptor(\Question.finalQuestionNumber)]
        )
    }

    private var answeredQuestionIDs: Set<String> {
        Set(answeredQuestions.map(\.id))
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(Array(topicQuestions.enumerated()), id: \.element.id) { index, question in
                    NavigationLink {
                        QuestionDetailLoaderView(questionID: question.id, sectionTitle: topic)
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
                        .glassCardStyle()
                        .opacity(answeredQuestionIDs.contains(question.id) ? 0.6 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .disabled(answeredQuestionIDs.contains(question.id))
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .navigationTitle(topic)
        .iOSNavigationBarTitleDisplayMode(.inline)
        .hiddenNavigationBarBackground()
        .platformNavigationBackground {
            Theme.screenBackground(for: topic)
        }
        .tint(Theme.accent)
    }
}

private struct QuestionDetailLoaderView: View {
    let questionID: String
    let sectionTitle: String

    init(questionID: String, sectionTitle: String) {
        self.questionID = questionID
        self.sectionTitle = sectionTitle
    }

    var body: some View {
        Group {
            if let detail = BundledQuestionCatalog.detail(for: questionID) {
                QuestionDetailView(detail: detail)
            } else {
                ZStack {
                    Theme.bg
                        .ignoresSafeArea()

                    ContentUnavailableView(
                        "Question Unavailable",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Unable to load this question from the bundled catalog.")
                    )
                }
                .navigationTitle(sectionTitle)
                .iOSNavigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    QuestionListView(topic: "Mediastinum")
}
