//
//  SceneDelegate.swift
//  SESATS10
//
//  Created by Edward Bender on 12/31/25.
//

import SwiftUI
import RevenueCat

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?
    let paywallViewModel = PaywallViewModel()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let root = ContentView().environmentObject(paywallViewModel)
        window.rootViewController = UIHostingController(rootView: root)
        self.window = window
        window.makeKeyAndVisible()
        
        Task {
            await paywallViewModel.refresh()
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        Task {
            await paywallViewModel.refresh()
        }
    }
}
