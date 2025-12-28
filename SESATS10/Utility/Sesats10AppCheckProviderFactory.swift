//
//  Sesats10AppCheckProviderFactory.swift
//  SESATS10
//
//  Created by Edward Bender on 12/22/25.
//

import Foundation
import Firebase
import FirebaseAppCheck

class Sesats10AppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        if #available(iOS 14.0, *) {
            return AppAttestProvider(app: app)
        } else {
            return DeviceCheckProvider(app: app)
        }
        
    }
}
