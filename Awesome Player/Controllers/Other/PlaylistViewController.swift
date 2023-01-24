import SnapKit
import UIKit

class PlaylistViewController: UIViewController {
	var playlist = PlaylistObject()
	var playlistSongs: [SongObject] = []
	var playlistSongViewModel: [SongCellViewModel] = []
	var alreadyLoaded = false

	var hasBeenLoaded: (() -> Void)?

	// MARK: Subviews
	var collectionView = UICollectionView(
		frame: .zero,
		collectionViewLayout: UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
			// Item
			let item = NSCollectionLayoutItem(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .fractionalWidth(1.0))
			)
			item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)

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
			section.boundarySupplementaryItems = [
				NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: NSCollectionLayoutSize(
						widthDimension: .fractionalWidth(1),
						heightDimension: .fractionalWidth(1)
					),
					elementKind: UICollectionView.elementKindSectionHeader,
					alignment: .top
				)
			]
			return section
		})

	lazy var indicatorView: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(style: .medium)
		view.color = .white
		view.hidesWhenStopped = true
		view.startAnimating()
		return view
	}()

	// MARK: Apps life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

		setUpViews()
		if alreadyLoaded {
			configureModel()
		} else {
			loadData()
		}

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(configureModel),
			name: Notification.Name(NotificationCenterConstants.playerVCClosed),
			object: nil
		)
    }

	// MARK: Adding view elements to View & configuring them
	func setUpViews() {
		title = playlist.name
		view.backgroundColor = .systemBackground

		view.addSubview(collectionView)
		collectionView.register(
			UICollectionViewCell.self,
			forCellWithReuseIdentifier: "cell"
		)
		collectionView.register(
			SongCollectionViewCell.self,
			forCellWithReuseIdentifier: SongCollectionViewCell.identifier
		)
		collectionView.register(
			PlaylistHeaderCollectionReusableView.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier
		)
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.isHidden = true

		view.addSubview(indicatorView)
	}

	// MARK: Setting Constraints
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		collectionView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		indicatorView.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
	}

	// MARK: Loading Data for Playlist
	func loadData() {
		// Getting play list sons from API
		APICaller.shared.loadPlaylistDetails(playlist.id) { [weak self] playlistDetailsResult in
			switch playlistDetailsResult {
			case .success(let playlistDetails):
				// Adding Songs to Realm & Creating Models
				DBManager.shared.addPlaylistsSongs(playlistDetails)
				self?.configureModel()
				// letting MainVC know that playlist has been downloaded
				self?.hasBeenLoaded?()

			case .failure(let error):
				self?.handlingErrorDuringLoadingData(error: error)
			}
		}
	}

	// MARK: Loading Data
	func getDataFromDB(completion: @escaping (() -> Void)) {
		DBManager.shared.getSongsForAPlaylist(playlist.id) { [weak self] result in
			self?.playlistSongs = result
			completion()
		}
	}

	// MARK: Updating or creating View Models
	@objc
	func configureModel() {
		getDataFromDB { [weak self] in
			guard let self = self else {
				return
			}

			self.playlistSongViewModel.removeAll()
			let viewModelToReturn = self.playlistSongs.compactMap({
				return SongCellViewModel(
					id: $0.id,
					name: $0.name,
					albumCoverURL: $0.albumCoverURL,
					artistName: $0.artistName,
					explicit: $0.explicit,
					liked: $0.liked)
			})
			self.playlistSongViewModel.append(contentsOf: viewModelToReturn)

			self.indicatorView.isHidden = true
			self.collectionView.isHidden = false

			self.collectionView.reloadData()
		}
	}

	// MARK: Controller logic
	// Processing tap on like button
	func processLikeButtonTappedAction(
		id: String,
		liked: Bool
	) {
		TrackHandlerManager.shared.processLikeButtonTappedAction(
			id: id,
			liked: liked
		) {
			self.configureModel()
		}
	}

	func handlingErrorDuringLoadingData(error: Error) {
		print(error.localizedDescription)

		HapticsManager.shared.vibrate(for: .error)

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
					self?.loadData()
				}
			)
		)
		present(alert, animated: true)
	}
}

// MARK: Configuring Collection View
extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	// MARK: Setting Number of Items in Section
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return playlistSongViewModel.count
	}

	// MARK: Configuring Cells in Collection View
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: SongCollectionViewCell.identifier,
			for: indexPath) as? SongCollectionViewCell
		else {
			return UICollectionViewCell()
		}

		let viewModel = playlistSongViewModel[indexPath.row]

		cell.configure(with: viewModel)
		cell.likeButtonTapAction = { [weak self] in
			self?.processLikeButtonTappedAction(id: viewModel.id, liked: viewModel.liked)
		}

		return cell
	}

	// MARK: Adding Header to Collection View
	func collectionView(
		_ collectionView: UICollectionView,
		viewForSupplementaryElementOfKind kind: String,
		at indexPath: IndexPath
	) -> UICollectionReusableView {
		guard let header = collectionView.dequeueReusableSupplementaryView(
			ofKind: kind,
			withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
			for: indexPath
		) as? PlaylistHeaderCollectionReusableView,
		kind == UICollectionView.elementKindSectionHeader else {
			return UICollectionReusableView()
		}
		let headerViewModel = PlaylistHeaderViewViewModel(
			description: playlist.playlistDescription,
			artworkURL: playlist.image
		)

		header.configure(with: headerViewModel)

		return header
	}

	// MARK: Adding Action on Tap on Cell
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		HapticsManager.shared.vibrateForSelection()
		let song = playlistSongs[indexPath.row]
		PlayerPresenter.shared.startPlaybackProcess(from: self, listOfOtherSongsInView: playlistSongs, song: song)
	}
}
