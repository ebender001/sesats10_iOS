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
    
    private let correctAnswerScrollID = "correctAnswerCard"
    
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
        ZStack {
            Theme.bg
                .ignoresSafeArea()

            questionDetail
        }
        .navigationDestination(isPresented: $showMediaList) {
            MediaListView(question: question)
        }
    }
    
    var questionDetail: some View {
        ScrollViewReader { proxy in
            ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                // Question stem
                Text(question.questionText)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()

                // Answer choices
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select best answer")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)

                    ForEach(Array(distractors.enumerated()), id: \.offset) { index, distractor in
                        Button {
                            guard question.selectedAnswer.isEmpty else { return }
                            let letters = distractors.letterIndices()
                            let idx = distractors.firstIndex(of: distractor) ?? index
                            selectedDistractor = letters[idx]
                            showConfirmation.toggle()
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(letters[index]).")
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text(distractor)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Theme.divider.opacity(0.7), lineWidth: 1)
                            )
                            .opacity(question.selectedAnswer.isEmpty ? 1 : 0.6)
                        }
                        .buttonStyle(.plain)
                        .disabled(!question.selectedAnswer.isEmpty)
                    }
                }
                .cardStyle()
                
                // Correct Answer Section (shown after answering)
                if !question.selectedAnswer.isEmpty {
                    HStack(spacing: 0) {
                        // Accent bar
                        Rectangle()
                            .fill(question.answeredCorrectly ? Theme.success : Theme.error)
                            .frame(width: 6)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Correct Answer")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textSecondary)

                            Text(question.correctAnswer.uppercased() + ". " +
                                 distractors[letters.firstIndex(of: question.correctAnswer.uppercased()) ?? 0])
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Theme.divider.opacity(0.6), lineWidth: 1)
                    )
                    .id(correctAnswerScrollID)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
            }
            .onChange(of: question.selectedAnswer) { _, newValue in
                guard !newValue.isEmpty else { return }
                // Ensure layout has updated before scrolling.
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(correctAnswerScrollID, anchor: .top)
                    }
                }
            }
        }
        .navigationTitle(question.section)
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.accent)
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
