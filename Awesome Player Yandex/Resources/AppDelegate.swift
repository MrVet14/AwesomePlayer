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
		window.rootViewController = rootViewController
		window.makeKeyAndVisible()

		self.window = window

		APICallerYandex.shared.makeFirstCallToAPI(songID: "109747897", albumID: "24310640") { result in
			switch result {
			case .success(let response):
				APICallerYandex.shared.makeSecondCallToAPI(src: response.src) { url in
					print(url)
				}

			case .failure(let error):
				print(error)
			}
		}

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
