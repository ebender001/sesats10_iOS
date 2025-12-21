//
//  StringExtension.swift
//  SESATS10
//
//  Created by Edward Bender on 12/18/25.
//

import Foundation

extension String {
    /// Returns a new string with all HTML tags removed.
    func removingHTMLTags() -> String {
        guard let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: .caseInsensitive) else { return self }
        let range = NSRange(self.startIndex..., in: self)
        // Replace every match with an empty string
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
    }
    
    func htmlStrippedPreservingParagraphs() -> String {
        var text = self

        // Convert <p> and </p> to newlines
        text = text.replacingOccurrences(
            of: "(?i)</?p[^>]*>",
            with: "\n",
            options: .regularExpression
        )

        // Remove all remaining HTML tags
        text = text.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )

        // Normalize multiple newlines
        text = text.replacingOccurrences(
            of: "\n{3,}",
            with: "\n",
            options: .regularExpression
        )

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

