//
//  AIView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/22/25.
//

import SwiftUI
import SwiftData

struct AIView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    let question: Question
    @StateObject private var viewModel = AIViewModel()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var aiTask: Task<Void, Never>?
    
    var correctAnswer: String {
        switch question.correctAnswer.lowercased() {
        case "a":
            return question.distractorA
        case "b":
            return question.distractorB
        case "c":
            return question.distractorC
        case "d":
            return question.distractorD
        case "e":
            return question.distractorE
        default:
            return ""
        }
    }
    
    var incorrectOptions: [String] {
        let letters = ["a", "b", "c", "d", "e"]
        let answers = [
            question.distractorA,
            question.distractorB,
            question.distractorC,
            question.distractorD,
            question.distractorE
        ]

        return zip(letters, answers)
            .filter { $0.0 != question.correctAnswer.lowercased() }
            .map { $0.1 }
    }
    
    var correctOption: [String] {
        let letters = ["a", "b", "c", "d", "e"]
        let answers = [
            question.distractorA,
            question.distractorB,
            question.distractorC,
            question.distractorD,
            question.distractorE
        ]

        return zip(letters, answers)
            .filter { $0.0 == question.correctAnswer.lowercased() }
            .map { $0.1 }
    }
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Question")) {
                        Text(question.questionText)
                        
                    }
                    Section(header: Text("A.I. Response")) {
                        if viewModel.responseText.isEmpty {
                            HStack {
                                Text("Generating AI analysis… This educational content may not fully reflect current guidelines and should be independently verified.")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                ProgressView()
                            }
                            .padding()
                            
                        } else {
                            Text(viewModel.responseText)
                        }
                    }
                }
                .alert("AI Update",
                       isPresented: $showAlert,
                       actions: {
                    Button("Dismiss") {
                        dismiss()
                    }
                }, message: {
                    Text(alertMessage)
                })
            }
            .onAppear {
                aiTask?.cancel()
                aiTask = Task { await generateAI() }
            }
            .onDisappear {
                aiTask?.cancel()
            }
            .navigationTitle("Update")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
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
        guard !question.id.isEmpty, !viewModel.responseText.isEmpty else { return }

        do {
            // Use optional to be compatible whether AIUpdate.id is String or String?
            let qid: String? = question.id

            // Fetch without a predicate to avoid SwiftData predicate macro errors
            let allUpdates = try modelContext.fetch(FetchDescriptor<AIUpdate>())

            if let existing = allUpdates.first(where: { $0.id == qid }) {
                existing.text = viewModel.responseText
                existing.date = .now
            } else {
                let aiUpdate = AIUpdate(id: question.id, text: viewModel.responseText, date: .now)
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
    
    private func generateAI() async {
        guard
            let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path),
            let apiKey = dict["OPENAI_API_KEY"] as? String,
            !apiKey.isEmpty
        else {
            await MainActor.run {
                viewModel.responseText = "Missing OPENAI_API_KEY in Secrets.plist"
            }
            return
        }
        
        let prompt = """
        You are a cardiothoracic surgery board examiner.

        This is a legacy multiple-choice question that may be outdated. Your job is to VALIDATE the keyed answer against current ACC/AHA and STS guidelines and contemporary cardiothoracic surgical practice.

        Question:
        \(question.questionText)

        Answer choices (A–E):
        A. \(question.distractorA)
        B. \(question.distractorB)
        C. \(question.distractorC)
        D. \(question.distractorD)
        E. \(question.distractorE)

        Keyed (legacy) correct answer: \(question.correctAnswer.uppercased()). \(correctAnswer)

        Tasks:
        1) Determine whether the keyed answer is still correct under current guidelines.
        2) Begin your response with exactly one line in this format:
           VERDICT: STILL_CORRECT
           OR
           VERDICT: OUTDATED
           OR
           VERDICT: AMBIGUOUS
        3) If STILL_CORRECT: explain why it remains correct and briefly explain why each other option (A–E) is incorrect.
        4) If OUTDATED: state the best current answer letter (A–E) and explain why the keyed answer is no longer correct; then briefly explain why the remaining options are incorrect.
        5) If NONE of the listed options reflects current best practice, clearly state:
           NO_OPTION_CURRENTLY_CORRECT
           Then explain what the correct modern management would be and why none of the choices are appropriate.
        6) If AMBIGUOUS: list the specific missing clinical data (1–3 items maximum) that would change the answer, and for each item state which letter (A–E) would become correct if that condition were met.

        Constraints:
        - Be guideline-anchored and conservative.
        - Do not recommend intervention unless formal guideline criteria are met.
        - Do not invent clinical data not provided.
        - When referring to an answer choice, always use the letter A–E exactly as listed above.
        - Keep the explanation concise, structured, and board-style.
        """

        do {
            let text = try await callOpenAI(prompt: prompt, apiKey: apiKey)
            await MainActor.run {
                viewModel.responseText = text
                // Auto-save when the response is ready
                saveAIUpdate(showConfirmation: false)
            }
        } catch {
            await MainActor.run {
                viewModel.responseText = "OpenAI request failed: \(error.localizedDescription)"
            }
        }
    }

    private func callOpenAI(prompt: String, apiKey: String) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/responses")!

        let body: [String: Any] = [
            "model": "gpt-4.1-mini",
            "max_output_tokens": 1200,
            "input": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "input_text",
                            "text": prompt
                        ]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            let raw = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "OpenAI", code: 0, userInfo: [NSLocalizedDescriptionKey: raw])
        }

        // Parse response
        guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return String(data: data, encoding: .utf8) ?? ""
        }

        // Preferred convenience field (if present)
        if let outputText = obj["output_text"] as? String,
           !outputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return outputText
        }

        // Fallback: walk `output[] -> content[]` and collect `output_text.text`
        if let output = obj["output"] as? [[String: Any]] {
            var parts: [String] = []

            for item in output {
                guard let content = item["content"] as? [[String: Any]] else { continue }
                for c in content {
                    if let type = c["type"] as? String, type == "output_text",
                       let text = c["text"] as? String,
                       !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        parts.append(text)
                    }
                }
            }

            if !parts.isEmpty {
                return parts.joined(separator: "\n")
            }
        }

        // Last resort: return raw JSON for debugging
        return String(data: data, encoding: .utf8) ?? ""
    }
}
