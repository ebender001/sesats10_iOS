//
//  CritiqueView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/20/25.
//

import SwiftUI
import TipKit
import StoreKit

struct CritiqueView: View {
    
    let question: Question
    let aiTip = AITip()
    @EnvironmentObject var entitlements: EntitlementManager
    
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
    
    @State private var showAIView = false
    @State private var showPaywall = false
        
    var body: some View {
        Form{
            Section {
                TipView(aiTip)
            }
            Section(header: Text("Question")) {
                Text(question.questionText)
            }

            Section(header: Text("Correct Answer: \(question.correctAnswer.uppercased())")) {
                Text(displayCorrectAnswer())
            }

            Section(header: Text("Critique")) {
                Text(question.critique)
                    .textSelection(.enabled)
            }
        }
        .navigationTitle("Critique")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if entitlements.hasAIAccess {
                        showAIView = true
                    } else {
                        showPaywall = true
                    }
                } label: {
                    VStack {
                        Image(systemName: "apple.intelligence")
                    }
                }
            }
        }
        .sheet(isPresented: $showPaywall, onDismiss: {
            Task {
                await entitlements.refresh()
                if entitlements.hasAIAccess {
                    showAIView = true
                }
            }
        }) {
            PaywallView(productIDs: [
                "com.cvoffice.sesats10.month",
                "com.cvoffice.sesats10.annual"
            ])
            .environmentObject(entitlements)
        }
        .sheet(isPresented: $showAIView) {
            AIView(question: question)
        }
        
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
