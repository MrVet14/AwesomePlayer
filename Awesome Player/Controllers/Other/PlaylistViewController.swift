import SnapKit
import UIKit

class PlaylistViewController: UIViewController {
	let playlist: PlaylistObject
	var playlistSongs: [SongObject] = []
	var playlistSongViewModel: [SongCellViewModel] = []

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

	// MARK: Init
	init(playlist: PlaylistObject) {
		self.playlist = playlist
		super.init(nibName: nil, bundle: nil)
	}

	// swiftlint:disable fatal_error
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Apps life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

		configureModel()
		setUpViews()
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
	}

	// MARK: Setting Constraints
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		collectionView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}

	// MARK: Loading Data
	func getDataFromDB(completion: @escaping ((Bool) -> Void)) {
		DBManager.shared.getSongsForAPlaylist(playlist.id) { [weak self] result in
			self?.playlistSongs = result
			completion(true)
		}
	}

	// MARK: Updating or creating View Models
	func configureModel() {
		getDataFromDB { [weak self] success in
			if success {
				self?.playlistSongViewModel.removeAll()
				self?.playlistSongViewModel.append(contentsOf: (self?.playlistSongs.compactMap({
					return SongCellViewModel(
						id: $0.id,
						name: $0.name,
						albumCoverURL: $0.albumCoverURL,
						artistName: $0.artistName,
						explicit: $0.explicit,
						liked: $0.liked)
				}))!)

				self?.collectionView.reloadData()
			}
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
		cell.likeButtonTapAction = {
			[weak self] () in
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
		let song = playlistSongs[indexPath.row]
		print("Playlist song with id: \(song.id) has been tapped")
	}
}
