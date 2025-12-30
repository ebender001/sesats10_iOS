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

struct AIView: View {
    @Environment(\.dismiss) var dismiss
    
    let question: Question
    @State private var responseText = ""
    @StateObject private var viewModel = AIViewModel()
    
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
                        Button("Dismiss") {
                            dismiss()
                        }
                    }
                }
        }
//        .task {
//            generateAI()
//        }
    }
    
    private func generateAI() {
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        let model = ai.generativeModel(modelName: "gemini-2.5-flash")
        
        let prompt = "Please give the most up to date information regarding the \(question.questionText). Explain why the correct answer \(question.correctAnswer). \(correctAnswer) is correct. Explain why each \(incorrectOptions) is incorrect. Explain if the \(question.critique) is still valid."
        
        viewModel.generate(prompt: prompt, model: model)
    }
}
