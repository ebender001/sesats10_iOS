//
//  TermsView.swift
//  SESATS10
//
//  Created by Edward Bender on 1/27/26.
//

import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Terms of Use")
                    .font(.title.bold())
                Divider()
                WebView(html: termsString)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    TermsView()
}
