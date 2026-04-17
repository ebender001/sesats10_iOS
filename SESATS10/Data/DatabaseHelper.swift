//
//  DatabaseHelper.swift
//  SESATS10
//
//  Created by Edward Bender on 1/2/26.
//

import Foundation
import SQLite3
import SwiftData

func deleteAll<T: PersistentModel>(
    of type: T.Type,
    in context: ModelContext
) throws {
    let descriptor = FetchDescriptor<T>()
    try context.delete(model: T.self, where: descriptor.predicate)
}

struct BundledQuestionSummary: Identifiable, Hashable {
    let id: String
    let finalQuestionNumber: Int
    let questionText: String
    let section: String
}

struct BundledQuestionDetail: Identifiable, Hashable {
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

extension BundledQuestionDetail {
    var distractors: [String] {
        [distractorA, distractorB, distractorC, distractorD, distractorE].filter { !$0.isEmpty }
    }

    var questionMediaAssets: [String] {
        guard !stem.isEmpty else { return [] }
        return stem
            .replacingOccurrences(of: "\"", with: "")
            .split(separator: ",")
            .compactMap { item in
                let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return nil }
                return URL(fileURLWithPath: trimmed).lastPathComponent
            }
    }

    var questionImageAssets: [String] {
        questionMediaAssets.filter {
            let ext = $0.lowercased()
            return ext.hasSuffix("png") || ext.hasSuffix("jpg") || ext.hasSuffix("jpeg")
        }
    }

    var questionMovieAssets: [String] {
        questionMediaAssets.filter { $0.lowercased().hasSuffix("mp4") }
    }
}

enum BundledQuestionCatalog {
    private struct Catalog {
        let detailsByID: [String: BundledQuestionDetail]
        let questionsByTopic: [String: [BundledQuestionSummary]]
        let countsByTopic: [String: Int]

        static let empty = Catalog(detailsByID: [:], questionsByTopic: [:], countsByTopic: [:])
    }

    private static let catalog: Catalog = {
        (try? loadCatalog()) ?? .empty
    }()

    static func questions(in topic: String) -> [BundledQuestionSummary] {
        catalog.questionsByTopic[topic] ?? []
    }

    static func questionCount(in topic: String) -> Int {
        catalog.countsByTopic[topic] ?? 0
    }

    static func detail(for questionID: String) -> BundledQuestionDetail? {
        catalog.detailsByID[questionID]
    }

    private static func loadCatalog() throws -> Catalog {
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
            ORDER BY section, finalQuestionNumber
        """

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            throw SeederError.invalidSQLiteData
        }
        defer { sqlite3_finalize(statement) }

        var detailsByID: [String: BundledQuestionDetail] = [:]
        var questionsByTopic: [String: [BundledQuestionSummary]] = [:]
        var countsByTopic: [String: Int] = [:]

        while sqlite3_step(statement) == SQLITE_ROW {
            let detail = BundledQuestionDetail(
                abstract1Title: sqliteColumnText(statement, index: 0).htmlStrippedPreservingParagraphs(),
                abstract2Title: sqliteColumnText(statement, index: 1).htmlStrippedPreservingParagraphs(),
                abstract3Title: sqliteColumnText(statement, index: 2).htmlStrippedPreservingParagraphs(),
                abstract4Title: sqliteColumnText(statement, index: 3).htmlStrippedPreservingParagraphs(),
                correctAnswer: sqliteColumnText(statement, index: 4),
                critique: sqliteColumnText(statement, index: 5).htmlStrippedPreservingParagraphs(),
                critiqueMedia: sqliteColumnText(statement, index: 6),
                distractorA: sqliteColumnText(statement, index: 7).htmlStrippedPreservingParagraphs(),
                distractorB: sqliteColumnText(statement, index: 8).htmlStrippedPreservingParagraphs(),
                distractorC: sqliteColumnText(statement, index: 9).htmlStrippedPreservingParagraphs(),
                distractorD: sqliteColumnText(statement, index: 10).htmlStrippedPreservingParagraphs(),
                distractorE: sqliteColumnText(statement, index: 11).htmlStrippedPreservingParagraphs(),
                examId: sqliteColumnText(statement, index: 12),
                finalQuestionNumber: Int(sqlite3_column_int(statement, 13)),
                id: sqliteColumnText(statement, index: 14),
                pubMedRefId1: sqliteColumnText(statement, index: 15).htmlStrippedPreservingParagraphs(),
                pubMedRefId2: sqliteColumnText(statement, index: 16).htmlStrippedPreservingParagraphs(),
                pubMedRefId3: sqliteColumnText(statement, index: 17).htmlStrippedPreservingParagraphs(),
                pubMedRefId4: sqliteColumnText(statement, index: 18).htmlStrippedPreservingParagraphs(),
                questionText: sqliteColumnText(statement, index: 19).htmlStrippedPreservingParagraphs(),
                section: sqliteColumnText(statement, index: 20),
                stem: sqliteColumnText(statement, index: 21),
                title: sqliteColumnText(statement, index: 22).htmlStrippedPreservingParagraphs()
            )

            let summary = BundledQuestionSummary(
                id: detail.id,
                finalQuestionNumber: detail.finalQuestionNumber,
                questionText: detail.questionText,
                section: detail.section
            )

            detailsByID[detail.id] = detail
            questionsByTopic[summary.section, default: []].append(summary)
            countsByTopic[summary.section, default: 0] += 1
        }

        return Catalog(detailsByID: detailsByID, questionsByTopic: questionsByTopic, countsByTopic: countsByTopic)
    }

    private static func sqliteColumnText(_ statement: OpaquePointer?, index: Int32) -> String {
        guard let cString = sqlite3_column_text(statement, index) else { return "" }
        return String(cString: cString)
    }
}
