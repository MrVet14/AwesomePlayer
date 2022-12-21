import Kingfisher
import SnapKit
import UIKit
// swiftlint:disable all
class MainViewController: UIViewController {
	let waysToSayHi = ["Hello", "Привет", " 你好", "今日は", " 안녕하세요", "Bonjour", "Hola", "Hallo", "Ciao", "Ahoy!", "Aloha", "नमस्ते", "γεια σας", "Salve", "ᐊᐃᓐᖓᐃ", "Osiyo"]
	
	var recommendedSongs: [SongObject] = []
	var likedSongs: [SongObject] = []

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

		let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(didTapSettings))
		navigationItem.rightBarButtonItems = [settingsButton]
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
		print("Loading User data")
		APICaller.shared.loadUser { [weak self] result in
			switch result {
			case .success(let data):
				DBManager.shared.addUserToDB(data)

			case .failure(let error):
				self?.handlingErrorDuringLoadingData(error: error)
			}
		}

		// getting Recommended songs
		APICaller.shared.loadRecommendedTracks { [weak self] result in
			print("Loading recommended songs")
			switch result {
			case .success(let data):
				DBManager.shared.addSongsToDB(data.tracks, typeOfPassedSongs: DBSongTypes.recommended)
				DBManager.shared.getRecommendedSongsFromDB { [weak self] result in
					self?.recommendedSongs = result
				}

			case.failure(let error):
				self?.handlingErrorDuringLoadingData(error: error)
			}
		}

		// getting Liked songs
		FirebaseManager.shared.getData { resultFromFirebase in
			// checking firebase response, if there's any liked songs we load and store them
			print("Checking if user have any liked songs")
			if !resultFromFirebase.isEmpty {
				print("Loading liked songs")
				// Handling fetching data from Firebase and APICaller
				LoadAllTheLikedSongsHelper.shared.getData(resultFromFirebase) { resultFromAPICaller in
					DBManager.shared.addSongsToDB(resultFromAPICaller, typeOfPassedSongs: DBSongTypes.liked)
					DBManager.shared.getLikedSongsFromDB { [weak self] result in
						self?.likedSongs = result
					}
				}
			}
		}
	}

	// MARK: Handling possible errors
	func handlingErrorDuringLoadingData(error: Error) {
		print(error.localizedDescription)

		let alert = UIAlertController(title: L10n.somethingWentWrong,
									  message: L10n.tryRestartingAppOrPressReload,
									  preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: L10n.reload, style: .default, handler: { [weak self] _ in
			self?.loadTheData()
		}))
		present(alert, animated: true)
	}
	
	// MARK: Updating view with fresh data
	func updateViewWithFreshData() {
		
	}
}
