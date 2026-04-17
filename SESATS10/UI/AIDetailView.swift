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
        Form {
            Section {
                DisclosureGroup("Critique", isExpanded: $isCritiqueExpanded) {
                    Text(question.critique)
                }
            }
            Section {
                DisclosureGroup("AI Update", isExpanded: $isAIUpdateExpanded) {
                    markdownText(formattedResponseText(aiUpdate.text))
                }
            }
        }
        .navigationTitle("AI Update")
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

//#Preview {
//    AIDetailView()
//}
