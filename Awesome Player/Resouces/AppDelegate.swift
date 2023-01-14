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

		// MARK: For testing only
//		AuthManager.shared.signOut { _ in
//			print("Signed Out")
//		}

        let window = UIWindow(frame: UIScreen.main.bounds)
		if AuthManager.shared.isSignedIn {
			AuthManager.shared.refreshIfNeeded { success in
				print("Need to update AuthToken: \(success)")
			}
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
