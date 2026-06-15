//
//  GenerateSesatsAIUpdateCloud.swift
//  SESATS10
//

import Foundation
import ParseSwift

struct GenerateSesatsAIUpdateCloud: ParseCloudable {
    struct Response: Decodable {
        let text: String
        let cached: Bool?
        let model: String?
        let promptVersion: Int?
        let questionId: String?
    }

    typealias ReturnType = Response

    var functionJobName = "generateSesatsAIUpdate"

    let questionId: String
    let questionText: String
    let distractorA: String
    let distractorB: String
    let distractorC: String
    let distractorD: String
    let distractorE: String
    let correctAnswer: String
    let critique: String
    let title: String
    let section: String
    let examId: String
}
