//
//  AIUpdate.swift
//  SESATS10
//
//  Created by Edward Bender on 1/2/26.
//

import Foundation
import SwiftData

@Model
class AIUpdate {
    var id: String
    var text: String
    var date: Date
    
    init (id: String, text: String, date: Date) {
        self.id = id
        self.text = text
        self.date = date
    }
    
    static let sample = AIUpdate(id: "999", text: "Hello World", date: .now)
}
