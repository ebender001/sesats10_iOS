//
//  AIView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/22/25.
//

import SwiftUI
import SwiftData
import ParseSwift

struct AIView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let question: Question

    @State private var responseText = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var aiTask: Task<Void, Never>?
    @State private var loadingWarningTask: Task<Void, Never>?
    @State private var isLoading = false
    @State private var showDelayedLoadingWarning = false

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    AISectionHeader(title: "Question")
                        .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)

                    Section {
                        Text(question.questionText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassCardStyle()
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                            .listRowBackground(Color.clear)
                    }

                    AISectionHeader(title: "A.I. Response")
                        .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)

                    Section {
                        if isLoading {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Generating AI analysis... This educational content may not fully reflect current guidelines and should be independently verified.")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    ProgressView()
                                }

                                if showDelayedLoadingWarning {
                                    Text("Patience, please. AI updates can take longer when an advanced AI model is being used.")
                                        .font(.subheadline)
                                        .foregroundStyle(.yellow)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassCardStyle()
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                            .listRowBackground(Color.clear)
                            .transition(.opacity)
                        }

                        if responseText.isEmpty {
                            if !isLoading {
                                Text("No AI response yet.")
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .glassCardStyle()
                                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                    .listRowBackground(Color.clear)
                            }
                        } else {
                            markdownText(formattedResponseText(responseText))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .glassCardStyle()
                                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                .listRowBackground(Color.clear)

                            CardioThoraxiaPromoCard()
                                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                .listRowBackground(Color.clear)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: isLoading)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .alert(
                    "AI Update",
                    isPresented: $showAlert,
                    actions: {
                        Button("Dismiss") {
                            dismiss()
                        }
                    },
                    message: {
                        Text(alertMessage)
                    }
                )
            }
            .onAppear {
                aiTask?.cancel()
                aiTask = Task { await loadOrGenerateAI() }
            }
            .onDisappear {
                aiTask?.cancel()
                loadingWarningTask?.cancel()
            }
            .navigationTitle("Update")
            .iOSNavigationBarTitleDisplayMode(.large)
            .hiddenNavigationBarBackground()
            .platformNavigationBackground {
                Theme.aiScreenBackground
            }
            .toolbar {
                ToolbarItem(placement: .platformTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }

    private func saveAIUpdate(showConfirmation: Bool = false) {
        let questionID = question.id.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedResponse = responseText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !questionID.isEmpty, !cleanedResponse.isEmpty else { return }

        do {
            if let existing = fetchCachedAIUpdate() {
                existing.text = cleanedResponse
                existing.date = .now
            } else {
                let aiUpdate = AIUpdate(id: questionID, text: cleanedResponse, date: .now)
                modelContext.insert(aiUpdate)
            }

            try modelContext.save()

            if showConfirmation {
                alertMessage = "AI Update Saved"
                showAlert = true
            }
        } catch {
            print("Could not save \(question.id): \(error)")
            alertMessage = "Failed to save AI Update: \(error.localizedDescription)"
            showAlert = true
        }
    }

    @MainActor
    private func loadOrGenerateAI() async {
        if let cachedUpdate = fetchCachedAIUpdate(),
           !cachedUpdate.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            responseText = cachedUpdate.text
            isLoading = false
            return
        }

        await generateAI()
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

    private func generateAI() async {
        let questionID = question.id.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("AI DEBUG raw id=[\(question.id)]")
        print("AI DEBUG trimmed id=[\(questionID)]")

        guard !questionID.isEmpty else {
            await MainActor.run {
                responseText = "Question is missing an ID."
                isLoading = false
            }
            return
        }

        let cachedText = await MainActor.run {
            fetchCachedAIUpdate()?.text.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let cachedText, !cachedText.isEmpty {
            await MainActor.run {
                responseText = cachedText
                isLoading = false
            }
            return
        }

        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoading = true
            }
            showDelayedLoadingWarning = false
            responseText = ""
        }

        loadingWarningTask?.cancel()
        loadingWarningTask = Task {
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                if isLoading {
                    showDelayedLoadingWarning = true
                }
            }
        }

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

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoading = false
                }
                loadingWarningTask?.cancel()
                showDelayedLoadingWarning = false

                let cleanText = result.text.trimmingCharacters(in: .whitespacesAndNewlines)
                responseText = cleanText

                if cleanText.isEmpty {
                    alertMessage = "AI returned an empty response."
                    showAlert = true
                } else {
                    saveAIUpdate(showConfirmation: false)
                }
            }
        } catch {
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoading = false
                }
                loadingWarningTask?.cancel()
                showDelayedLoadingWarning = false
                responseText = "AI request failed: \(error.localizedDescription)"
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

    private func formattedResponseText(_ text: String) -> String {
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
}

struct AISectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.textSecondary)
            .textCase(nil)
            .padding(.horizontal, 16)
            .padding(.vertical, 7)
            .glassEffect(.regular, in: .capsule)
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.32), lineWidth: 1)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
