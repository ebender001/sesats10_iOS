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

        return text
            .decodingHTMLEntities()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func decodingHTMLEntities() -> String {
        let namedEntities: [String: String] = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&apos;": "'",
            "&#39;": "'",
            "&nbsp;": " "
        ]

        var decoded = self
        for (entity, replacement) in namedEntities {
            decoded = decoded.replacingOccurrences(of: entity, with: replacement)
        }

        let pattern = "&#(x?[0-9A-Fa-f]+);"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return decoded }

        let matches = regex.matches(
            in: decoded,
            range: NSRange(decoded.startIndex..., in: decoded)
        )

        for match in matches.reversed() {
            guard
                let range = Range(match.range(at: 1), in: decoded)
            else {
                continue
            }

            let value = String(decoded[range])
            let scalarValue: UInt32?

            if value.lowercased().hasPrefix("x") {
                scalarValue = UInt32(value.dropFirst(), radix: 16)
            } else {
                scalarValue = UInt32(value, radix: 10)
            }

            guard
                let scalarValue,
                let scalar = UnicodeScalar(scalarValue),
                let replacementRange = Range(match.range, in: decoded)
            else {
                continue
            }

            decoded.replaceSubrange(replacementRange, with: String(scalar))
        }

        return decoded
    }
}
