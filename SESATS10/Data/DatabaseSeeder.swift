//
//  DatabaseSeeder.swift
//  SESATS10
//
//  Created by Edward Bender on 4/16/26.
//

import Foundation
import SQLite3
import SwiftData

enum DatabaseSeeder {
    static let expectedQuestionCount = 400

    struct SeedPayload: Sendable {
        let questions: [SeedQuestion]
    }

    struct SeedQuestion: Sendable {
        let abstract1Title: String
        let abstract2Title: String
        let abstract3Title: String
        let abstract4Title: String
        let correctAnswer: String
        let critique: String
        let critiqueMedia: String
        let distractorA: String
        let distractorB: String
        let distractorC: String
        let distractorD: String
        let distractorE: String
        let examId: String
        let finalQuestionNumber: Int
        let id: String
        let pubMedRefId1: String
        let pubMedRefId2: String
        let pubMedRefId3: String
        let pubMedRefId4: String
        let questionText: String
        let section: String
        let stem: String
        let title: String
    }

    static func seedIfNeeded(into modelContext: ModelContext) async throws {
        guard !isSeeded(in: modelContext) else { return }

        let payload = try await Task.detached(priority: .userInitiated) { @Sendable in
            try loadSeedPayload()
        }.value

        try insert(payload, into: modelContext)
    }

    static func isSeeded(in modelContext: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Question>()

        do {
            let questions = try modelContext.fetch(descriptor)
            let sections = Set(questions.map(\.section))

            return questions.count == expectedQuestionCount
                && sections.contains("General Thoracic - Lung & Chest Wall")
                && sections.contains("Mediastinum")
                && sections.contains("Adult Acquired Cardiac")
                && sections.contains("Congenital Cardiac")
                && sections.contains("Critical Care")
        } catch {
            print("Failed to check seeded state: \(error.localizedDescription)")
            return false
        }
    }

    nonisolated static func loadSeedPayload() throws -> SeedPayload {
        guard let path = Bundle.main.url(forResource: "questions", withExtension: "sqlite") else {
            throw SeederError.missingSQLiteFile
        }

        var db: OpaquePointer?
        guard sqlite3_open_v2(path.path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK, let db else {
            throw SeederError.invalidSQLiteData
        }
        defer { sqlite3_close(db) }

        let sql = """
            SELECT
                abstract1Title,
                abstract2Title,
                abstract3Title,
                abstract4Title,
                correctAnswer,
                critique,
                critiqueMedia,
                distractorA,
                distractorB,
                distractorC,
                distractorD,
                distractorE,
                examId,
                finalQuestionNumber,
                id,
                pubMedRefId1,
                pubMedRefId2,
                pubMedRefId3,
                pubMedRefId4,
                questionText,
                section,
                stem,
                title
            FROM questions
            ORDER BY finalQuestionNumber
        """

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            throw SeederError.invalidSQLiteData
        }
        defer { sqlite3_finalize(statement) }

        var questions: [SeedQuestion] = []

        while sqlite3_step(statement) == SQLITE_ROW {
            let question = SeedQuestion(
                abstract1Title: sqliteColumnText(statement, index: 0),
                abstract2Title: sqliteColumnText(statement, index: 1),
                abstract3Title: sqliteColumnText(statement, index: 2),
                abstract4Title: sqliteColumnText(statement, index: 3),
                correctAnswer: sqliteColumnText(statement, index: 4),
                critique: sqliteColumnText(statement, index: 5),
                critiqueMedia: sqliteColumnText(statement, index: 6),
                distractorA: sqliteColumnText(statement, index: 7),
                distractorB: sqliteColumnText(statement, index: 8),
                distractorC: sqliteColumnText(statement, index: 9),
                distractorD: sqliteColumnText(statement, index: 10),
                distractorE: sqliteColumnText(statement, index: 11),
                examId: sqliteColumnText(statement, index: 12),
                finalQuestionNumber: Int(sqlite3_column_int(statement, 13)),
                id: sqliteColumnText(statement, index: 14),
                pubMedRefId1: sqliteColumnText(statement, index: 15),
                pubMedRefId2: sqliteColumnText(statement, index: 16),
                pubMedRefId3: sqliteColumnText(statement, index: 17),
                pubMedRefId4: sqliteColumnText(statement, index: 18),
                questionText: sqliteColumnText(statement, index: 19),
                section: sqliteColumnText(statement, index: 20),
                stem: sqliteColumnText(statement, index: 21),
                title: sqliteColumnText(statement, index: 22)
            )
            questions.append(question)
        }

        guard !questions.isEmpty else {
            throw SeederError.invalidSQLiteData
        }

        return SeedPayload(questions: questions)
    }

    nonisolated private static func sqliteColumnText(_ statement: OpaquePointer?, index: Int32) -> String {
        guard let cString = sqlite3_column_text(statement, index) else { return "" }
        return String(cString: cString)
    }

    @MainActor
    static func insert(_ payload: SeedPayload, into modelContext: ModelContext) throws {
        try deleteAll(of: Question.self, in: modelContext)
        try deleteAll(of: AIUpdate.self, in: modelContext)

        for seedQuestion in payload.questions {
            let question = Question(
                abstract1Title: seedQuestion.abstract1Title,
                abstract2Title: seedQuestion.abstract2Title,
                abstract3Title: seedQuestion.abstract3Title,
                abstract4Title: seedQuestion.abstract4Title,
                answeredCorrectly: false,
                answeredIncorrectly: false,
                correctAnswer: seedQuestion.correctAnswer,
                critique: seedQuestion.critique,
                critiqueMedia: seedQuestion.critiqueMedia,
                distractorA: seedQuestion.distractorA,
                distractorB: seedQuestion.distractorB,
                distractorC: seedQuestion.distractorC,
                distractorD: seedQuestion.distractorD,
                distractorE: seedQuestion.distractorE,
                examId: seedQuestion.examId,
                finalQuestionNumber: seedQuestion.finalQuestionNumber,
                id: seedQuestion.id,
                pubMedRefId1: seedQuestion.pubMedRefId1,
                pubMedRefId2: seedQuestion.pubMedRefId2,
                pubMedRefId3: seedQuestion.pubMedRefId3,
                pubMedRefId4: seedQuestion.pubMedRefId4,
                questionText: seedQuestion.questionText,
                section: seedQuestion.section,
                selectedAnswer: "",
                stem: seedQuestion.stem,
                title: seedQuestion.title
            )
            modelContext.insert(question)
        }

        try modelContext.save()
    }
}

enum SeederError: LocalizedError {
    case missingSQLiteFile
    case invalidSQLiteData

    var errorDescription: String? {
        switch self {
        case .missingSQLiteFile:
            return "Could not find questions.sqlite in the app bundle."
        case .invalidSQLiteData:
            return "The SQLite file is missing, unreadable, or invalid."
        }
    }
}
