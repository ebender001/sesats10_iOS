//
//  CritiqueView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/20/25.
//

import SwiftUI
import TipKit

struct CritiqueView: View {

    let question: Question
    let aiTip = AITip()

    @EnvironmentObject var entitlements: EntitlementManager

    @State private var showAIView = false
    @State private var showPaywall = false

    var body: some View {
        Form {
            Section {
                Button {
                    aiTip.invalidate(reason: .actionPerformed)

                    if entitlements.hasAIAccess {
                        showAIView = true
                    } else {
                        showPaywall = true
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(Theme.accent)

                        Text("AI Update")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .popoverTip(aiTip, arrowEdge: .top)
            }

            Section("Question") {
                Text(question.questionText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Theme.divider.opacity(0.7), lineWidth: 1)
                    )
                    .listRowBackground(Color.clear)
            }

            Section("Correct Answer: \(question.correctAnswer.uppercased())") {
                Text(displayCorrectAnswer())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Theme.divider.opacity(0.7), lineWidth: 1)
                    )
                    .listRowBackground(Color.clear)
            }

            Section("Critique") {
                Text(question.critique)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Theme.divider.opacity(0.7), lineWidth: 1)
                    )
                    .listRowBackground(Color.clear)
            }
        }
        // Theme (Form-friendly)
        .scrollContentBackground(.hidden)
        .background(Theme.bg.ignoresSafeArea())
        .tint(Theme.accent)
        .navigationTitle("Critique")
        .navigationBarTitleDisplayMode(.inline)
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
        case "a": return question.distractorA
        case "b": return question.distractorB
        case "c": return question.distractorC
        case "d": return question.distractorD
        case "e": return question.distractorE
        default:  return ""
        }
    }
}
