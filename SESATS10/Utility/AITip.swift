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
        Text("Tap the \(Image(systemName: "apple.intelligence")) button for AI updates. Three options are available: Monthly, Annually, and Lifetime.")
    }
    
    var image: Image? {
        Image(systemName: "info.circle")
    }
}
