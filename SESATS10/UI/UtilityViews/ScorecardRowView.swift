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
    
    var body: some View {
        HStack {
            Image(scorecard.imageString)
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.horizontal)
            Text(scorecard.title)
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
            let count = (scorecard.title == "Correct" ? correctAnswersCount : incorrectAnswersCount)
            Text("\(count) question\(count == 1 ? "" : "s")")
        }
    }
}

#Preview {
    ScorecardRowView(scorecard: Scorecard.allScorecards[0])
}
