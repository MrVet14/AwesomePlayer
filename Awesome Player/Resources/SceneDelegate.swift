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
    // swiftlint:disable line_length
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        if AuthManager.shared.isSignedIn {
            window.rootViewController = MainViewController()
        } else {
            window.rootViewController = WelcomeViewController()
        }
        window.makeKeyAndVisible()
        self.window = window
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
    
    lazy var rootViewController = MainViewController()
}

//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    var window: UIWindow?
//    lazy var rootViewController = ViewController()
//
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window!.makeKeyAndVisible()
//        window!.windowScene = windowScene
//        window!.rootViewController = rootViewController
//    }
//
//    // For spotify authorization and authentication flow
//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        guard let url = URLContexts.first?.url else { return }
//        let parameters = rootViewController.appRemote.authorizationParameters(from: url)
//        if let code = parameters?["code"] {
//            rootViewController.responseCode = code
//        } else if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
//            rootViewController.accessToken = access_token
//        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
//            print("No access token error =", error_description)
//        }
//    }
//
//    func sceneDidBecomeActive(_ scene: UIScene) {
//        if let accessToken = rootViewController.appRemote.connectionParameters.accessToken {
//            rootViewController.appRemote.connectionParameters.accessToken = accessToken
//            rootViewController.appRemote.connect()
//        } else if let accessToken = rootViewController.accessToken {
//            rootViewController.appRemote.connectionParameters.accessToken = accessToken
//            rootViewController.appRemote.connect()
//        }
//    }
//
//    func sceneWillResignActive(_ scene: UIScene) {
//        if rootViewController.appRemote.isConnected {
//            rootViewController.appRemote.disconnect()
//        }
//    }
//}

