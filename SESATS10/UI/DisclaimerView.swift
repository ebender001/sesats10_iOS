//
//  DisclaimerView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/21/25.
//

import SwiftUI

struct DisclaimerView: View {
    
    let disclaimer =
        """
        This application is the third in a series developed to facilitate review of prior SESATS examination questions. The first, CardioThoracic Study Questions, was published in October 2011 and was based on the SESATS VIII question set. The second application covered material from SESATS IX. The current software presents content derived from SESATS X.
        
        At the time of this writing, SESATS XIII is the most current edition and is the version used for Maintenance of Certification. Accordingly, while this application remains a useful study resource for thoracic surgeons, some material may be outdated and may not fully reflect the current standards, practices, or scientific advances in thoracic surgery.
        """
    let aiString = """
To ensure critiques reflect the most current medical knowledge, this app incorporates **artificial intelligence** to deliver up-to-date explanations and relevant supplemental information when appropriate. The app is powered by Google’s Gemini 2.5 generative model, which incurs a modest usage cost. To help offset this expense, we offer flexible subscription options, including auto-renewing monthly or annual plans, as well as a one-time lifetime subscription that never expires.
"""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(disclaimer)
                        .padding(.bottom)
                    
                    Text("Artificial Intelligence")
                        .font(.title.bold())
                    if let attributedAiString = try? AttributedString(markdown: aiString) {
                        Text(attributedAiString)
                    }
                    
                    Spacer()
                    
                    
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
            .navigationTitle("Disclaimer")
        }
        
        
    }
}

#Preview {
    DisclaimerView()
}
