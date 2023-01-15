import UIKit
// swiftlint:disable all
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?

	lazy var rootViewController = TabBarViewController()

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		let window = UIWindow(windowScene: windowScene)
		if true {
			window.rootViewController = rootViewController
		}
		else {
			let navVC = UINavigationController(rootViewController: WelcomeViewController())
			window.rootViewController = navVC
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
}
