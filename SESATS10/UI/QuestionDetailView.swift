//
//  QuestionDetailView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/18/25.
//

import SwiftUI
import SwiftData

struct QuestionDetailView: View {
    let question: Question
    @State private var showMediaList = false
    @State private var showConfirmation = false
    @State private var selectedDistractor = ""
    @State private var showCritique = false
    @State private var showAnswerStatus = false
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var distractors: [String] {
        [
            question.distractorA,
            question.distractorB,
            question.distractorC,
            question.distractorD,
            question.distractorE
        ].filter { !$0.isEmpty }
    }
    
    var letters: [String] {
        //array of a, b, c, etc
        Array(0..<distractors.count).map {
            String(UnicodeScalar(65 + $0)!)
        }
    }
    
    var body: some View {
        questionDetail
            .navigationDestination(isPresented: $showMediaList) {
                MediaListView(question: question)
            }
    }
    
    var questionDetail: some View {
        VStack(spacing: 0) {
            ScrollView {
                Text(question.questionText)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 250)
            
            List {
                Section(header: Text("Select best answer")) {
                    ForEach(Array(distractors.enumerated()), id: \.offset) { index, distractor in
                        
                        Text("\(letters[index].uppercased()).  \(distractor)")
                            .fontWeight(.bold)
                            .onTapGesture {
                                //select answer here
                                let letters = distractors.letterIndices()
                                let index = distractors.firstIndex(of: distractor)!
                                selectedDistractor = letters[index]
                                showConfirmation.toggle()
                                
                            }
                    }
                }
            }
            .disabled(!question.selectedAnswer.isEmpty)
            .opacity(question.selectedAnswer.isEmpty ? 1 : 0.6)
        }
        .padding()
        .navigationTitle(question.section)
        .toolbar {
            if !question.questionMovieAssets.isEmpty || !question.questionImageAssets.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Media") {
                        showMediaList.toggle()
                    }
                }
                
            }
        }
        .alert("\(question.answeredCorrectly ? "Correct" : "Incorrect") Answer",
               isPresented: $showAnswerStatus) {
            Button("OK", role: .close) {
                dismiss()
            }
            if !question.critique.isEmpty {
                Button("View Critique", role: .confirm) {
                    showCritique.toggle()
                }
            }
        } message: {
            let answerStatus = question.answeredCorrectly ?
            "correctly. Congratulations! You can view the critique or just keep going." :
            "incorrectly. View critique for correct answer"
            Text("You answered \(answerStatus).")
        }
        .alert("Confirm Answer", isPresented: $showConfirmation) {
            Button("Yes", role: .destructive) {
                updateQuestion()
            }
            Button("No", role: .cancel) {}
        } message: {
            Text("You chose option \(selectedDistractor.uppercased()). Is this your final answer?")
        }
        .navigationDestination(isPresented: $showCritique) {
            CritiqueView(question: question)
        }
        

    }
    
    func updateQuestion() {
        question.selectedAnswer = selectedDistractor
        if selectedDistractor == question.correctAnswer.lowercased() {
            question.answeredCorrectly = true
            question.answeredIncorrectly = false
            print("Answered correctly")
        } else {
            question.answeredCorrectly = false
            question.answeredIncorrectly = true
            print("Answered wrong")
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to update question: \(error.localizedDescription)")
        }
        showAnswerStatus.toggle()
    }
}

//#Preview {
//    QuestionDetailView()
//}
