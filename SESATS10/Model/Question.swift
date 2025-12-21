//
//  Question.swift
//  SESATS10
//
//  Created by Edward Bender on 12/17/25.
//

import Foundation
import SwiftData

@Model
class Question {
    var abstract1Title: String
    var abstract2Title: String
    var abstract3Title: String
    var abstract4Title: String
    var answeredCorrectly: Bool
    var answeredIncorrectly: Bool
    var correctAnswer: String
    var critique: String
    var critiqueMedia: String
    var distractorA: String
    var distractorB: String
    var distractorC: String
    var distractorD: String
    var distractorE: String
    var examId: String
    var finalQuestionNumber: Int
    var id: String
    var pubMedRefId1: String
    var pubMedRefId2: String
    var pubMedRefId3: String
    var pubMedRefId4: String
    var questionText: String
    var section: String
    var selectedAnswer: String
    var stem: String
    var title: String
    
    init(abstract1Title: String, abstract2Title: String, abstract3Title: String, abstract4Title: String, answeredCorrectly: Bool, answeredIncorrectly: Bool, correctAnswer: String, critique: String, critiqueMedia: String, distractorA: String, distractorB: String, distractorC: String, distractorD: String, distractorE: String, examId: String, finalQuestionNumber: Int, id: String, pubMedRefId1: String, pubMedRefId2: String, pubMedRefId3: String, pubMedRefId4: String, questionText: String, section: String, selectedAnswer: String, stem: String, title: String) {
        self.abstract1Title = abstract1Title.htmlStrippedPreservingParagraphs()
        self.abstract2Title = abstract2Title.htmlStrippedPreservingParagraphs()
        self.abstract3Title = abstract3Title.htmlStrippedPreservingParagraphs()
        self.abstract4Title = abstract4Title.htmlStrippedPreservingParagraphs()
        self.answeredCorrectly = answeredCorrectly
        self.answeredIncorrectly = answeredIncorrectly
        self.correctAnswer = correctAnswer
        self.critique = critique.htmlStrippedPreservingParagraphs()
        self.critiqueMedia = critiqueMedia
        self.distractorA = distractorA.htmlStrippedPreservingParagraphs()
        self.distractorB = distractorB.htmlStrippedPreservingParagraphs()
        self.distractorC = distractorC.htmlStrippedPreservingParagraphs()
        self.distractorD = distractorD.htmlStrippedPreservingParagraphs()
        self.distractorE = distractorE.htmlStrippedPreservingParagraphs()
        self.examId = examId
        self.finalQuestionNumber = finalQuestionNumber
        self.id = id
        self.pubMedRefId1 = pubMedRefId1.htmlStrippedPreservingParagraphs()
        self.pubMedRefId2 = pubMedRefId2.htmlStrippedPreservingParagraphs()
        self.pubMedRefId3 = pubMedRefId3.htmlStrippedPreservingParagraphs()
        self.pubMedRefId4 = pubMedRefId4.htmlStrippedPreservingParagraphs()
        self.questionText = questionText.htmlStrippedPreservingParagraphs()
        self.section = section
        self.selectedAnswer = selectedAnswer
        self.stem = stem
        self.title = title.htmlStrippedPreservingParagraphs()
    }
}

extension Question {
    var questionReferences: [[String: String]] {
        let ref1 = self.pubMedRefId1
        let ref2 = self.pubMedRefId2
        let ref3 = self.pubMedRefId3
        let ref4 = self.pubMedRefId4
        
        let abstract1 = self.abstract1Title
        let abstract2 = self.abstract2Title
        let abstract3 = self.abstract3Title
        let abstract4 = self.abstract4Title
        
        var dictArray = [[String: String]]()
        if !abstract1.isEmpty {
            dictArray.append([abstract1: ref1])
        }
        if !abstract2.isEmpty {
            dictArray.append([abstract2: ref2])
        }
        if !abstract3.isEmpty {
            dictArray.append([abstract3: ref3])
        }
        if !abstract4.isEmpty {
            dictArray.append([abstract4: ref4])
        }
        return dictArray
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
        guard !questionMediaAssets.isEmpty else { return [] }
        return questionMediaAssets.filter {
            let ext = $0.lowercased()
            return ext.hasSuffix("png") || ext.hasSuffix("jpg") || ext.hasSuffix("jpeg")
        }
    }
    
    var questionMovieAssets: [String] {
        guard !questionMediaAssets.isEmpty else { return [] }
        return questionMediaAssets.filter {
            let ext = $0.lowercased()
            return ext.hasSuffix("mp4")
        }
    }
    
    var critiqueMediaAssets: [String] {
        guard !critiqueMedia.isEmpty else { return [] }
        return critiqueMedia
            .replacingOccurrences(of: "\"", with: "")
            .split(separator: ",")
            .compactMap { item in
                let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return nil }
                return URL(fileURLWithPath: trimmed).lastPathComponent
            }
    }
    
    var critiqueImageAssets: [String] {
        guard !critiqueMediaAssets.isEmpty else { return [] }
        return critiqueMediaAssets.filter {
            let ext = $0.lowercased()
            return ext.hasSuffix("jpg")
        }
    }
    
    var critiqueMovieAssets: [String] {
        guard !critiqueMediaAssets.isEmpty else { return [] }
        return critiqueMediaAssets.filter {
            let ext = $0.lowercased()
            return ext.hasSuffix("mp4")
        }
    }
}
