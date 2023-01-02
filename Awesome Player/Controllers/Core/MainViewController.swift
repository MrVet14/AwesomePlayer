import SnapKit
import UIKit
// swiftlint:disable all
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

    // MARK: - Subviews
	var collectionView = UICollectionView(
		frame: .zero,
		collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
			return MainViewController.createSectionLayout(section: sectionIndex)
	 })

    // MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

		setupViews()
		loadTheData()
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
    }

	// MARK: Laying out constraints
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		collectionView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}

	// MARK: Getting Data Form API & Firebase, then storing & retrieving it from Realm
	func loadTheData() {
		let group = DispatchGroup()
		group.enter()
		group.enter()
		group.enter()

		// Purging all songs in realm on start
		DBManager.shared.purgeAllSongsAndAlbumsInRealmOnLaunch { success in
			if success {
				defer {
					group.leave()
				}
				print("Purged all songs in Realm")
			}
		}

		// Getting Featured Playlists
		APICaller.shared.loadRecommendedPlaylists { [weak self] recommendedPlaylistsResult in
			print("Loading Recommended Playlists")
			switch recommendedPlaylistsResult {
			case .success(let recommendedPlaylists):
				var numberOfTimesRan = 0
				for playlist in recommendedPlaylists.playlists.items {
					// Getting Featured Playlists tracks by theres IDs
					APICaller.shared.loadPlaylistDetails(playlist.id) { playlistDetailsResult in
						switch playlistDetailsResult {
						case .success(let playlistDetails):
							// Adding Playlists to Realm and Retrieving Data from Realm as Objects
							DBManager.shared.addPlaylistToRealm(playlistDetails)
							numberOfTimesRan += 1
							if numberOfTimesRan == recommendedPlaylists.playlists.items.count {
								do {
									group.leave()
								}
							}

						case .failure(let error):
							self?.handlingErrorDuringLoadingData(error: error)
						}
					}
				}
				
			case .failure(let error):
				self?.handlingErrorDuringLoadingData(error: error)
			}
		}

		// Getting Recommended songs
		APICaller.shared.loadRecommendedTracks { [weak self] recommendedSongsResults in
			print("Loading Recommended songs")
			switch recommendedSongsResults {
			case .success(let data):
				defer {
					group.leave()
				}
				DBManager.shared.addSongsToDB(data.tracks, typeOfPassedSongs: DBSongTypes.recommended)

			case.failure(let error):
				self?.handlingErrorDuringLoadingData(error: error)
			}
		}

		// Moving forward once all the data has been loaded
		group.notify(queue: .main) {
			self.configureModels()
		}
		
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
					DBManager.shared.addSongsToDB(resultFromAPICaller, typeOfPassedSongs: DBSongTypes.liked)
				}
			}
		}
	}

	// MARK: Updating Song Data
	func getUpdatedDataFromDB(completion: @escaping ((Bool) -> Void)) {
		let group = DispatchGroup()
		group.enter()
		group.enter()

		DBManager.shared.getPlaylistsFormDB { [weak self] result in
			defer {
				group.leave()
			}
			self?.featuredPlaylists = result
		}
		DBManager.shared.getRecommendedSongsFromDB { [weak self] result in
			defer {
				group.leave()
			}
			self?.recommendedSongs = result
		}

		group.notify(queue: .main) {
			completion(true)
		}
	}

	// MARK: Creating or updating ViewModels
	func configureModels() {
		getUpdatedDataFromDB { [weak self] success in
			if success {
				self?.sections.removeAll()
				self?.sections.append(.featuredPlaylists(viewModels: (self?.featuredPlaylists.compactMap({
					return PlaylistCellViewModel(
						name: $0.name,
						playlistCoverURL: $0.image,
						description: $0.playlistDescription,
						numberOfTracks: $0.numberOfTracks
					)
				}))!))
				self?.sections.append(.recommendedSongs(viewModels: (self?.recommendedSongs.compactMap({
					return SongCellViewModel(
						id: $0.id,
						name: $0.name,
						albumCoverURL: $0.albumCoverURL,
						artistName: $0.artistName,
						explicit: $0.explicit,
						liked: $0.liked
					)
				}))!))

				self?.collectionView.reloadData()
			}
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
		let group = DispatchGroup()
		group.enter()

		TrackHandlerManager.shared.processLikeButtonTappedAction(
			id: id,
			liked: liked
		) {
			do {
				group.leave()
			}
		}

		group.notify(queue: .main) {
			self.configureModels()
		}
	}
}

// MARK: Configuring Collection View
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	// MARK: Setting Number of Items in Section
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let type = sections[section]
		switch type {
		case .featuredPlaylists(let viewModels):
			return viewModels.count

		case .recommendedSongs(let viewModels):
			return viewModels.count
		}
	}

	// MARK: Setting Number of Sections to Display
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return sections.count
	}

	// MARK: Configuring Cells in Collection View
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let type = sections[indexPath.section]
		switch type {
		case .featuredPlaylists(let viewModels):
			guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: PlaylistCollectionViewCell.identifier,
				for: indexPath) as? PlaylistCollectionViewCell
			else {
				return UICollectionViewCell()
			}
			let viewModel = viewModels[indexPath.row]

			cell.configure(with: viewModel)

			return cell

		case .recommendedSongs(let viewModels):
			guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: SongCollectionViewCell.identifier,
				for: indexPath) as? SongCollectionViewCell
			else {
				return UICollectionViewCell()
			}

			let viewModel = viewModels[indexPath.row]

			cell.configure(with: viewModel)
			cell.likeButtonTapAction = {
				[weak self] () in
				self?.processLikeButtonTappedAction(id: viewModel.id, liked: viewModel.liked)
			}

			return cell
		}
	}
	
	// MARK: Creating Headers for the Sections
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard let header = collectionView.dequeueReusableSupplementaryView(
			ofKind: kind,
			withReuseIdentifier: TitleHeaderCollectionReusableView.identifier,
			for: indexPath
		) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
			return UICollectionReusableView()
		}
		let section = indexPath.section

		let title = sections[section].title
		print(title)
		header.configure(with: title)

		return header
	}

	// MARK: Creating Section Layout for Collection View
	static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
		let supplementaryViews = [
			NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1),
					heightDimension: .absolute(50)
				),
				elementKind: UICollectionView.elementKindSectionHeader,
				alignment: .top
			)
		]

		switch section {
		// Liked Songs Section
		case 0:
			// Item
			let item = NSCollectionLayoutItem(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .fractionalHeight(1.0))
			)
			item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

			// Group
			let verticalGroup = NSCollectionLayoutGroup.vertical(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .absolute(390)
				),
				subitem: item,
				count: 3
			)
			let horizontalGroup = NSCollectionLayoutGroup.horizontal(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(0.9),
					heightDimension: .absolute(390)
				),
				subitem: verticalGroup,
				count: 1
			)

			// Section
			let section = NSCollectionLayoutSection(group: horizontalGroup)
			section.orthogonalScrollingBehavior = .groupPaging
			section.boundarySupplementaryItems = supplementaryViews
			return section

		// Recommended Songs Section
		default:
			// Item
			let item = NSCollectionLayoutItem(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .fractionalWidth(1.0))
			)
			item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

			// Group
			let group = NSCollectionLayoutGroup.vertical(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .absolute(80)
				),
				subitem: item,
				count: 1
			)

			// Section
			let section = NSCollectionLayoutSection(group: group)
			section.boundarySupplementaryItems = supplementaryViews
			return section
		}
	}
}
