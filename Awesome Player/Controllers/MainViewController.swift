import Kingfisher
import SnapKit
import UIKit

class MainViewController: UIViewController {
	var recommendedSongs: [SongObject] = []
	var likedSongs: [SongObject] = []
	var userProfile: UserObject?

    // MARK: - Subviews
    private lazy var connectLabel: UILabel = {
        let label = UILabel()
		label.text = L10n.welcome
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
		label.textColor = UIColor(asset: Asset.spotifyGreen)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		loadAllTheData()
		setupViews()
    }

    // MARK: Adding different elements to view
    func setupViews() {
		view.backgroundColor = .systemBackground

        view.addSubview(connectLabel)
    }

	// MARK: Laying out constraints
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		connectLabel.snp.makeConstraints { make in
			make.center.equalTo(view.center)
		}
	}

	// MARK: Getting Data Form API & Firebase, then storing & retrieving it from Realm
	func loadAllTheData() {
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
}
