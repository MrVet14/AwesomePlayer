import SnapKit
import UIKit

class LikedSongsViewController: UIViewController {
	var likedSongs: [SongObject] = []
	var likedSongsViewModels: [SongCellViewModel] = []

	// MARK: - Subviews
	var collectionView = UICollectionView(
		frame: .zero,
		collectionViewLayout: UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
			return LikedSongsViewController().createSectionLayout()
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

	// MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

		configureModel()
		setupViews()
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
	}

	// MARK: Getting Fresh Data from DB
	func getUpdatedDataFromDB(completion: @escaping ((Bool) -> Void)) {
		let group = DispatchGroup()
		group.enter()

		DBManager.shared.getLikedSongsFromDB { [weak self] likedSongsFromDB in
			defer {
				group.leave()
			}
			self?.likedSongs = likedSongsFromDB
		}

		group.notify(queue: .main) {
			completion(true)
		}
	}

	// MARK: Creating or updating ViewModels
	func configureModel() {
		getUpdatedDataFromDB { [weak self] success in
			if success {
				// Used .count, because .isEmpty not working in closure
				// swiftlint:disable empty_count
				if self?.likedSongs.count == 0 {
					self?.collectionView.isHidden = true
					self?.noLikedSongsLabel.isHidden = false
					self?.noLikedSongsSubLabel.isHidden = false
				} else {
					self?.collectionView.isHidden = false
					self?.noLikedSongsLabel.isHidden = true
					self?.noLikedSongsSubLabel.isHidden = true

					self?.likedSongsViewModels.removeAll()
					self?.likedSongsViewModels.append(contentsOf: (self?.likedSongs.compactMap({
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
	}

	// MARK: Controller logic
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
		cell.likeButtonTapAction = {
			[weak self] () in
			self?.processLikeButtonTappedAction(id: viewModel.id, liked: viewModel.liked)
		}

		return cell
	}

	// MARK: Creating Section Layout for Collection View
	func createSectionLayout() -> NSCollectionLayoutSection {
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
	}
}
