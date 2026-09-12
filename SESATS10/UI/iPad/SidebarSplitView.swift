//
//  SidebarSplitView.swift
//  SESATS10
//
//  iPad root: a left nav column (topics/scorecard) plus a right-hand detail
//  column that hosts its own push navigation — selecting a topic shows its
//  question list, then selecting a question slides in the detail, mirroring
//  the phone's push flow instead of pinning everything into fixed columns.
//

import SwiftUI
import SwiftData

enum SidebarSelection: Hashable {
    case topic(String)
    case scorecard(correct: Bool)
}

private enum QuestionRoute: Hashable {
    case topicQuestion(String)
    case reviewQuestion(String)
}

struct SidebarSplitView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var entitlements: EntitlementManager
    @AppStorage("hasShownInitialDisclaimer") private var hasShownInitialDisclaimer = false

    @Query(
        filter: #Predicate<Question> { question in
            question.selectedAnswer != ""
        },
        sort: [SortDescriptor(\Question.finalQuestionNumber)]
    ) private var answeredQuestions: [Question]

    @State private var sidebarSelection: SidebarSelection?
    @State private var detailPath = NavigationPath()
    @State private var showDisclaimer = false
    @State private var showResetConfirmation = false

    private let topics = Topic.allTopics
    private let scorecards = Scorecard.allScorecards

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            NavigationStack(path: $detailPath) {
                detailRoot
                    .navigationDestination(for: QuestionRoute.self) { route in
                        switch route {
                        case .topicQuestion(let id):
                            if let detail = BundledQuestionCatalog.detail(for: id) {
                                QuestionDetailView(detail: detail)
                            }
                        case .reviewQuestion(let id):
                            if let question = answeredQuestions.first(where: { $0.id == id }) {
                                ReviewQuestionDetailView(question: question)
                            }
                        }
                    }
            }
        }
        .tint(Theme.accent)
        .sheet(isPresented: $showDisclaimer, onDismiss: {
            hasShownInitialDisclaimer = true
        }) {
            DisclaimerView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .task {
            guard !hasShownInitialDisclaimer else { return }
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled, !hasShownInitialDisclaimer else { return }
            showDisclaimer = true
        }
        .onChange(of: sidebarSelection) { _, _ in
            detailPath = NavigationPath()
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        List(selection: $sidebarSelection) {
            Section("Topics") {
                ForEach(topics) { topic in
                    SidebarTopicRow(topic: topic, progress: topicCompletion(for: topic.title))
                        .tag(SidebarSelection.topic(topic.title))
                }
            }

            Section {
                ForEach(scorecards) { scorecard in
                    SidebarScorecardRow(
                        scorecard: scorecard,
                        count: scorecard.title == "Correct" ? correctAnswersCount : incorrectAnswersCount
                    )
                    .tag(SidebarSelection.scorecard(correct: scorecard.title == "Correct"))
                }
            } header: {
                Text("Scorecard")
            } footer: {
                if !answeredQuestions.isEmpty {
                    Button(role: .destructive) {
                        showResetConfirmation.toggle()
                    } label: {
                        Label("Reset Scorecard", systemImage: "trash")
                    }
                    .padding(.top, 4)
                }
            }

            Section("About") {
                Button {
                    showDisclaimer.toggle()
                } label: {
                    Label("Disclaimer", systemImage: "info.circle")
                }

                Button {
                    openURL(Constants.privacyPolicyURL)
                } label: {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
            }
        }
        .navigationTitle("SESATS 10")
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 400)
        .alert("Reset Scorecard", isPresented: $showResetConfirmation) {
            Button("OK", role: .destructive, action: resetDatabase)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All of your answers and saved updates will be deleted.")
        }
    }

    // MARK: - Detail column root (question list; detail pushes on top of this)

    @ViewBuilder
    private var detailRoot: some View {
        switch sidebarSelection {
        case .topic(let topic):
            TopicQuestionsColumn(topic: topic, answeredQuestions: answeredQuestions)
        case .scorecard(let correct):
            ReviewQuestionsColumn(questions: scorecardQuestions(correct: correct), correctlyAnswered: correct)
        case nil:
            ContentUnavailableView(
                "Select a Topic",
                systemImage: "list.bullet.rectangle",
                description: Text("Choose a topic or scorecard from the sidebar.")
            )
        }
    }

    // MARK: - Helpers

    private var correctAnswersCount: Int {
        answeredQuestions.filter(\.answeredCorrectly).count
    }

    private var incorrectAnswersCount: Int {
        answeredQuestions.filter(\.answeredIncorrectly).count
    }

    private func scorecardQuestions(correct: Bool) -> [Question] {
        correct ? answeredQuestions.filter(\.answeredCorrectly) : answeredQuestions.filter(\.answeredIncorrectly)
    }

    private func topicCompletion(for topic: String) -> Double {
        let questionCount = BundledQuestionCatalog.questionCount(in: topic)
        guard questionCount > 0 else { return 0 }

        let answeredCount = answeredQuestions.filter { $0.section == topic }.count
        return Double(answeredCount) / Double(questionCount)
    }

    private func resetDatabase() {
        do {
            try deleteAll(of: Question.self, in: modelContext)
            try deleteAll(of: AIUpdate.self, in: modelContext)
            try modelContext.save()
        } catch {
            print("Failed to reset database: \(error.localizedDescription)")
        }
    }
}

