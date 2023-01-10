import SnapKit
import UIKit

enum MainViewSectionType {
	case featuredPlaylists(viewModels: [PlaylistCellViewModel])
	case recommendedSongs(viewModels: [SongCellViewModel])

	var title: String {
		switch self {
		case .featuredPlaylists:
			return L10n.featuredPlaylists
		case .recommendedSongs:
			return L10n.recommendedSongs
		}
	}
}

class MainViewController: UIViewController {
	var featuredPlaylists: [PlaylistObject] = []
	var recommendedSongs: [SongObject] = []

	var sections = [MainViewSectionType]()

	var alreadyLoadedPlaylists: [String] = []

    // MARK: - Subviews
	var collectionView = UICollectionView(
		frame: .zero,
		collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
			return MainViewController.createSectionLayout(section: sectionIndex)
	 })

	lazy var indicatorView: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(style: .medium)
		view.color = .white
		view.hidesWhenStopped = true
		view.startAnimating()
		return view
	}()

    // MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

		setupViews()
		loadTheData()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(configureModels),
			name: Notification.Name(NotificationCenterConstants.playerVCClosed),
			object: nil
		)
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		configureModels()
	}

    // MARK: Adding different elements to view
    func setupViews() {
		view.backgroundColor = .systemBackground

		let settingsButton = UIBarButtonItem(
			image: UIImage(systemName: "gear"),
			style: .plain,
			target: self,
			action: #selector(didTapSettings)
		)
		settingsButton.tintColor = .label
		navigationItem.rightBarButtonItems = [settingsButton]

		view.addSubview(collectionView)
		collectionView.register(
			UICollectionViewCell.self,
			forCellWithReuseIdentifier: "cell"
		)
		collectionView.register(
			PlaylistCollectionViewCell.self,
			forCellWithReuseIdentifier: PlaylistCollectionViewCell.identifier
		)
		collectionView.register(
			SongCollectionViewCell.self,
			forCellWithReuseIdentifier: SongCollectionViewCell.identifier
		)
		collectionView.register(
			TitleHeaderCollectionReusableView.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: TitleHeaderCollectionReusableView.identifier
		)
		collectionView.dataSource = self
		collectionView.delegate = self

		collectionView.isHidden = true

		view.addSubview(indicatorView)
    }

	// MARK: Laying out constraints
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		collectionView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		indicatorView.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
	}

	// MARK: Getting Data Form API & Firebase, then storing & retrieving it from Realm
	func loadTheData() {
		let group = DispatchGroup()
		group.enter()
		group.enter()
		group.enter()

		// Purging all songs & playlists in realm on start
		DBManager.shared.purgeAllSongsAndPlaylistsInRealmOnLaunch { success in
			if success {
				group.leave()
			}
		}

		// Getting Featured Playlists
		APICaller.shared.loadRecommendedPlaylists { [weak self] featuredPlaylistsResult in
			switch featuredPlaylistsResult {
			case .success(let featuredPlaylists):
				DBManager.shared.addFeaturedPlaylistsToRealm(featuredPlaylists)
				group.leave()

			case .failure(let error):
				self?.handlingErrorDuringLoadingData(error: error)
			}
		}

		// Getting Recommended songs
		APICaller.shared.loadRecommendedTracks { [weak self] recommendedSongsResults in
			switch recommendedSongsResults {
			case .success(let data):
				DBManager.shared.addSongsToDB(data.tracks, typeOfPassedSongs: DBSongTypes.recommended, playlistID: "")
				group.leave()

			case.failure(let error):
				self?.handlingErrorDuringLoadingData(error: error)
			}
		}

		// Creating Models, hiding indicator & showing collection view once all the data has been loaded
		group.notify(queue: .main) {
			self.indicatorView.stopAnimating()
			self.collectionView.isHidden = false

			self.configureModels()
		}

		loadingAllNotSuperUrgentStuff()
	}

	// MARK: Loading Data that not used immediately
	func loadingAllNotSuperUrgentStuff() {
		// Getting user profile
		APICaller.shared.loadUser { [weak self] userProfileResults in
			switch userProfileResults {
			case .success(let data):
				DBManager.shared.addUserToDB(data)

			case .failure(let error):
				self?.handlingErrorDuringLoadingData(error: error)
			}
		}

		// Getting Liked songs
		FirebaseManager.shared.getData { resultFromFirebase in
			// Checking firebase response, if there's any liked songs we load and store them
			if !resultFromFirebase.isEmpty {
				// Handling fetching data from Firebase and APICaller
				LoadAllTheLikedSongsHelper.shared.getData(resultFromFirebase) { resultFromAPICaller in
					DBManager.shared.addSongsToDB(resultFromAPICaller, typeOfPassedSongs: DBSongTypes.liked, playlistID: "")
				}
			}
		}
	}

	// MARK: Updating Song Data
	func getUpdatedDataFromDB(completion: @escaping (() -> Void)) {
		let group = DispatchGroup()
		group.enter()
		group.enter()

		DBManager.shared.getFeaturedPlaylistsFromDB { [weak self] featuredPlaylistsResult in
			self?.featuredPlaylists = featuredPlaylistsResult
			group.leave()
		}
		DBManager.shared.getRecommendedSongsFromDB { [weak self] recommendedSongsResult in
			self?.recommendedSongs = recommendedSongsResult
			group.leave()
		}

		group.notify(queue: .main) {
			completion()
		}
	}

	// MARK: Creating or updating ViewModels
	@objc
	func configureModels() {
		getUpdatedDataFromDB { [weak self] in
			guard let self = self else {
				return
			}
			// Clearing sections
			self.sections.removeAll()

			// Filling Recommended songs
			let playlistViewModelToReturn = self.featuredPlaylists.compactMap({
				return PlaylistCellViewModel(
					name: $0.name,
					playlistCoverURL: $0.image,
					description: $0.playlistDescription,
					numberOfTracks: $0.numberOfTracks
				)
			})
			self.sections.append(.featuredPlaylists(viewModels: playlistViewModelToReturn))

			// Filling Featured Playlists
			let songViewModelsToReturn = self.recommendedSongs.compactMap({
				return SongCellViewModel(
					id: $0.id,
					name: $0.name,
					albumCoverURL: $0.albumCoverURL,
					artistName: $0.artistName,
					explicit: $0.explicit,
					liked: $0.liked)
			})
			self.sections.append(.recommendedSongs(viewModels: songViewModelsToReturn))

			// Reloading Collection View with new data
			self.collectionView.reloadData()
		}
	}

	// MARK: Handling possible errors
	func handlingErrorDuringLoadingData(error: Error) {
		print(error.localizedDescription)

		let alert = UIAlertController(
			title: L10n.somethingWentWrong,
			message: L10n.tryRestartingAppOrPressReload,
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: L10n.reload,
				style: .default,
				handler: { [weak self] _ in
					self?.loadTheData()
				}
			)
		)
		present(alert, animated: true)
	}

	// MARK: Controller logic
	// Switching to settings View
	@objc
	func didTapSettings() {
		let settingsVC = SettingsViewController()
		settingsVC.navigationItem.largeTitleDisplayMode = .never
		navigationController?.pushViewController(settingsVC, animated: true)
	}

	// Processing tap on like button
	func processLikeButtonTappedAction(
		id: String,
		liked: Bool
	) {
		TrackHandlerManager.shared.processLikeButtonTappedAction(
			id: id,
			liked: liked
		) {
			self.configureModels()
		}
	}
}
