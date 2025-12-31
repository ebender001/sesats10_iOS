//
//  CritiqueView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/20/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI
import TipKit

struct CritiqueView: View {
    @EnvironmentObject var paywallViewModel: PaywallViewModel
    @StateObject private var networkChecker = NetworkChecker()
    
    let question: Question
    let aiTip = AITip()
    
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
    @State private var showPaywallAlert = false
    @State private var showPaywallView = false
    @State private var showNetworkIssue = false
        
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
                    if !networkChecker.connected {
                        showNetworkIssue.toggle()
                    } else {
                        Task {
                            if let customerInfo = try? await Purchases.shared.customerInfo()  {
                                if customerInfo.entitlements[Constants.ENTITLEMENT_ID]?.isActive == true {
                                    showAIView.toggle()
                                } else {
                                    showPaywallAlert.toggle()
                                }
                            }
                        }
                    }
                } label: {
                    VStack {
                        Image(systemName: "apple.intelligence")
                    }
                }
            }
        }
        .sheet(isPresented: $showAIView) {
            AIView(question: question)
        }
        .alert(isPresented: $showNetworkIssue) {
            Alert(title: Text("Network Error"), message: Text("You are not connected to the internet. Please try again later."), dismissButton: .default(Text("OK")))
        }
        .alert("Artificial Intelligence", isPresented: $showPaywallAlert) {
            Button("Show Offers") {
                if let offering = paywallViewModel.offering, !offering.availablePackages.isEmpty {
                    showPaywallView = true
                } else {
                    Task {
                        await paywallViewModel.refresh()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The artificial intelligence component is not available. Please purchase a subscription to access this feature.")
        }
        .sheet(isPresented: $showPaywallView) {
            if let offering = paywallViewModel.offering {
                ZStack(alignment: .topTrailing) {
                    PaywallView(offering: offering)
                    Image(systemName: "xmark.circle")
                        .font(.title)
                        .foregroundStyle(.gray)
                        .onTapGesture {
                            showPaywallView = false
                        }
                    .padding()
                }
            }
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
