//
//  SubscriptionTip.swift
//  SESATS10
//
//  Created by Edward Bender on 12/28/25.
//

import SwiftUI
import TipKit

struct SubscriptionTip: Tip {
    var title: Text {
        Text("AI Subscription")
    }
    
    var message: Text? {
        Text("Tap the \(Image(systemName: "apple.intelligence")) button to take advantage of artificial intelligence by subscribing. There are two great options!")
    }
    
    var image: Image? {
        Image(systemName: "info.circle")
    }
}
