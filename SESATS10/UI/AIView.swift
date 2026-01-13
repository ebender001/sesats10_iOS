//
//  AIView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/22/25.
//

import SwiftUI
import FirebaseAILogic
import RevenueCat
import RevenueCatUI
import SwiftData

struct AIView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    let question: Question
    @StateObject private var viewModel = AIViewModel()
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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
                                Text("Fetching response (may take 30 seconds or more)...")
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
                
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(alertMessage))
                }
            }
            .onAppear {
                generateAI()
            }
            .onDisappear {
                viewModel.cancel()
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
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            saveAIUpdate()
                        } label: {
                            Text("Save")
                        }
                        .disabled(viewModel.responseText.isEmpty)
                    }
                }
        }
    }
    
    private func saveAIUpdate() {
        guard !question.id.isEmpty, !viewModel.responseText.isEmpty else { return }
        do {
            let aiUpdate = AIUpdate(id: question.id, text: viewModel.responseText, date: .now)
            modelContext.insert(aiUpdate)
            try modelContext.save()
            alertMessage = "AI Update Saved"
            showAlert.toggle()
        } catch {
            print("Could not save \(question.id): \(error)")
            alertMessage = "Failed to save AI Update: \(error.localizedDescription)"
            showAlert.toggle()
        }
    }
    
    private func generateAI() {
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        let model = ai.generativeModel(modelName: "gemini-2.5-flash")
        
        let prompt = "Please give the most up to date information regarding the \(question.questionText). Explain why the correct answer \(question.correctAnswer). \(correctAnswer) is correct. Explain why each \(incorrectOptions) is incorrect. Explain if the \(question.critique) is still valid."
        
        viewModel.generate(prompt: prompt, model: model)
    }
}
