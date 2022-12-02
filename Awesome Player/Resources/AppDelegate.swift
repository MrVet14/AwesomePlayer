import FirebaseCore
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    lazy var rootViewController = MainViewController()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()

        let window = UIWindow(frame: UIScreen.main.bounds)
		if AuthManager.shared.isSignedIn {
			window.rootViewController = rootViewController
		} else {
			window.rootViewController = AuthViewController()
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