// MARK: - Sidebar rows (compact — built for a ~300pt column, not a phone card)

private struct SidebarTopicRow: View {
    let topic: Topic
    let progress: Double

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(topic.imageString)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(Theme.accentMuted)
                .padding(.top, 2)

            Text(topic.title)
                .font(.body)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(progress.formatted(.percent.precision(.fractionLength(0))))
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
                .monospacedDigit()
                .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }
}

private struct SidebarScorecardRow: View {
    let scorecard: Scorecard
    let count: Int

    private var iconTint: Color {
        switch scorecard.title {
        case "Correct":
            return Theme.success
        case "Incorrect":
            return Theme.error
        default:
            return Theme.accent
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(scorecard.imageString)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(iconTint)

            Text(scorecard.title)
                .font(.body)
                .lineLimit(1)

            Spacer(minLength: 4)

            Text("\(count)")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
                .monospacedDigit()
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Detail column: question lists (push into detail)

private struct TopicQuestionsColumn: View {
    let topic: String
    let answeredQuestions: [Question]

    private var topicQuestions: [BundledQuestionSummary] {
        BundledQuestionCatalog.questions(in: topic)
    }

    private var answeredQuestionIDs: Set<String> {
        Set(answeredQuestions.filter { $0.section == topic }.map(\.id))
    }

    var body: some View {
        List {
            ForEach(Array(topicQuestions.enumerated()), id: \.element.id) { index, question in
                let isAnswered = answeredQuestionIDs.contains(question.id)

                NavigationLink(value: QuestionRoute.topicQuestion(question.id)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(index + 1).")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                        Text(question.questionText)
                            .font(.headline)
                            .lineLimit(3)
                    }
                    .opacity(isAnswered ? 0.6 : 1.0)
                }
                .disabled(isAnswered)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .navigationTitle(topic)
        .listStyle(.plain)
        .platformNavigationBackground {
            Theme.screenBackground(for: topic)
        }
    }
}

private struct ReviewQuestionsColumn: View {
    let questions: [Question]
    let correctlyAnswered: Bool

    var body: some View {
        Group {
            if questions.isEmpty {
                ContentUnavailableView(
                    "Review Questions",
                    systemImage: "list.bullet",
                    description: Text("No \(correctlyAnswered ? "correctly" : "incorrectly") answered questions to display.")
                )
            } else {
                List {
                    ForEach(questions) { question in
                        NavigationLink(value: QuestionRoute.reviewQuestion(question.id)) {
                            Text(question.questionText)
                                .font(.headline)
                                .lineLimit(3)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listStyle(.plain)
            }
        }
        .navigationTitle(correctlyAnswered ? "Answered Correctly" : "Answered Incorrectly")
        .platformNavigationBackground {
            Theme.screenBackground
        }
    }
}
