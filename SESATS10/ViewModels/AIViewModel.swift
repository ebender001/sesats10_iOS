//
//  AIViewModel.swift
//  SESATS10
//
//  Created by Edward Bender on 12/30/25.
//

import SwiftUI
import Combine
import FirebaseAI

@MainActor
final class AIViewModel: ObservableObject {
    @Published var responseText = ""

    private var generationTask: Task<Void, Never>?

    func generate(prompt: String, model: GenerativeModel) {
        generationTask?.cancel()   // cancel any previous request

        generationTask = Task {
            do {
                let response = try await model.generateContent(prompt)

                // Check cancellation explicitly (good practice)
                try Task.checkCancellation()

                responseText = response.text ?? ""
            } catch is CancellationError {
                // Expected when view is dismissed
                print("Generation cancelled")
            } catch {
                print("Generation error:", error)
            }
        }
    }

    func cancel() {
        generationTask?.cancel()
        generationTask = nil
    }

    deinit {
        generationTask?.cancel()
    }
}
