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
import SwiftData

enum SidebarSelection: Hashable {
    case topic(String)
    case scorecard(correct: Bool)
}

enum QuestionRoute: Hashable {
    case topicQuestion(String)
    case reviewQuestion(String)
    case critique(String)
    case aiUpdate(String)
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

private struct PushQuestionRouteKey: EnvironmentKey {
    static let defaultValue: (QuestionRoute) -> Void = { _ in }
}

extension EnvironmentValues {
    /// Pushes a screen onto the shared route. Detail views use this instead of
    /// local `navigationDestination(isPresented:)` state so the screen they
    /// present survives a layout swap (e.g. folding iPhone Duo).
    var pushQuestionRoute: (QuestionRoute) -> Void {
        get { self[PushQuestionRouteKey.self] }
        set { self[PushQuestionRouteKey.self] = newValue }
    }
}

/// Destination for a pushed question, shared by both layouts.
struct QuestionRouteView: View {
    let route: QuestionRoute
    let answeredQuestions: [Question]

    @Query private var aiUpdates: [AIUpdate]

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
        case .critique(let id):
            if let question = answeredQuestions.first(where: { $0.id == id }) {
                CritiqueView(question: question)
            }
        case .aiUpdate(let id):
            if let question = answeredQuestions.first(where: { $0.id == id }) {
                AIDetailView(
                    question: question,
                    aiUpdate: aiUpdates.first(where: { $0.id == id })
                        ?? AIUpdate(id: id, text: "AI update failed.", date: .now)
                )
            }
        }
    }
}
