import SnapKit
import UIKit
// swiftlint:disable all
enum SectionType {
	case likedSongs(viewModels: [SongCellViewModel])
	case recommendedSongs(viewModels: [SongCellViewModel])

	var title: String {
		switch self {
		case .likedSongs:
			return L10n.likedSongs
		case .recommendedSongs:
			return L10n.recommendedSongs
		}
	}
}

class MainViewController: UIViewController {
	var recommendedSongs: [SongObject] = []
	var likedSongs: [SongObject] = []

	var sections = [SectionType]()

    // MARK: - Subviews
	var collectionView = UICollectionView(
		frame: .zero,
		collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
			return MainViewController.createSectionLayout(section: sectionIndex)
	 })

	let spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView()
		spinner.tintColor = .label
		spinner.hidesWhenStopped = true
		return spinner
	}()

    // MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

		setupViews()
		loadTheData()
    }

    // MARK: Adding different elements to view
    func setupViews() {
		title = setTitleDependingOnTheTimeOfDay()
		view.backgroundColor = .systemBackground

		let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(didTapSettings))
		settingsButton.tintColor = .label
		navigationItem.rightBarButtonItems = [settingsButton]

		view.addSubview(collectionView)
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
		collectionView.register(LikedSongCollectionViewCell.self, forCellWithReuseIdentifier: LikedSongCollectionViewCell.identifier)
		collectionView.register(RecommendedSongCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedSongCollectionViewCell.identifier)
		collectionView.dataSource = self
		collectionView.delegate = self

		view.addSubview(spinner)
    }

	// MARK: Laying out constraints
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		collectionView.frame = view.bounds
	}
	
	func setTitleDependingOnTheTimeOfDay() -> String {
		// let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate()) Swift 2 legacy
		let hour = Calendar.current.component(.hour, from: Date())

		switch hour {
		case 6..<12 : return L10n.goodMorning
		case 12..<17 : return L10n.goodAfternoon
		case 17..<22 : return L10n.goodEvening
		default: return L10n.goodNight
		}
	}

	@objc
	func didTapSettings() {
		let settingsVC = SettingsViewController()
		settingsVC.navigationItem.largeTitleDisplayMode = .never
		navigationController?.pushViewController(settingsVC, animated: true)
	}

	// MARK: Getting Data Form API & Firebase, then storing & retrieving it from Realm
	func loadTheData() {
		let group = DispatchGroup()
		group.enter()
		group.enter()
		group.enter()

		DBManager.shared.purgeAllSongsInRealmOnLaunch { success in
			if success {
				defer {
					group.leave()
				}
				print("Purged all songs in Realm")
			}
		}

		// getting user profile
		print("Loading User data")
		APICaller.shared.loadUser { [weak self] userProfileResults in
			switch userProfileResults {
			case .success(let data):
				DBManager.shared.addUserToDB(data)

			case .failure(let error):
				self?.handlingErrorDuringLoadingData(error: error)
			}
		}

		// getting Recommended songs
		APICaller.shared.loadRecommendedTracks { [weak self] recommendedSongsResults in
			print("Loading recommended songs")
			switch recommendedSongsResults {
			case .success(let data):
				DBManager.shared.addSongsToDB(data.tracks, typeOfPassedSongs: DBSongTypes.recommended)
				DBManager.shared.getRecommendedSongsFromDB { [weak self] result in
					defer {
						group.leave()
					}
					self?.recommendedSongs = result
				}

			case.failure(let error):
				self?.handlingErrorDuringLoadingData(error: error)
			}
		}

		// getting Liked songs
		FirebaseManager.shared.getData { [weak self] resultFromFirebase in
			// checking firebase response, if there's any liked songs we load and store them
			print("Checking if user have any liked songs")
			if !resultFromFirebase.isEmpty {
				print("Loading liked songs")
				// Handling fetching data from Firebase and APICaller
				LoadAllTheLikedSongsHelper.shared.getData(resultFromFirebase) { resultFromAPICaller in
					DBManager.shared.addSongsToDB(resultFromAPICaller, typeOfPassedSongs: DBSongTypes.liked)
					DBManager.shared.getLikedSongsFromDB { result in
						defer {
							group.leave()
						}
						self?.likedSongs = result
					}
				}
			} else {
				print("User has no liked Songs")
			}
		}

		group.notify(queue: .main) {
			self.configureModels()
		}
	}

	func getUpdatedDataFromDB(completion: @escaping ((Bool) -> Void)) {
		let group = DispatchGroup()
		group.enter()
		group.enter()

		DBManager.shared.getRecommendedSongsFromDB { [weak self] result in
			defer {
				group.leave()
			}
			self?.recommendedSongs = result
		}
		DBManager.shared.getLikedSongsFromDB { [weak self] result in
			defer {
				group.leave()
			}
			self?.likedSongs = result
		}

		group.notify(queue: .main) {
			completion(true)
		}
	}

	func configureModels() {
		sections.removeAll()
		sections.append(.likedSongs(viewModels: likedSongs.compactMap({
			return SongCellViewModel(
				id: $0.id,
				name: $0.name,
				albumCoverURL: $0.albumCoverURL,
				artistName: $0.artistName,
				explicit: $0.explicit,
				liked: $0.liked
			)
		})))
		sections.append(.recommendedSongs(viewModels: recommendedSongs.compactMap({
			return SongCellViewModel(
				id: $0.id,
				name: $0.name,
				albumCoverURL: $0.albumCoverURL,
				artistName: $0.artistName,
				explicit: $0.explicit,
				liked: $0.liked
			)
		})))

		collectionView.reloadData()
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
	func processLikeButtonTappedAction(id: String, liked: Bool) {
		let group = DispatchGroup()
		group.enter()

		if liked {
			FirebaseManager.shared.deleteUnlikedSongFromFirebase(id) { success in
				if success {
					defer {
						group.leave()
					}
					DBManager.shared.dislikedSong(id)
				}
			}
		} else {
			FirebaseManager.shared.addLikedSongToFirebase(id) { success in
				if success {
					defer {
						group.leave()
					}
					DBManager.shared.likedSong(id)
				}
			}
		}

		group.notify(queue: .main) {
			self.getUpdatedDataFromDB { [weak self] success in
				if success {
					self?.configureModels()
				}
			}
		}
	}
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let type = sections[section]
		switch type {
		case .likedSongs(let viewModels):
			return viewModels.count

		case .recommendedSongs(let viewModels):
			return viewModels.count
		}
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return sections.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let type = sections[indexPath.section]
		switch type {
		case .likedSongs(let viewModels):
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LikedSongCollectionViewCell.identifier, for: indexPath) as? LikedSongCollectionViewCell else {
				return UICollectionViewCell()
			}
			let viewModel = viewModels[indexPath.row]
			cell.configure(with: viewModel)
			cell.likeButtonTapAction = {
				[weak self] () in
				self?.processLikeButtonTappedAction(id: viewModel.id, liked: viewModel.liked)
			}
			return cell

		case .recommendedSongs(let viewModels):
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedSongCollectionViewCell.identifier, for: indexPath) as? RecommendedSongCollectionViewCell else {
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

	static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
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
			return section

		// Recommended Songs Section
		case 1:
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
			return section

		default:
			// Item
			let item = NSCollectionLayoutItem(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .fractionalHeight(1.0))
			)
			item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

			// Group
			let group = NSCollectionLayoutGroup.vertical(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .absolute(390)
				),
				subitem: item,
				count: 1
			)

			// Section
			let section = NSCollectionLayoutSection(group: group)
			return section
		}
	}
}
