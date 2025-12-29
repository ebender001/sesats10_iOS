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
        Text("Using artificial intelligence")
    }
    
    var message: Text? {
        Text("Tap the image upper right for AI updates. Swipe down on the subscription offer to dismiss without purchasing.")
    }
    
    var image: Image? {
        Image(systemName: "apple.intelligence")
    }
}
