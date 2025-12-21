//
//  Topic.swift
//  SESATS10
//
//  Created by Edward Bender on 12/18/25.
//

import SwiftUI

struct Topic: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let imageString: String
    
    static let allTopics: [Topic] = [
        Topic(title: "General Thoracic - Lung & Chest Wall", imageString: "lungs"),
        Topic(title: "Mediastinum", imageString: "mediastinum"),
        Topic(title: "Adult Acquired Cardiac", imageString: "heart"),
        Topic(title: "Congenital Cardiac", imageString: "congenital"),
        Topic(title: "Critical Care", imageString: "criticalCare")
    ]
}
