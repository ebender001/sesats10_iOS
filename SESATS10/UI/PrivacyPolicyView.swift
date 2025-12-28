//
//  PrivacyPolicyView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/21/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Privacy Policy")
                    .font(.title.bold())
                Divider()
                WebView(html: privacyString)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
//                    Button("Dismiss") {
//                        dismiss()
//                    }
                }
            }
        }
    }
    
}

#Preview {
    PrivacyPolicyView()
}
