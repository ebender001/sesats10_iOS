//
//  CritiqueView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/20/25.
//

import SwiftUI
import SwiftData
import ParseSwift
import TipKit

struct CritiqueView: View {

    let question: Question
    let aiTip = AITip()
    private let oralBoardsAppStoreURL = URL(string: "https://apps.apple.com/us/app/oral-boards-ai/id6763632588")!

    @EnvironmentObject var entitlements: EntitlementManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    @State private var showPaywall = false
    @State private var showOralBoardsPromo = false
    @State private var hasAnimatedOralBoardsPromo = false
    @State private var isCritiqueExpanded = false
    @State private var aiUpdateText: String?
    @State private var aiUpdateIsLoading = false
    @State private var aiUpdateError: String?
    @State private var isAIUpdateExpanded = false
    @State private var answerVerdict: AnswerVerdict = .unknown
    @State private var critiqueVerdict: CritiqueVerdict = .unknown

    private var shouldShowOralBoardsPromo: Bool {
        !question.selectedAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || question.answeredCorrectly
            || question.answeredIncorrectly
    }

    var body: some View {
        Form {
            Section {
                Text("Question \(question.finalQuestionNumber) • \(question.section)")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCardStyle()
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowBackground(Color.clear)
            }

            Section {
                aiUpdateVerdictCard
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowBackground(Color.clear)
                    .popoverTip(aiTip, arrowEdge: .top)
            }

            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(isCritiqueExpanded ? "Hide Critique" : "Show Critique")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textSecondary)

                        Spacer()

                        Image(systemName: isCritiqueExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.textSecondary)
                    }

                    if isCritiqueExpanded {
                        Text(question.critique)
                            .foregroundStyle(.primary)
                            .textSelection(.enabled)
                            .transition(.opacity)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(question.critique)
                                .foregroundStyle(.primary)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)

