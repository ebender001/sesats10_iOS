//
//  AITip.swift
//  SESATS10
//
//  Created by Edward Bender on 12/28/25.
//

import SwiftUI
import TipKit

struct AITip: Tip {
    var title: Text {
        Text("AI Update")
    }
    
    var message: Text? {
        Text("An AI Update subscription is required for more up-to-date information about the correct answer and critique.")
    }
    
    var image: Image? {
        Image(systemName: "info.circle")
    }
}
