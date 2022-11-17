//
//  SceneDelegate.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/9/22.
//

// swiftlint:disable all

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    lazy var rootViewController = MainViewController()

    func scene(
		_ scene: UIScene, willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        if AuthManager().appRemote.isConnected {
            // deciding on the root view
        }
        window.rootViewController = MainViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
    
    //for spotify authorization and authentication flow
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        let parameters = AuthManager().appRemote.authorizationParameters(from: url)
        if let code = parameters?["code"] {
            AuthManager().responseTypeCode = code
        } else if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            AuthManager().accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("No access token error =", error_description)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
