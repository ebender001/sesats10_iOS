//
//  QuestionDetailView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/18/25.
//

import SwiftUI
import SwiftData
import AVKit

struct QuestionDetailView: View {
    let detail: BundledQuestionDetail
    @Query private var questionStates: [Question]
    @State private var expandedMediaID: String?
    @State private var showConfirmation = false
    @State private var selectedDistractor = ""
    @State private var showCritique = false
    @State private var showCritiqueToolbarItem = false
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
        questionDetail
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
                    .glassCardStyle()

                questionMediaCards

                // Answer choices
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select best answer")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)

                    ForEach(Array(distractors.enumerated()), id: \.offset) { index, distractor in
                        let optionLetter = letters[index]
                        let isSelectedAnswer = selectedAnswer.lowercased() == optionLetter.lowercased()
                        let selectedAnswerIsCorrect = selectedAnswer.lowercased() == detail.correctAnswer.lowercased()

                        Button {
                            guard !hasAnswered else { return }
                            let letters = distractors.letterIndices()
                            let idx = distractors.firstIndex(of: distractor) ?? index
                            selectedDistractor = letters[idx]
                            showConfirmation.toggle()
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(optionLetter).")
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text(distractor)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if hasAnswered && isSelectedAnswer {
                                    AnswerSelectionBadge(isCorrect: selectedAnswerIsCorrect)
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .glassEffect(.regular, in: .rect(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                            .opacity(hasAnswered && !isSelectedAnswer ? 0.6 : 1)
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
                    .glassEffect(.regular, in: .rect(cornerRadius: 16))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
                    .id(correctAnswerScrollID)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
            }
            .onChange(of: selectedAnswer) { _, newValue in
                let shouldShowCritiqueButton = !newValue.isEmpty && !detail.critique.isEmpty
                withAnimation(.snappy(duration: 0.25)) {
                    showCritiqueToolbarItem = shouldShowCritiqueButton
                }

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
        .toolbarBackground(.hidden, for: .navigationBar)
        .containerBackground(for: .navigation) {
            Theme.screenBackground(for: detail.section)
        }
        .tint(Theme.accent)
        .onAppear {
            showCritiqueToolbarItem = hasAnswered && !detail.critique.isEmpty
        }
        .toolbar {
            if showCritiqueToolbarItem {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Critique") {
                        if let persistedQuestion = questionState {
                            activeQuestionState = persistedQuestion
                            showCritique = true
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
                }
            }
        }
        .animation(.snappy(duration: 0.25), value: showCritiqueToolbarItem)
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

    private var questionMediaItems: [QuestionMediaItem] {
        var imageNumber = 0
        var videoNumber = 0

        return detail.questionMediaAssets.compactMap { asset in
            let lowercasedAsset = asset.lowercased()

            if lowercasedAsset.hasSuffix(".jpg") || lowercasedAsset.hasSuffix(".jpeg") || lowercasedAsset.hasSuffix(".png") {
                imageNumber += 1
                return QuestionMediaItem(
                    id: "image-\(imageNumber)-\(asset)",
                    assetName: asset,
                    title: "Image \(imageNumber)",
                    type: .image
                )
            }

            if lowercasedAsset.hasSuffix(".mp4") {
                videoNumber += 1
                return QuestionMediaItem(
                    id: "video-\(videoNumber)-\(asset)",
                    assetName: asset,
                    title: "Video \(videoNumber)",
                    type: .video
                )
            }

            return nil
        }
    }

    private var questionMediaCards: some View {
        ForEach(questionMediaItems) { item in
            switch item.type {
            case .image:
                CollapsibleMediaImageCard(
                    id: item.id,
                    assetName: item.assetName,
                    title: item.title,
                    isExpanded: expandedMediaID == item.id
                ) {
                    toggleMedia(item.id)
                }
            case .video:
                CollapsibleMediaVideoCard(
                    id: item.id,
                    assetName: item.assetName,
                    title: item.title,
                    isExpanded: expandedMediaID == item.id
                ) {
                    toggleMedia(item.id)
                }
            }
        }
    }

    private func toggleMedia(_ id: String) {
        withAnimation(.snappy) {
            expandedMediaID = expandedMediaID == id ? nil : id
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

struct QuestionMediaItem: Identifiable {
    enum MediaKind {
        case image
        case video
    }

    let id: String
    let assetName: String
    let title: String
    let type: MediaKind
}

struct CollapsibleMediaHeader: View {
    let title: String
    let systemImage: String
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(Theme.accent)
                    .frame(width: 24)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer(minLength: 0)

                Image(systemName: "chevron.down")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct CollapsibleMediaImageCard: View {
    let id: String
    let assetName: String
    let title: String
    let isExpanded: Bool
    let toggle: () -> Void

    private var uiImage: UIImage? {
        guard let path = Bundle.main.path(forResource: assetName, ofType: nil) else { return nil }
        return UIImage(contentsOfFile: path)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CollapsibleMediaHeader(
                title: title,
                systemImage: "photo",
                isExpanded: isExpanded,
                action: toggle
            )

            if isExpanded {
                if let uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
                } else {
                    ContentUnavailableView(
                        "Image Unavailable",
                        systemImage: "photo",
                        description: Text(assetName)
                    )
                    .frame(maxWidth: .infinity, minHeight: 160)
                    .transition(.opacity)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCardStyle()
    }
}

struct CollapsibleMediaVideoCard: View {
    let id: String
    let assetName: String
    let title: String
    let isExpanded: Bool
    let toggle: () -> Void

    @State private var player: AVPlayer?

    private var url: URL? {
        Bundle.main.url(forResource: assetName, withExtension: nil)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CollapsibleMediaHeader(
                title: title,
                systemImage: "play.rectangle",
                isExpanded: isExpanded,
                action: toggle
            )

            if isExpanded {
                if url != nil {
                    VideoPlayer(player: player)
                        .frame(minHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .onAppear {
                            startPlayback()
                        }
                        .onDisappear {
                            stopPlayback()
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
                } else {
                    ContentUnavailableView(
                        "Video Unavailable",
                        systemImage: "video",
                        description: Text(assetName)
                    )
                    .frame(maxWidth: .infinity, minHeight: 160)
                    .transition(.opacity)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCardStyle()
        .onChange(of: isExpanded) { _, expanded in
            if expanded {
                startPlayback()
            } else {
                stopPlayback()
            }
        }
    }

    private func startPlayback() {
        guard let url else { return }

        if player == nil {
            player = AVPlayer(url: url)
        }

        player?.play()
    }

    private func stopPlayback() {
        player?.pause()
        player = nil
    }
}

private struct AnswerSelectionBadge: View {
    let isCorrect: Bool

    var body: some View {
        Image(systemName: isCorrect ? "checkmark" : "xmark")
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 24, height: 24)
            .background(isCorrect ? Theme.success : Theme.error, in: Circle())
            .accessibilityLabel(isCorrect ? "Correct answer" : "Incorrect answer")
    }
}

//#Preview {
//    QuestionDetailView()
//}
