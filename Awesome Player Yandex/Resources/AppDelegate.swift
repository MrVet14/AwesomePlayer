import FirebaseCore
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	lazy var rootViewController = TabBarViewController()

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		FirebaseApp.configure()

		print("Launched Yandex version")

		let window = UIWindow(frame: UIScreen.main.bounds)
		if true {
			window.rootViewController = rootViewController
		} else {
			let navVC = UINavigationController(rootViewController: WelcomeViewController())
			window.rootViewController = navVC
		}

		window.makeKeyAndVisible()

		self.window = window

		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions
	) -> UISceneConfiguration {
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(
		_ application: UIApplication,
		didDiscardSceneSessions sceneSessions: Set<UISceneSession>
	) {
	}
}
