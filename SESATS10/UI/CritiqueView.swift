//
//  CritiqueView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/20/25.
//

import SwiftUI

struct CritiqueView: View {
    let question: Question
    
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
        Form{
            Section(header: Text("Question")) {
                Text(question.questionText)
            }
            Section(header: Text("Correct Answer: \(question.correctAnswer.uppercased())")) {
                Text(displayCorrectAnswer())
            }
            Section(header: Text("Critique")) {
                Text(question.critique)
            }
        }
        .navigationTitle("Critique")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }
    
    func displayCorrectAnswer() -> String {
        let correctAnswer = question.correctAnswer.lowercased()
        
        switch correctAnswer {
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
}

//#Preview {
//    CritiqueView()
//}
