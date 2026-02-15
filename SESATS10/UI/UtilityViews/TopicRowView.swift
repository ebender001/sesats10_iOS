//
//  TopicRowView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/18/25.
//

import SwiftUI

struct TopicRowView: View {
    let topic: Topic
    
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Theme.accentMuted.opacity(0.12))

                Image(topic.imageString)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .foregroundStyle(Theme.accentMuted)
            }
            .frame(width: 44, height: 44)

            Text(topic.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Spacer(minLength: 0)

        }
        .cardStyle()
        .contentShape(Rectangle())
    }
}

#Preview {
    TopicRowView(topic: Topic(title: "General Thoracic - Lung & Chest Wall", imageString: "lungs"))
}
