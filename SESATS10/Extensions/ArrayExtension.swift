//
//  ArrayExtension.swift
//  SESATS10
//
//  Created by Edward Bender on 12/20/25.
//

import Foundation

extension Array {
    func letterIndices() -> Array<String> {
        let letters = (0..<self.count).map { i -> String in
            let scalar = UnicodeScalar("a").value + UInt32(i)
            return String(UnicodeScalar(scalar)!)
        }
        return letters
    }
    
    func integerIndices() -> Array<Int> {
        guard let letters = self as? [Character] else { return []}
        return letters.map {
            Int($0.unicodeScalars.first!.value - UnicodeScalar("a").value)
        }
    }
}
