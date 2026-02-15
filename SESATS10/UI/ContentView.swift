//
//  ContentView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/17/25.
//

import SwiftUI
import SwiftData
import TipKit
import StoreKit

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var entitlements: EntitlementManager
    
    @Query var questions: [Question]
    @Query var aiUpdates: [AIUpdate]
    
    @State private var showCustomerCenter = false
    @State private var errorMessage: String?
    @State private var loading: Bool = false
    @State var scorecards = Scorecard.allScorecards
    @State private var showDisclaimer = false
    @State private var showPrivacyPolicy = false
    @State private var showResetConfirmation = false
    @State private var showSubscriptionStore: Bool = false
    @State private var showManageSubscriptions = false

    private enum Route: Hashable {
        case topic(String)
        case scorecard(correct: Bool)
    }

    @State private var path = NavigationPath()
    
    var databaseIsClean: Bool {
        questions.filter { !$0.selectedAnswer.isEmpty }.count == 0
    }
    
    var topics = Topic.allTopics
    
    private let subscriptionTip = SubscriptionTip()
    
    init() {
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Theme.bg
                    .ignoresSafeArea()

                topicList
                    .navigationTitle("SESATS 10")
                    .navigationBarTitleDisplayMode(.large)
                    .sheet(isPresented: $showDisclaimer) {
                        DisclaimerView()
                    }
                    .sheet(isPresented: $showPrivacyPolicy) {
                        PrivacyPolicyView()
                    }
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        footer
                    }
            }
            .task {
                if !dataSeeded {
                    print("Not seeded")
                    seedDatabase()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if entitlements.hasAIAccess {
                            showManageSubscriptions = true
                        } else {
                            showSubscriptionStore = true
                        }
                    } label: {
                        Image(systemName: "apple.intelligence")
                    }
                }
            }
            .sheet(isPresented: $showSubscriptionStore, onDismiss: {
                Task { await entitlements.refresh() }
            }) {
                PaywallView(productIDs: [
                    "com.cvoffice.sesats10.month",
                    "com.cvoffice.sesats10.annual"
                ])
                .environmentObject(entitlements)
            }
            .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .topic(let title):
                    QuestionListView(topic: title)
                case .scorecard(let correct):
                    ReviewQuestionListView(questions: questions, correctlyAnswered: correct)
                }
            }
        }
    }
    
    var topicList: some View {
        List {
            TipView(subscriptionTip)
            Section {
                ForEach(topics) { topic in
                    Button {
                        path.append(Route.topic(topic.title))
                    } label: {
                        TopicRowView(topic: topic)
                    }
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
                    Button {
                        path.append(Route.scorecard(correct: scorecard.title == "Correct"))
                    } label: {
                        ScorecardRowView(scorecard: scorecard)
                    }
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
    
    func topicQuestions(topic: String) -> [Question] {
        questions
            .filter{ $0.section == topic}
            .sorted { $0.finalQuestionNumber < $1.finalQuestionNumber }
    }
    
    func resetDatabase() {
        for question in questions {
            question.answeredCorrectly = false
            question.answeredIncorrectly = false
            question.selectedAnswer = ""
        }
        do {
            try deleteAll(of: AIUpdate.self, in: modelContext)
            try modelContext.save()
        } catch {
            print("Failed to reset database: \(error.localizedDescription)")
        }
    }
    
    func seedDatabase() {
        guard let path = Bundle.main.url(forResource: "questions", withExtension: "tsv") else {
            fatalError("Could not find questions file")
        }
        
        do {
            let questionsString = try String(contentsOf: path, encoding: .utf8)
                .replacingOccurrences(of: "\"", with: "")
                .replacingOccurrences(of: "&#39;", with: "'")
            let questionsArray = questionsString.components(separatedBy: "\n")
            //remove header row
            for x in 1..<questionsArray.count {
                let oneQuestion = questionsArray[x]
                let itemArray = oneQuestion.components(separatedBy: "\t")
                fillInDatabase(oneQuestion: itemArray)
            }
                
        } catch {
            fatalError("Could not load database: \(error.localizedDescription)")
        }
    }
    
    func fillInDatabase(oneQuestion: [String]) {
        var section = oneQuestion[10]
        if section == "Adult Acquired (TIVV)" {
            section = "Adult Acquired Cardiac"
        }
        if section == "Congenital" {
            section = "Congenital Cardiac"
        }
        
        let newQuestion = Question(abstract1Title: oneQuestion[19], abstract2Title: oneQuestion[20], abstract3Title: oneQuestion[21], abstract4Title: oneQuestion[22], answeredCorrectly: false, answeredIncorrectly: false, correctAnswer: oneQuestion[4], critique: oneQuestion[13], critiqueMedia: oneQuestion[14], distractorA: oneQuestion[5], distractorB: oneQuestion[6], distractorC: oneQuestion[7], distractorD: oneQuestion[8], distractorE: oneQuestion[9], examId: oneQuestion[1], finalQuestionNumber: Int(oneQuestion[3])!, id: oneQuestion[2], pubMedRefId1: oneQuestion[15], pubMedRefId2: oneQuestion[16], pubMedRefId3: oneQuestion[17], pubMedRefId4: oneQuestion[18], questionText: oneQuestion[12], section: section, selectedAnswer: "", stem: oneQuestion[11], title: oneQuestion[0])
        
        modelContext.insert(newQuestion)
    }
    
    var dataSeeded: Bool {
        let descriptor = FetchDescriptor<Question>()
        do {
            let count = try modelContext.fetchCount(descriptor)
            return count > 0
        } catch {
            print("Failed to fetch count: \(error.localizedDescription)")
            return false
        }
    }
}
