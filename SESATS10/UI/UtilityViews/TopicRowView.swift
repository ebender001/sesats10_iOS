//
//  TopicRowView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/18/25.
//

import SwiftUI

struct TopicRowView: View {
    let topic: Topic
    let progress: Double

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

            TopicProgressGauge(progress: progress)
        }
        .cardStyle()
        .contentShape(Rectangle())
    }
}

private struct TopicProgressGauge: View {
    let progress: Double

    private let startTrim = 0.18
    private let endTrim = 0.82

    private var gaugeColor: Color {
        switch progress {
        case ..<0.33:
            return Theme.error
        case ..<0.66:
            return Color.orange
        default:
            return Theme.success
        }
    }

    var body: some View {
        let clampedProgress = min(max(progress, 0), 1)
        let trimRange = endTrim - startTrim

        ZStack {
            ZStack {
                Circle()
                    .trim(from: startTrim, to: endTrim)
                    .stroke(
                        gaugeColor.opacity(0.2),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )

                Circle()
                    .trim(from: startTrim, to: startTrim + (trimRange * clampedProgress))
                    .stroke(
                        gaugeColor,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
            }
            .rotationEffect(.degrees(90))

            Text(clampedProgress.formatted(.percent.precision(.fractionLength(0))))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(width: 31, height: 31)
    }
}

#Preview {
    TopicRowView(topic: Topic(title: "General Thoracic - Lung & Chest Wall", imageString: "lungs"), progress: 0.64)
}
