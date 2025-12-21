//
//  DisclaimerView.swift
//  SESATS10
//
//  Created by Edward Bender on 12/21/25.
//

import SwiftUI

struct DisclaimerView: View {
    
    let disclaimer = """
        This is the third in a series of apps developed to review previous SESATS examination questions.  The first was CardioThoracic Study Questions, published in October, 2011, and represented the SESATS VIII question set.  The second offering represents the SESATS IX question set.  The current software represents material from SESATS X.  SESATS XIII is the most current version and is the version used for maintenance of certification as of the date of this writing.  Therefore, although the current question set is a resource for the studying Thoracic Surgeon, some of its content may be outdated and may not represent the current state of the art and science of Thoracic Surgery.
        """
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Disclaimer")
                .font(.title.bold())
            Text(disclaimer)
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Dismiss")
                    .fontWeight(.bold)
                    .foregroundStyle(.gray)
            }
        }
        .padding()
    }
}

#Preview {
    DisclaimerView()
}
