//
//  ReviewTip.swift
//  SESATS10
//
//  Created by Edward Bender on 1/13/26.
//

import SwiftUI
import TipKit

struct ReviewTip: Tip {
    var title: Text {
        Text("AI Update")
    }
    
    var message: Text? {
        Text("Tap the \(Image(systemName: "apple.intelligence")) button to display both the question's critique and the AI update.")
    }
    
    var image: Image? {
        Image(systemName: "info.circle")
    }
}
