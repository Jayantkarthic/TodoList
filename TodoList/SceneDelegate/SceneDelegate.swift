//
//  SceneDelegate.swift
//  TodoList
//
//  Created by Jayant Karthic on 16/07/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        AppSession.shared.start(in: window)
        self.window = window
    }
}
