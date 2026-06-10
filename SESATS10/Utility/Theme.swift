//
//  Theme.swift
//  SESATS10
//
//  Created by Edward Bender on 2/15/26.
//

import SwiftUI

enum Theme {
    static let bg = Color("CTBackground")
    static let surface = Color("CTSurface")
    static let divider = Color("CTDivider")
    static let accent = Color("CTAccent")
    static let accentMuted = Color("CTAccentMuted")
    static let textSecondary = Color("CTTextSecondary")
    static let success = Color("Success")
    static let error = Color("Error")

    static var screenBackground: some View {
        screenBackground(named: "orBackground")
    }

    static func screenBackground(for topic: String) -> some View {
        screenBackground(named: backgroundImageName(for: topic))
    }

    static var aiScreenBackground: some View {
        screenBackground(named: "aiBackground")
    }

    private static func backgroundImageName(for topic: String) -> String {
        switch topic {
        case "General Thoracic - Lung & Chest Wall", "Mediastinum":
            return "lungBackground"
        case "Adult Acquired Cardiac":
            return "heartBackground"
        case "Congenital Cardiac":
            return "congenitalBackground"
        case "Critical Care":
            return "criticalBackground"
        default:
            return "orBackground"
        }
    }

    private static func screenBackground(named imageName: String) -> some View {
        GeometryReader { geometry in
            let safeAreaInsets = geometry.safeAreaInsets
            let width = geometry.size.width + safeAreaInsets.leading + safeAreaInsets.trailing
            let height = geometry.size.height + safeAreaInsets.top + safeAreaInsets.bottom

            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
                .offset(x: -safeAreaInsets.leading, y: -safeAreaInsets.top)
                .ignoresSafeArea()
        }
    }
}
