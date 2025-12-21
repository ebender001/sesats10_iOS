//
//  TopicRowView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/18/25.
//

import SwiftUI

struct TopicRowView: View {
    let topic: Topic
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Image(topic.imageString)
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.horizontal)
            Text(topic.title)
                .font(.headline)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    TopicRowView(topic: Topic(title: "General Thoracic - Lung & Chest Wall", imageString: "lungs"))
}
