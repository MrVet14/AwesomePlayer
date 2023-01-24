import SnapKit
import UIKit

class LikedSongsViewController: UIViewController {
	var likedSongs: [SongObject] = []
	var likedSongsViewModels: [SongCellViewModel] = []

	// MARK: - Subviews
	var collectionView = UICollectionView(
		frame: .zero,
		collectionViewLayout: UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
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
		})

	let noLikedSongsLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 22, weight: .semibold)
		label.text = L10n.noLikedSongs
		label.textAlignment = .center
		label.numberOfLines = 2
		return label
	}()

	let noLikedSongsSubLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 18, weight: .regular)
		label.textColor = .secondaryLabel
		label.text = L10n.tryExploringOurRecommendationList
		label.textAlignment = .center
		label.numberOfLines = 3
		return label
	}()

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
		configureModel()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(configureModel),
			name: Notification.Name(NotificationCenterConstants.playerVCClosed),
			object: nil
		)
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		configureModel()
	}

	// MARK: Adding view elements to View & configuring them
	func setupViews() {
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
		collectionView.dataSource = self
		collectionView.delegate = self

		view.addSubview(noLikedSongsLabel)
		view.addSubview(noLikedSongsSubLabel)
		view.addSubview(indicatorView)
	}

	// MARK: Setting Constraints
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		collectionView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		noLikedSongsLabel.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}

		noLikedSongsSubLabel.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(noLikedSongsLabel.snp.bottom).offset(10)
		}

		indicatorView.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
	}

	// MARK: Getting Fresh Data from DB
	func getUpdatedDataFromDB(completion: @escaping (() -> Void)) {
		DBManager.shared.getLikedSongs { [weak self] likedSongsFromDB in
			self?.likedSongs = likedSongsFromDB
			completion()
		}
	}

	// MARK: Creating or updating ViewModels
	@objc
	func configureModel() {
		getUpdatedDataFromDB { [weak self] in
			guard let self = self else {
				return
			}

			self.indicatorView.isHidden = true

			if self.likedSongs.isEmpty == true {
				self.collectionView.isHidden = true
				self.noLikedSongsLabel.isHidden = false
				self.noLikedSongsSubLabel.isHidden = false
			} else {
				self.collectionView.isHidden = false
				self.noLikedSongsLabel.isHidden = true
				self.noLikedSongsSubLabel.isHidden = true

				self.likedSongsViewModels.removeAll()
				let viewModelToReturn = self.likedSongs.compactMap({
					return SongCellViewModel(
						id: $0.id,
						name: $0.name,
						albumCoverURL: $0.albumCoverURL,
						artistName: $0.artistName,
						explicit: $0.explicit,
						liked: $0.liked)
				})
				self.likedSongsViewModels.append(contentsOf: viewModelToReturn)

				self.collectionView.reloadData()
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
extension LikedSongsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	// MARK: Setting Number of Items in Section
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return likedSongsViewModels.count
	}

	// MARK: Configuring Cells in Collection View
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: SongCollectionViewCell.identifier,
			for: indexPath) as? SongCollectionViewCell
		else {
			return UICollectionViewCell()
		}

		let viewModel = likedSongsViewModels[indexPath.row]

		cell.configure(with: viewModel)
		cell.likeButtonTapAction = { [weak self] in
			self?.processLikeButtonTappedAction(id: viewModel.id, liked: viewModel.liked)
		}

		return cell
	}

	// MARK: Adding Action on Tap on Cell
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		HapticsManager.shared.vibrateForSelection()
		let song = likedSongs[indexPath.row]
		PlayerPresenter.shared.startPlaybackProcess(from: self, listOfOtherSongsInView: likedSongs, song: song)
	}
}
