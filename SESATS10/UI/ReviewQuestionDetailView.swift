//
//  ReviewQuestionDetailView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/21/25.
//

import SwiftUI
import SwiftData

struct ReviewQuestionDetailView: View {
    let question: Question
    @Query var aiUpdates: [AIUpdate]
    @State private var expandedMediaID: String?
    @State private var showCritique = false
    @State private var showAiUpdate = false
    
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
    
    func aiUpdate(for question: Question) -> AIUpdate? {
        aiUpdates.filter( { question.id == $0.id }).first
    }

    var hasMedia: Bool {
        !question.questionMovieAssets.isEmpty || !question.questionImageAssets.isEmpty
    }

    var showsCritiqueToolbarAction: Bool {
        !question.critique.isEmpty && aiUpdate(for: question) == nil
    }
    
    var body: some View {
        questionDetail
        .navigationDestination(isPresented: $showCritique) {
            CritiqueView(question: question)
        }
        .navigationDestination(isPresented: $showAiUpdate) {
            AIDetailView(question: question, aiUpdate: aiUpdate(for: question) ??
                         AIUpdate(id: question.id, text: "AI update failed.", date: .now))
        }
    }
    
    var questionDetail: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                if aiUpdate(for: question) != nil {
                    Button {
                        showAiUpdate.toggle()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(Theme.accent)

                            Text("AI Update and Critique")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassCardStyle()
                        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .buttonStyle(.plain)
                }

                // Question stem
                Text(question.questionText)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCardStyle()

                reviewMediaCards

                // Your answer summary
                let answeredCorrectly = question.selectedAnswer.lowercased() == question.correctAnswer.lowercased()
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(answeredCorrectly ? Theme.success : Theme.error)
                        .frame(width: 6)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your answer")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textSecondary)

                        Text(question.selectedAnswer.uppercased())
                            .font(.headline)
                            .foregroundStyle(.primary)
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

                // Options (correct highlighted)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Correct answer is highlighted")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)

                    ForEach(Array(distractors.enumerated()), id: \.offset) { index, distractor in
                        let letter = letters[index]
                        let isCorrect = question.correctAnswer.lowercased() == letter.lowercased()
                        let isSelected = question.selectedAnswer.lowercased() == letter.lowercased()

                        HStack(spacing: 0) {
                            if isCorrect {
                                Rectangle()
                                    .fill(Theme.success)
                                    .frame(width: 6)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 6)
                            }

                            HStack(alignment: .top, spacing: 10) {
                                Text("\(letter).")
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text(distractor)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(answeredCorrectly ? Theme.success : Theme.error)
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .glassEffect(.regular, in: .rect(cornerRadius: 14))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isCorrect ? Theme.success.opacity(0.45) : Color.white.opacity(0.35), lineWidth: 1)
                        )
                    }
                }
                .glassCardStyle()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .navigationTitle(question.section)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .containerBackground(for: .navigation) {
            Theme.screenBackground(for: question.section)
        }
        .tint(Theme.accent)
        .toolbar {
            if showsCritiqueToolbarAction {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Critique") {
                        showCritique.toggle()
                    }
                }
            }
        }
    }

    private var reviewMediaItems: [QuestionMediaItem] {
        var imageNumber = 0
        var videoNumber = 0

        let imageItems = question.questionImageAssets.map { asset in
            imageNumber += 1
            return QuestionMediaItem(
                id: "image-\(imageNumber)-\(asset)",
                assetName: asset,
                title: "Image \(imageNumber)",
                type: .image
            )
        }

        let videoItems = question.questionMovieAssets.map { asset in
            videoNumber += 1
            return QuestionMediaItem(
                id: "video-\(videoNumber)-\(asset)",
                assetName: asset,
                title: "Video \(videoNumber)",
                type: .video
            )
        }

        return imageItems + videoItems
    }

    private var reviewMediaCards: some View {
        ForEach(reviewMediaItems) { item in
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
}

//#Preview {
//    ReviewQuestionDetailView()
//}
