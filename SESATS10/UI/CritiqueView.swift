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
    private let oralBoardsAppStoreURL = URL(string: "https://apps.apple.com/us/app/oral-boards-ai/id6763632588")!

    @EnvironmentObject var entitlements: EntitlementManager
    @Environment(\.openURL) private var openURL

    @State private var showAIView = false
    @State private var showPaywall = false
    @State private var showOralBoardsPromo = false
    @State private var hasAnimatedOralBoardsPromo = false

    private var shouldShowOralBoardsPromo: Bool {
        !question.selectedAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || question.answeredCorrectly
            || question.answeredIncorrectly
    }

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
                    .glassCardStyle()
                    .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                .listRowBackground(Color.clear)
                .popoverTip(aiTip, arrowEdge: .top)
            }

            CritiqueSectionHeader(title: "Question")
                .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)

            Section {
                Text(question.questionText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCardStyle()
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowBackground(Color.clear)
            }

            CritiqueSectionHeader(title: "Correct Answer: \(question.correctAnswer.uppercased())")
                .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)

            Section {
                Text(displayCorrectAnswer())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCardStyle()
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowBackground(Color.clear)
            }

            if shouldShowOralBoardsPromo && showOralBoardsPromo {
                OralBoardsPromoCard(action: openOralBoardsApp)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowBackground(Color.clear)
                    .transition(.opacity.combined(with: .offset(y: 10)))
            }

            CritiqueSectionHeader(title: "Critique")
                .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)

            Section {
                Text(question.critique)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCardStyle()
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowBackground(Color.clear)
            }
        }
        // Theme (Form-friendly)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .tint(Theme.accent)
        .navigationTitle("Critique")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .containerBackground(for: .navigation) {
            Theme.screenBackground(for: question.section)
        }
        .onAppear {
            guard shouldShowOralBoardsPromo else { return }

            if hasAnimatedOralBoardsPromo {
                showOralBoardsPromo = true
                return
            }

            hasAnimatedOralBoardsPromo = true

            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.25)) {
                    showOralBoardsPromo = true
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
        case "a": return question.distractorA
        case "b": return question.distractorB
        case "c": return question.distractorC
        case "d": return question.distractorD
        case "e": return question.distractorE
        default:  return ""
        }
    }

    private func openOralBoardsApp() {
        openURL(oralBoardsAppStoreURL)
    }
}

private struct CritiqueSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.textSecondary)
            .textCase(nil)
            .padding(.horizontal, 16)
            .padding(.vertical, 7)
            .glassEffect(.regular, in: .capsule)
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.32), lineWidth: 1)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
