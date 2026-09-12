//
//  AIDetailView.swift
//  SESATS10
//
//  Created by Edward Bender on 1/13/26.
//

import SwiftUI

struct AIDetailView: View {
    let question: Question
    let aiUpdate: AIUpdate
    
    @State private var isCritiqueExpanded = false
    @State private var isAIUpdateExpanded = true
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                GlassDisclosureCard(
                    title: "Critique",
                    isExpanded: $isCritiqueExpanded
                ) {
                    Text(question.critique)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                GlassDisclosureCard(
                    title: "AI Update",
                    isExpanded: $isAIUpdateExpanded
                ) {
                    markdownText(formattedResponseText(aiUpdate.text))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .navigationTitle("AI Update")
        .iOSNavigationBarTitleDisplayMode(.inline)
        .hiddenNavigationBarBackground()
        .platformNavigationBackground {
            Theme.aiScreenBackground
        }
    }

    @ViewBuilder
    private func markdownText(_ text: String) -> some View {
        if let attributed = try? AttributedString(
            markdown: text,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        ) {
            Text(attributed)
        } else {
            Text(text)
        }
    }

    private func formattedResponseText(_ text: String) -> String {
        text
            .components(separatedBy: .newlines)
            .map { line in
                guard let colonIndex = line.firstIndex(of: ":") else { return line }

                let key = String(line[..<colonIndex])
                let valueStart = line.index(after: colonIndex)
                let rawValue = String(line[valueStart...]).trimmingCharacters(in: .whitespaces)

                guard key == "VERDICT_ANSWER" || key == "VERDICT_CRITIQUE" else {
                    return line
                }

                let displayKey = key.replacingOccurrences(of: "_", with: " ")
                let displayValue = rawValue.replacingOccurrences(of: "_", with: " ")
                return "\(displayKey): **\(displayValue)**"
            }
            .joined(separator: "\n")
    }
}

private struct GlassDisclosureCard<Content: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                withAnimation(.snappy) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                content
                    .font(.body)
                    .foregroundStyle(.primary)
                    .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCardStyle()
    }
}

//#Preview {
//    AIDetailView()
//}
