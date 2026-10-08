//
//  AppRoute.swift
//  SESATS10
//
//  Navigation state shared by the compact (ContentView) and regular
//  (SidebarSplitView) layouts. RootView owns a single `[AppRoute]`, so folding
//  or resizing the window swaps layouts without losing the user's place.
//
//  The route is always: an optional section (topic or scorecard) followed by
//  zero or more questions pushed on top of it.
//

import SwiftUI

enum SidebarSelection: Hashable {
    case topic(String)
    case scorecard(correct: Bool)
}

enum QuestionRoute: Hashable {
    case topicQuestion(String)
    case reviewQuestion(String)
}

enum AppRoute: Hashable {
    case section(SidebarSelection)
    case question(QuestionRoute)
}

extension Array where Element == AppRoute {
    var selectedSection: SidebarSelection? {
        if case .section(let selection)? = first { return selection }
        return nil
    }

    var questionRoutes: [QuestionRoute] {
        compactMap {
            if case .question(let route) = $0 { return route }
            return nil
        }
    }

    /// Replaces the selected section, discarding any questions pushed on the old one.
    mutating func select(_ selection: SidebarSelection?) {
        self = selection.map { [.section($0)] } ?? []
    }

    /// Replaces the pushed questions, keeping the selected section.
    mutating func setQuestionRoutes(_ routes: [QuestionRoute]) {
        self = (selectedSection.map { [.section($0)] } ?? []) + routes.map { .question($0) }
    }
}

/// Destination for a pushed question, shared by both layouts.
struct QuestionRouteView: View {
    let route: QuestionRoute
    let answeredQuestions: [Question]

    var body: some View {
        switch route {
        case .topicQuestion(let id):
            if let detail = BundledQuestionCatalog.detail(for: id) {
                QuestionDetailView(detail: detail)
            } else {
                ContentUnavailableView(
                    "Question Unavailable",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Unable to load this question from the bundled catalog.")
                )
            }
        case .reviewQuestion(let id):
            if let question = answeredQuestions.first(where: { $0.id == id }) {
                ReviewQuestionDetailView(question: question)
            }
        }
    }
}
