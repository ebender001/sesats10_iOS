//
//  ContentView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/17/25.
//

import SwiftUI
import SwiftData
import StoreKit

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var entitlements: EntitlementManager
    @AppStorage("hasShownInitialDisclaimer") private var hasShownInitialDisclaimer = false
    
    @Query(
        filter: #Predicate<Question> { question in
            question.selectedAnswer != ""
        },
        sort: [SortDescriptor(\Question.finalQuestionNumber)]
    ) var answeredQuestions: [Question]
    
    @State private var showCustomerCenter = false
    @State private var errorMessage: String?
    @State private var loading: Bool = false
    @State private var showDisclaimer = false
    @State private var showPrivacyPolicy = false
    @State private var showResetConfirmation = false
    
    var databaseIsClean: Bool {
        answeredQuestions.isEmpty
    }
    
    var topics = Topic.allTopics
    private let scorecards = Scorecard.allScorecards
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg
                    .ignoresSafeArea()
                topicList
                    .navigationTitle("SESATS 10")
                    .navigationBarTitleDisplayMode(.large)
                    .sheet(isPresented: $showDisclaimer, onDismiss: {
                        hasShownInitialDisclaimer = true
                    }) {
                        DisclaimerView()
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                    }
                    .sheet(isPresented: $showPrivacyPolicy) {
                        PrivacyPolicyView()
                    }
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        footer
                    }
            }
        }
        .task {
            guard !hasShownInitialDisclaimer else { return }
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled, !hasShownInitialDisclaimer else { return }
            showDisclaimer = true
        }
    }
    
    var topicList: some View {
        List {
            Section {
                ForEach(topics) { topic in
                    NavigationLink {
                        QuestionListView(topic: topic.title)
                    } label: {
                        TopicRowView(topic: topic, progress: topicCompletion(for: topic.title))
                    }
                    .navigationLinkIndicatorVisibility(.hidden)
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            } header: {
                Text("Topics")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            Section {
                ForEach(scorecards) { scorecard in
                    NavigationLink {
                        ReviewQuestionListView(
                            questions: answeredQuestions,
                            correctlyAnswered: scorecard.title == "Correct"
                        )
                    } label: {
                        ScorecardRowView(
                            scorecard: scorecard,
                            count: scorecard.title == "Correct" ? correctAnswersCount : incorrectAnswersCount
                        )
                    }
                    .navigationLinkIndicatorVisibility(.hidden)
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            } header: {
                Text("Scorecard")
                    .font(.headline)
                    .foregroundStyle(.primary)
            } footer: {
                if !databaseIsClean {
                    Text("Reset database")
                        .fontWeight(.medium)
                        .onTapGesture {
                            showResetConfirmation.toggle()
                        }
                }
            }
        }
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)
        .alert(isPresented: $showResetConfirmation) {
            Alert(title: Text("Reset Database"),
                  message: Text("All of your answers and saved updates will be deleted."),
                  primaryButton: .destructive(Text("OK"), action: resetDatabase),
                  secondaryButton: .cancel())
        }
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .listStyle(.insetGrouped)
        .tint(Theme.accent)
    }
    
    var footer: some View {
        HStack(spacing: 18) {
            Button {
                showDisclaimer.toggle()
            } label: {
                Text("Disclaimer")
            }

            Text("•")
                .foregroundStyle(Theme.textSecondary)

            Button {
                showPrivacyPolicy.toggle()
            } label: {
                Text("Privacy Policy")
            }
        }
        .font(.footnote)
        .foregroundStyle(Theme.textSecondary)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Theme.bg)
        .overlay(Divider().opacity(0.4), alignment: .top)
    }

    private var correctAnswersCount: Int {
        answeredQuestions.filter(\.answeredCorrectly).count
    }

    private var incorrectAnswersCount: Int {
        answeredQuestions.filter(\.answeredIncorrectly).count
    }

    func topicCompletion(for topic: String) -> Double {
        let questionCount = BundledQuestionCatalog.questionCount(in: topic)
        guard questionCount > 0 else { return 0 }

        let answeredCount = answeredQuestions.filter { $0.section == topic }.count
        return Double(answeredCount) / Double(questionCount)
    }
    
    func resetDatabase() {
        do {
            try deleteAll(of: Question.self, in: modelContext)
            try deleteAll(of: AIUpdate.self, in: modelContext)
            try modelContext.save()
        } catch {
            print("Failed to reset database: \(error.localizedDescription)")
        }
    }
}
