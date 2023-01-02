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

		// MARK: Section for testing logic
		// swiftlint:disable all

//		APICaller.shared.loadRecommendedPlaylists { result in
//			switch result {
//			case .success(let response):
//				for item in response.playlists.items {
//					APICaller.shared.loadPlaylistDetails(item.id) { foo in
//						switch foo {
//						case .success(let success):
////							var trackNumber = 0
////							for track in success.tracks.items {
////								print("track #\(trackNumber): ", track)
////								trackNumber += 1
////							}
//							break
//
//						case .failure(let failure):
//							print(failure.localizedDescription)
//						}
//					}
//				}
//			case .failure(let error):
//				print(error.localizedDescription)
//			}
//		}

//		APICaller.shared.loadPlaylistDetails("37i9dQZF1DX9XIFQuFvzM4") { result in
//			switch result {
//			case .success(let response):
//				print(response.id)
//			case .failure(let error):
//				print(error.localizedDescription)
//			}
//		}
//
//		APICaller.shared.loadSongs(["7ouMYWpwJ422jRcDASZB7P", "4VqPOruhp5EdPBeR92t6lQ", "2takcwOaAZWiXQijPHIx7B"]) { result in
//			DBManager.shared.addSongsToDB(result, typeOfPassedSongs: DBSongTypes.liked)
//		}
//
//		APICaller.shared.loadRecommendedTracks { result in
//			DBManager.shared.addSongsToDB(result, typeOfPassedSongs: DBSongTypes.recommended)
//			DBManager.shared.getRecommendedSongsFromDB { foo in
//				print(foo)
//			}
//		}
//
//		APICaller.shared.loadASong("7ouMYWpwJ422jRcDASZB7P") { foo in
//			print(foo)
//		}
//
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
