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
        Text("Subscription Status")
    }
    
    var message: Text? {
        Text("Take advantage of artificial intelligence by subscribing.")
    }
    
    var image: Image? {
        Image(systemName: "person.crop.circle")
    }
}
