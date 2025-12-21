//
//  Scorecard.swift
//  SESATS10
//
//  Created by Edward Bender on 12/18/25.
//

import Foundation

struct Scorecard: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let imageString: String
    var numberAnswered: Int
    
    static let allScorecards = [
        Scorecard(title: "Correct", imageString: "correct", numberAnswered: 0),
        Scorecard(title: "Incorrect", imageString: "incorrect", numberAnswered: 0)
    ]
}
