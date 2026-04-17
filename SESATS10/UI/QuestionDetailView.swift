//
//  QuestionDetailView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/18/25.
//

import SwiftUI
import SwiftData

struct QuestionDetailView: View {
    let detail: BundledQuestionDetail
    @Query private var questionStates: [Question]
    @State private var showMediaList = false
    @State private var showConfirmation = false
    @State private var selectedDistractor = ""
    @State private var showCritique = false
    @State private var showAnswerStatus = false
    @State private var activeQuestionState: Question?
    
    private let correctAnswerScrollID = "correctAnswerCard"
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    init(detail: BundledQuestionDetail) {
        self.detail = detail
        let questionID = detail.id
        _questionStates = Query(
            filter: #Predicate<Question> { question in
                question.id == questionID
            }
        )
    }
    
    var distractors: [String] {
        detail.distractors
    }

    private var questionState: Question? {
        activeQuestionState ?? questionStates.first
    }

    private var selectedAnswer: String {
        questionState?.selectedAnswer ?? ""
    }

    private var answeredCorrectly: Bool {
        questionState?.answeredCorrectly ?? false
    }

    private var hasAnswered: Bool {
        !selectedAnswer.isEmpty
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
            MediaListView(detail: detail)
        }
    }
    
    var questionDetail: some View {
        ScrollViewReader { proxy in
            ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                // Question stem
                Text(detail.questionText)
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
                            guard !hasAnswered else { return }
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
                            .opacity(hasAnswered ? 0.6 : 1)
                        }
                        .buttonStyle(.plain)
                        .disabled(hasAnswered)
                    }
                }
                .cardStyle()
                
                // Correct Answer Section (shown after answering)
                if hasAnswered {
                    let correctAnswerIndex = letters.firstIndex(of: detail.correctAnswer.uppercased()) ?? 0
                    let correctAnswerText = "\(detail.correctAnswer.uppercased()). \(distractors[correctAnswerIndex])"

                    HStack(spacing: 0) {
                        // Accent bar
                        Rectangle()
                            .fill(answeredCorrectly ? Theme.success : Theme.error)
                            .frame(width: 6)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Correct Answer")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textSecondary)

                            Text(correctAnswerText)
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
            .onChange(of: selectedAnswer) { _, newValue in
                guard !newValue.isEmpty else { return }
                // Ensure layout has updated before scrolling.
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(correctAnswerScrollID, anchor: .top)
                    }
                }
            }
        }
        .navigationTitle(detail.section)
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.accent)
        .toolbar {
            if !detail.questionMovieAssets.isEmpty || !detail.questionImageAssets.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Media") {
                        showMediaList.toggle()
                    }
                }
            }
        }
        .alert("\(answeredCorrectly ? "Correct" : "Incorrect") Answer",
               isPresented: $showAnswerStatus) {
            Button("OK", role: .close) {
                dismiss()
            }
            if !detail.critique.isEmpty, let persistedQuestion = questionState {
                Button("View Critique", role: .confirm) {
                    activeQuestionState = persistedQuestion
                    showCritique.toggle()
                }
            }
        } message: {
            let answerStatus = answeredCorrectly ?
            "correctly. You can view the critique for more detail and generate AI updates there, or just keep going." :
            "incorrectly. View critique for the correct answer and to generate AI updates."
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
        .navigationDestination(isPresented: Binding(
            get: { showCritique && questionState != nil },
            set: { showCritique = $0 }
        )) {
            if let persistedQuestion = questionState {
                CritiqueView(question: persistedQuestion)
            }
        }
    }
    
    func updateQuestion() {
        let persistedQuestion = questionState ?? Question(
            abstract1Title: detail.abstract1Title,
            abstract2Title: detail.abstract2Title,
            abstract3Title: detail.abstract3Title,
            abstract4Title: detail.abstract4Title,
            answeredCorrectly: false,
            answeredIncorrectly: false,
            correctAnswer: detail.correctAnswer,
            critique: detail.critique,
            critiqueMedia: detail.critiqueMedia,
            distractorA: detail.distractorA,
            distractorB: detail.distractorB,
            distractorC: detail.distractorC,
            distractorD: detail.distractorD,
            distractorE: detail.distractorE,
            examId: detail.examId,
            finalQuestionNumber: detail.finalQuestionNumber,
            id: detail.id,
            pubMedRefId1: detail.pubMedRefId1,
            pubMedRefId2: detail.pubMedRefId2,
            pubMedRefId3: detail.pubMedRefId3,
            pubMedRefId4: detail.pubMedRefId4,
            questionText: detail.questionText,
            section: detail.section,
            selectedAnswer: "",
            stem: detail.stem,
            title: detail.title
        )

        if questionState == nil {
            modelContext.insert(persistedQuestion)
        }

        persistedQuestion.selectedAnswer = selectedDistractor
        if selectedDistractor == detail.correctAnswer.lowercased() {
            persistedQuestion.answeredCorrectly = true
            persistedQuestion.answeredIncorrectly = false
        } else {
            persistedQuestion.answeredCorrectly = false
            persistedQuestion.answeredIncorrectly = true
        }
        do {
            try modelContext.save()
            activeQuestionState = persistedQuestion
        } catch {
            print("Failed to update question state: \(error.localizedDescription)")
        }
        showAnswerStatus.toggle()
    }
}

//#Preview {
//    QuestionDetailView()
//}
