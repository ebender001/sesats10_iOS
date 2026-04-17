//
//  CardStyle.swift
//  SESATS10
//
//  Created by Edward Bender on 2/15/26.
//
import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.divider.opacity(0.7), lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }
}
