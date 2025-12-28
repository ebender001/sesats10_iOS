//
//  CritiqueView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/20/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI


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
    
    @State private var showAIView = false
    @State private var showPaywallAlert = false
    @State private var showPaywallView = false
    
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
                    .textSelection(.enabled)
            }
        }
        .navigationTitle("Critique")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        if let customerInfo = try? await Purchases.shared.customerInfo()  {
                            if customerInfo.entitlements[Constants.ENTITLEMENT_ID]?.isActive == true {
                                showAIView.toggle()
                            } else {
                                showPaywallAlert.toggle()
                            }
                        }
                    }
                } label: {
                    Image(systemName: "apple.intelligence")
                }
            }
        }
        .sheet(isPresented: $showAIView) {
            AIView(question: question)
        }
        .presentPaywallIfNeeded(requiredEntitlementIdentifier: Constants.ENTITLEMENT_ID,
                                purchaseCompleted: { customerInfo in
                print("Purchase completed: \(customerInfo.entitlements)")
        },
                                restoreCompleted: { customerInfo in
                print("Purchases restored: \(customerInfo.entitlements)")
        },
                                purchaseFailure: { error in
            print("Purchase failed with error: \(error.description)")
        },
                                restoreFailure: { error in
                print("Restore purchase failed with error: \(error.description)")
        }
        )
        .alert("Artificial Intelligence", isPresented: $showPaywallAlert) {
            Button("Purchase") {
                showPaywallView.toggle()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The artificial intelligence component is not available. Please purchase a subscription to access this feature.")
        }
        .sheet(isPresented: $showPaywallView) {
            PaywallView()
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