                            Text("Show more")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.accent)
                        }
                        .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .glassCardStyle()
                .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        isCritiqueExpanded.toggle()
                    }
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                .listRowBackground(Color.clear)
            }

            if shouldShowOralBoardsPromo && showOralBoardsPromo {
                OralBoardsPromoCard(action: openOralBoardsApp)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowBackground(Color.clear)
                    .transition(.opacity.combined(with: .offset(y: 10)))
            }
        }
        // Theme (Form-friendly)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .tint(Theme.accent)
        .navigationTitle("Critique")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .containerBackground(for: .navigation) {
            Theme.screenBackground(for: question.section)
        }
        .onAppear {
            guard shouldShowOralBoardsPromo else { return }

            if hasAnimatedOralBoardsPromo {
                showOralBoardsPromo = true
                return
            }

            hasAnimatedOralBoardsPromo = true

            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.25)) {
                    showOralBoardsPromo = true
                }
            }
        }
        .task(id: question.id) {
            await entitlements.refresh()
            await fetchAIUpdateIfNeeded()
        }
        .onChange(of: entitlements.hasAIAccess) { _, hasAccess in
            guard hasAccess else { return }
            Task { await fetchAIUpdateIfNeeded() }
        }
        .sheet(isPresented: $showPaywall, onDismiss: {
            Task {
                await entitlements.refresh()
                await fetchAIUpdateIfNeeded()
            }
        }) {
            PaywallView(productIDs: [
                "com.cvoffice.sesats10.month",
                "com.cvoffice.sesats10.annual"
            ])
            .environmentObject(entitlements)
        }
    }

    private var aiUpdateVerdictCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Theme.accent)

                VStack(alignment: .leading, spacing: 6) {
                    Text(aiUpdateCardTitle)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(aiUpdateCardBody)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)

                    if let note = aiUpdateCritiqueNote {
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    if entitlements.hasAIAccess, aiUpdateIsLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Loading AI Update...")
                                .font(.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }

                    if !entitlements.hasAIAccess {
                        Text("Subscribe to view the full AI Update.")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.accent)
                    }

                    if entitlements.hasAIAccess, aiUpdateText != nil, !isAIUpdateExpanded {
                        Text("Tap to expand the full AI Update.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.accent)
                            .transition(.opacity)
                    }

                    if entitlements.hasAIAccess, isAIUpdateExpanded, let aiUpdateText {
                        VStack(alignment: .leading, spacing: 8) {
                            Divider()
                                .padding(.vertical, 2)

                            markdownText(formattedAIUpdateText(aiUpdateText))
                                .font(.body)
                                .foregroundStyle(.primary)
                                .textSelection(.enabled)
                        }
                        .transition(.opacity)
                    }
                }

                Spacer(minLength: 0)

                if entitlements.hasAIAccess, aiUpdateText != nil {
                    Image(systemName: isAIUpdateExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCardStyle()
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .inset(by: 1)
                .strokeBorder(aiUpdateBorderColor, lineWidth: 2)
        }
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onTapGesture {
            aiTip.invalidate(reason: .actionPerformed)

            if entitlements.hasAIAccess {
                guard aiUpdateText != nil else { return }
                withAnimation(.easeInOut(duration: 0.22)) {
                    isAIUpdateExpanded.toggle()
                }
            } else {
                showPaywall = true
            }
        }
    }

    private var aiUpdateCardTitle: String {
        if !entitlements.hasAIAccess {
            return "AI Update Available"
        }

        if aiUpdateIsLoading {
            return "AI Update"
        }

        if aiUpdateError != nil {
            return "AI Update unavailable"
        }

        switch answerVerdict {
        case .stillCorrect:
            return "AI Update: Answer Still Valid"
        case .ambiguous:
            return "AI Update: Answer Needs Review"
        case .outdated:
            return "AI Update: Answer May Be Outdated"
        case .unknown:
            return "AI Update"
        }
    }

    private var aiUpdateCardBody: String {
        if !entitlements.hasAIAccess {
            return "Modern practice review is available for this question."
        }

        if aiUpdateIsLoading {
            return "Loading AI Update..."
        }

        if aiUpdateError != nil {
            return "Unable to load the cached AI Update. Please try again."
        }

        switch answerVerdict {
        case .stillCorrect:
            return "The originally correct answer remains consistent with current practice."
        case .ambiguous:
            return "Current evidence or practice may make the original answer less definitive."
        case .outdated:
            return "Current practice may differ from the originally correct answer."
        case .unknown:
            return "Modern practice review is available for this question."
        }
    }

    private var aiUpdateCritiqueNote: String? {
        guard entitlements.hasAIAccess, !aiUpdateIsLoading, aiUpdateError == nil else { return nil }

        switch critiqueVerdict {
        case .current:
            return "Original critique remains current."
        case .partiallyOutdated:
            return "Original critique is partially outdated."
        case .outdated:
            return "Original critique is outdated."
        case .unknown:
            return "Critique status unavailable."
        }
    }

    private var aiUpdateBorderColor: Color {
        guard entitlements.hasAIAccess, !aiUpdateIsLoading, aiUpdateError == nil else {
            return Theme.divider.opacity(0.7)
        }

        switch answerVerdict {
        case .stillCorrect:
            return Theme.success
        case .ambiguous:
            return .orange
        case .outdated:
            return Theme.error
        case .unknown:
            return Theme.divider.opacity(0.7)
        }
    }

    @MainActor
    private func fetchAIUpdateIfNeeded() async {
        guard entitlements.hasAIAccess else { return }
        guard aiUpdateText == nil, !aiUpdateIsLoading else { return }

        let questionID = question.id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !questionID.isEmpty else {
            aiUpdateError = "Question is missing an ID."
            return
        }

        aiUpdateError = nil

        if let cachedUpdate = fetchCachedAIUpdate(),
           !cachedUpdate.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            applyAIUpdateText(cachedUpdate.text)
            return
        }

        aiUpdateIsLoading = true
        defer { aiUpdateIsLoading = false }

        let request = GenerateSesatsAIUpdateCloud(
            questionId: questionID,
            questionText: question.questionText,
            distractorA: question.distractorA,
            distractorB: question.distractorB,
            distractorC: question.distractorC,
            distractorD: question.distractorD,
            distractorE: question.distractorE,
            correctAnswer: question.correctAnswer,
            critique: question.critique,
            title: question.title,
            section: question.section,
            examId: question.examId
        )

        do {
            let result = try await request.runFunction()
            let cleanText = result.text.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !cleanText.isEmpty else {
                aiUpdateError = "AI update was empty."
                return
            }

            applyAIUpdateText(cleanText)
            saveAIUpdate(cleanText, questionID: questionID)
        } catch {
            aiUpdateError = error.localizedDescription
        }
    }

    @MainActor
    private func fetchCachedAIUpdate() -> AIUpdate? {
        let questionID = question.id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !questionID.isEmpty else { return nil }

        do {
            let allUpdates = try modelContext.fetch(FetchDescriptor<AIUpdate>())
            return allUpdates.first(where: { $0.id == questionID })
        } catch {
            print("Could not fetch cached AI update for \(question.id): \(error)")
            return nil
        }
    }

    @MainActor
    private func saveAIUpdate(_ text: String, questionID: String) {
        do {
            if let existing = fetchCachedAIUpdate() {
                existing.text = text
                existing.date = .now
            } else {
                modelContext.insert(AIUpdate(id: questionID, text: text, date: .now))
            }

            try modelContext.save()
        } catch {
            print("Could not save cached AI update for \(question.id): \(error)")
        }
    }

    @MainActor
    private func applyAIUpdateText(_ text: String) {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        aiUpdateText = cleanText
        aiUpdateError = nil
        parseVerdicts(from: cleanText)
    }

    @MainActor
    private func parseVerdicts(from text: String) {
        answerVerdict = .unknown
        critiqueVerdict = .unknown

        for line in text.components(separatedBy: .newlines) {
            let parts = line.split(separator: ":", maxSplits: 1).map { String($0) }
            guard parts.count == 2 else { continue }

            let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)

            if key == "VERDICT_ANSWER" {
                answerVerdict = AnswerVerdict(rawValue: value) ?? .unknown
            } else if key == "VERDICT_CRITIQUE" {
                critiqueVerdict = CritiqueVerdict(rawValue: value) ?? .unknown
            }
        }
    }

    @ViewBuilder
    private func markdownText(_ text: String) -> some View {
        if let attributed = try? AttributedString(
            markdown: text,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        ) {
            Text(attributed)
        } else {
            Text(text)
        }
    }

    private func formattedAIUpdateText(_ text: String) -> String {
        text
            .components(separatedBy: .newlines)
            .map { line in
                guard let colonIndex = line.firstIndex(of: ":") else { return line }

                let key = String(line[..<colonIndex])
                let valueStart = line.index(after: colonIndex)
                let rawValue = String(line[valueStart...]).trimmingCharacters(in: .whitespaces)

                guard key == "VERDICT_ANSWER" || key == "VERDICT_CRITIQUE" else {
                    return line
                }

                let displayKey = key.replacingOccurrences(of: "_", with: " ")
                let displayValue = rawValue.replacingOccurrences(of: "_", with: " ")
                return "\(displayKey): **\(displayValue)**"
            }
            .joined(separator: "\n")
    }

    private func openOralBoardsApp() {
        openURL(oralBoardsAppStoreURL)
    }
}

enum AnswerVerdict: String {
    case stillCorrect = "STILL_CORRECT"
    case outdated = "OUTDATED"
    case ambiguous = "AMBIGUOUS"
    case unknown = "UNKNOWN"
}

enum CritiqueVerdict: String {
    case current = "CURRENT"
    case partiallyOutdated = "PARTIALLY_OUTDATED"
    case outdated = "OUTDATED"
    case unknown = "UNKNOWN"
}

