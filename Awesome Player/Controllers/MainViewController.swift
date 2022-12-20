import Kingfisher
import SnapKit
import UIKit
// swiftlint:disable all
class MainViewController: UIViewController {
	let waysToSayHi = ["Hi!", "Hello!", "Howdy!", "Buongiorno!", "Hey!", "How are you?", "What’s up?", "What’s new?", "Long time no see...", "I come in peace!", "Ahoy!"]
	
	var recommendedSongs: [SongObject] = []
	var likedSongs: [SongObject] = []
	var userProfile: UserObject?

    // MARK: - Subviews

    // MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

		loadTheData()
		setupViews()
    }

    // MARK: Adding different elements to view
    func setupViews() {
		title = waysToSayHi.randomElement()
		view.backgroundColor = .systemBackground

		let accountButton = UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .plain, target: self, action: #selector(didTapProfile))
		let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(didTapSettings))
		navigationItem.rightBarButtonItems = [accountButton, settingsButton]
    }

	// MARK: Laying out constraints
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}

	@objc
	func didTapProfile() {
		let profileVC = ProfileViewController()
		profileVC.navigationItem.largeTitleDisplayMode = .never
		navigationController?.pushViewController(profileVC, animated: true)
	}

	@objc
	func didTapSettings() {
		let settingsVC = SettingsViewController()
		settingsVC.navigationItem.largeTitleDisplayMode = .never
		navigationController?.pushViewController(settingsVC, animated: true)
	}

	// MARK: Getting Data Form API & Firebase, then storing & retrieving it from Realm
	func loadTheData() {
		// getting user profile
		APICaller.shared.loadUser { result in
			print("Loading User data")
			DBManager.shared.addUserToDB(result)
			DBManager.shared.getUserFromDB { [weak self] result in
				self?.userProfile = result
			}
		}

		// getting Recommended songs
		APICaller.shared.loadRecommendedTracks { result in
			print("Loading recommended songs")
			DBManager.shared.addSongsToDB(result, typeOfPassedSongs: DBSongTypes.recommended)
			DBManager.shared.getRecommendedSongsFromDB { [weak self] result in
				self?.recommendedSongs = result
			}
		}

		// Add a check for a number of calls? if over 50? split call into 2
		// getting Liked songs
		FirebaseManager.shared.getData { result in
			// checking firebase response, if there's any liked songs we load and store them
			print("Checking if user have any liked songs")
			if !result.isEmpty {
				print("Loading liked songs")
				APICaller.shared.loadSongs(result) { result in
					DBManager.shared.addSongsToDB(result, typeOfPassedSongs: DBSongTypes.liked)
					DBManager.shared.getLikedSongsFromDB { [weak self] result in
						self?.likedSongs = result
					}
				}
			}
		}
	}
	
	// MARK: Updating view with fresh data
	func updateViewWithFreshData() {
		
	}
}
