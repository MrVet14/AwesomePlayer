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

//		// MARK: For testing only
//		AuthManager.shared.signOut { _ in
//			print("Signed Out")
//		}

        let window = UIWindow(frame: UIScreen.main.bounds)
		if AuthManager.shared.isSignedIn {
			AuthManager.shared.refreshIfNeeded { success in
				print("Need to update AuthToken: \(success)")
			}
			let mainVC = UINavigationController(rootViewController: rootViewController)
			mainVC.navigationBar.prefersLargeTitles = true
			mainVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
			window.rootViewController = mainVC
		} else {
			let navVC = UINavigationController(rootViewController: WelcomeViewController())
			navVC.navigationBar.prefersLargeTitles = true
			navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
			window.rootViewController = navVC
		}
        window.makeKeyAndVisible()

        self.window = window

		// MARK: Section for testing logic
		// swiftlint:disable line_length
//		APICaller.shared.loadSongs(["7ouMYWpwJ422jRcDASZB7P", "4VqPOruhp5EdPBeR92t6lQ", "2takcwOaAZWiXQijPHIx7B"]) { result in
//			DBManager.shared.addSongsToDB(result, typeOfPassedSongs: DBSongTypes.liked)
//		}
//		APICaller.shared.loadRecommendedTracks { result in
//			DBManager.shared.addSongsToDB(result, typeOfPassedSongs: DBSongTypes.recommended)
//			DBManager.shared.getRecommendedSongsFromDB { foo in
//				print(foo)
//			}
//		}
//		APICaller.shared.loadASong("7ouMYWpwJ422jRcDASZB7P") { foo in
//			print(foo)
//		}
//		APICaller.shared.loadUser { result in
//			DBManager.shared.addUserToDB(result)
//			DBManager.shared.getUserFromDB { foo in
//				print(foo)
//			}
//		}

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
