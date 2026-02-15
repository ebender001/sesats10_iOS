//
//  ScorecardRowView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/18/25.
//

import SwiftUI
import SwiftData

struct ScorecardRowView: View {
    let scorecard: Scorecard
    @Query var questions: [Question]
    
    var correctAnswersCount: Int {
        questions.filter { $0.answeredCorrectly }.count
    }
    
    var incorrectAnswersCount: Int {
        questions.filter { $0.answeredIncorrectly }.count
    }
    
    private var count: Int {
        scorecard.title == "Correct" ? correctAnswersCount : incorrectAnswersCount
    }

    private var iconTint: Color {
        switch scorecard.title {
        case "Correct":
            return Theme.success
        case "Incorrect":
            return Theme.error
        default:
            return Theme.accent
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconTint.opacity(0.12))

                Image(scorecard.imageString)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .foregroundStyle(iconTint)
            }
            .frame(width: 44, height: 44)

            Text(scorecard.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer(minLength: 0)

            Text("\(count) question\(count == 1 ? "" : "s")")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
        .cardStyle()
        .contentShape(Rectangle())
    }
}

#Preview {
    ScorecardRowView(scorecard: Scorecard.allScorecards[0])
}
