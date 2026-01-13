//
//  AIRowView.swift
//  SESATS10
//
//  Created by Edward Bender on 1/2/26.
//

import SwiftUI
import SwiftData

struct AIRowView: View {
    
    @Query var aiUpdates: [AIUpdate]
    
    var body: some View {
        HStack {
            Image(systemName: "apple.intelligence")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.horizontal)
            Text("AI Updates")
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
            Text("\(aiUpdates.count) question\(aiUpdates.count == 1 ? "" : "s")")
        }
    }
}

#Preview {
    AIRowView()
}
