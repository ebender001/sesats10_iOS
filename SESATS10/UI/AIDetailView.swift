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
                    Text(aiUpdate.text)
                }
            }
        }
        .navigationTitle("AI Detail")
    }
}

//#Preview {
//    AIDetailView()
//}
